#!/bin/bash

# Función para obtener la ruta absoluta
get_abs_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

clear
echo "======================================================="
echo "   ORGANIZADOR MAESTRO: CON REGISTRO DE LOGS         "
echo "======================================================="
echo ""

# --- PASO 1: Solicitar ORIGEN ---
while true; do
    printf "📂 Ruta de la carpeta de ORIGEN: "
    read -r source_input
    if [ -z "$source_input" ]; then source_input="."; fi

    if [ -d "$source_input" ]; then
        abs_source=$(cd "$source_input" && pwd)
        echo "   -> Origen: $abs_source"
        break
    else
        echo "   ❌ Error: La carpeta no existe."
    fi
done

echo ""

# --- PASO 2: Solicitar DESTINO ---
printf "💾 Ruta de la carpeta de DESTINO: "
read -r dest_input
if [ -z "$dest_input" ]; then dest_input="./Archivos_Organizados"; fi

mkdir -p "$dest_input"
abs_dest=$(cd "$dest_input" && pwd)
echo "   -> Destino: $abs_dest"
echo ""

# --- PREPARAR LOGS ---
log_success="$abs_dest/registro_exito.csv"
log_error="$abs_dest/registro_errores.txt"
echo "Archivo Original;Archivo Nuevo;Fecha" > "$log_success"
echo "Log de Errores - Inicio: $(date)" > "$log_error"

# --- PASO 3: Lógica Anti-bucle ---
if [[ "$abs_dest" == "$abs_source"* ]]; then
    find_cmd="find \"$abs_source\" -path \"$abs_dest\" -prune -o -type f -print0"
    count_cmd="find \"$abs_source\" -path \"$abs_dest\" -prune -o -type f | wc -l"
else
    find_cmd="find \"$abs_source\" -type f -print0"
    count_cmd="find \"$abs_source\" -type f | wc -l"
fi

# --- PASO 4: Ejecución ---
echo "Calculando archivos..."
total_files=$(eval "$count_cmd")
processed_files=0

if [ "$total_files" -eq 0 ]; then
    echo "❌ No hay archivos."
    exit 0
fi

echo "Iniciando copia de $total_files archivos..."
sleep 1

eval "$find_cmd" | while IFS= read -r -d '' file; do
    
    # Bloque TRY/CATCH manual para asegurar lectura
    if [ ! -r "$file" ]; then
        echo "ERROR DE LECTURA: No se puede leer $file (Permisos denegados?)" >> "$log_error"
        continue
    fi

    timestamp=$(stat -c %y "$file")
    year=${timestamp:0:4}
    month=${timestamp:5:2}
    day=${timestamp:8:2}
    hour=${timestamp:11:2}
    minute=${timestamp:14:2}

    base_file=$(basename "$file")
    extension="${base_file##*.}"
    ext_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Lógica Sin Extensión
    if [ "$extension" == "$base_file" ]; then
        ext_folder="SIN_EXT"
        category_folder="Varios"
    else
        ext_folder=$(echo "$extension" | tr '[:lower:]' '[:upper:]')
        
        # Clasificación
        case "$ext_lower" in
            log|pdf|doc|docx|xls|xlsx|ppt|pptx|txt|rtf|odt|ods|odp|csv|md|epub|pages|numbers|key) category_folder="Documentos" ;;
            jpg|jpeg|png|gif|bmp|tiff|tif|heic|heif|raw|cr2|nef|arw|svg|webp|ico|psd|ai) category_folder="Imágenes" ;;
            mp4|mov|avi|mkv|flv|wmv|webm|m4v|3gp|mpg|mpeg|ts|mts) category_folder="Vídeos" ;;
            mp3|wav|flac|aac|ogg|wma|m4a|aiff|alac|mid) category_folder="Sonidos" ;;
            zip|rar|7z|tar|gz|tgz|bz2|xz|iso|dmg) category_folder="Comprimidos" ;;
            p12|pfx|cer|crt|pem|key|der|p7b|crl) category_folder="Certificados" ;;
            *) category_folder="Varios" ;;
        esac
    fi

    target_path="$abs_dest/$category_folder/$ext_folder/$year/$month"
    mkdir -p "$target_path"

    counter=0
    counter_formatted=$(printf "%05d" $counter)
    new_filename="${year}_${month}_${day}_${hour}_${minute}_${counter_formatted}"
    
    if [ -n "$extension" ] && [ "$extension" != "$base_file" ]; then
        new_filename="$new_filename.$extension"
    fi
    
    full_new_path="$target_path/$new_filename"

    while [ -e "$full_new_path" ]; do
        counter=$((counter+1))
        counter_formatted=$(printf "%05d" $counter)
        new_filename="${year}_${month}_${day}_${hour}_${minute}_${counter_formatted}"
        if [ -n "$extension" ] && [ "$extension" != "$base_file" ]; then
            new_filename="$new_filename.$extension"
        fi
        full_new_path="$target_path/$new_filename"
    done

    # --- COPIA CON CONTROL DE ERRORES ---
    if cp -p "$file" "$full_new_path" 2>> "$log_error"; then
        # Registro en el CSV si ha ido bien
        echo "\"$file\";\"$full_new_path\";\"$timestamp\"" >> "$log_success"
    else
        echo "FALLO AL COPIAR: $file -> $full_new_path" >> "$log_error"
    fi

    # Barra de progreso arreglada
    processed_files=$((processed_files+1))
    bar_size=30
    if [ "$total_files" -gt 0 ]; then
        progress=$((processed_files * 100 / total_files))
        num_hashes=$(( (progress * bar_size) / 100 ))
        bar=$(printf "%0.s#" $(seq 1 $num_hashes))
        printf "\r\033[KProgreso: [%-*s] %d%% (%d/%d)" "$bar_size" "$bar" "$progress" "$processed_files" "$total_files"
    fi

done

echo ""
echo "======================================================="
echo "   ✅ FINALIZADO"
echo "   📄 Revisa el archivo: $log_error"
echo "   (Ahí verás por qué no se copiaron los archivos faltantes)"
echo "======================================================="