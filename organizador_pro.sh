#!/bin/bash

# Función para obtener la ruta absoluta
get_abs_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

clear
echo "======================================================="
echo "   ORGANIZADOR MAESTRO: TIPO > EXTENSIÓN > FECHA     "
echo "======================================================="
echo ""

# --- PASO 1: Solicitar y Validar ORIGEN ---
while true; do
    printf "📂 Ruta de la carpeta de ORIGEN (donde está el desorden): "
    read -r source_input
    
    if [ -z "$source_input" ]; then
        source_input="."
    fi

    if [ -d "$source_input" ]; then
        abs_source=$(cd "$source_input" && pwd)
        echo "   -> Origen validado: $abs_source"
        break
    else
        echo "   ❌ Error: La carpeta no existe. Inténtalo de nuevo."
    fi
done

echo ""

# --- PASO 2: Solicitar y Crear DESTINO ---
printf "💾 Ruta de la carpeta de DESTINO (donde guardar lo ordenado): "
read -r dest_input

if [ -z "$dest_input" ]; then
    dest_input="./Archivos_Organizados"
fi

mkdir -p "$dest_input"
abs_dest=$(cd "$dest_input" && pwd)
echo "   -> Destino configurado: $abs_dest"
echo ""

# --- PASO 3: Protección anti-bucle ---
if [[ "$abs_dest" == "$abs_source"* ]]; then
    echo "⚠️  Nota: El destino está dentro del origen. Activando exclusión."
    find_cmd="find \"$abs_source\" -path \"$abs_dest\" -prune -o -type f -print0"
    count_cmd="find \"$abs_source\" -path \"$abs_dest\" -prune -o -type f | wc -l"
else
    find_cmd="find \"$abs_source\" -type f -print0"
    count_cmd="find \"$abs_source\" -type f | wc -l"
fi

# --- PASO 4: Ejecución ---
echo "-------------------------------------------------------"
echo "Calculando total de archivos..."
total_files=$(eval "$count_cmd")
processed_files=0

if [ "$total_files" -eq 0 ]; then
    echo "❌ No se encontraron archivos en el origen."
    exit 0
fi

echo "Iniciando clasificación profunda de $total_files archivos..."
sleep 1

# Bucle principal
eval "$find_cmd" | while IFS= read -r -d '' file; do
    
    # 1. Obtener datos de fecha
    timestamp=$(stat -c %y "$file")
    year=${timestamp:0:4}
    month=${timestamp:5:2}
    day=${timestamp:8:2}
    hour=${timestamp:11:2}
    minute=${timestamp:14:2}

    # 2. Obtener extensión y normalizar
    base_file=$(basename "$file")
    extension="${base_file##*.}"
    ext_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Crear variable para la carpeta de extensión (en Mayúsculas para que quede bonito)
    # Si no tiene extensión, carpeta "SIN_EXT"
    if [ "$extension" == "$base_file" ]; then
        ext_folder="SIN_EXT"
    else
        ext_folder=$(echo "$extension" | tr '[:lower:]' '[:upper:]')
    fi

    # 3. CLASIFICACIÓN POR CATEGORÍA PRINCIPAL
    if [ "$extension" == "$base_file" ]; then
        category_folder="Varios"
    else
        case "$ext_lower" in
            # Documentos
            pdf|doc|docx|xls|xlsx|ppt|pptx|txt|rtf|odt|ods|odp|csv|md|epub|pages|numbers|key)
                category_folder="Documentos"
                ;;
            # Imágenes
            jpg|jpeg|png|gif|bmp|tiff|tif|heic|heif|raw|cr2|nef|arw|svg|webp|ico|psd|ai)
                category_folder="Imágenes"
                ;;
            # Vídeos
            mp4|mov|avi|mkv|flv|wmv|webm|m4v|3gp|mpg|mpeg|ts|mts)
                category_folder="Vídeos"
                ;;
            # Sonidos
            mp3|wav|flac|aac|ogg|wma|m4a|aiff|alac|mid)
                category_folder="Sonidos"
                ;;
            # Archivos Comprimidos
            zip|rar|7z|tar|gz|tgz|bz2|xz|iso|dmg)
                category_folder="Comprimidos"
                ;;
            # Certificados y Claves
            p12|pfx|cer|crt|pem|key|der|p7b|crl)
                category_folder="Certificados"
                ;;
            # Todo lo demás
            *)
                category_folder="Varios"
                ;;
        esac
    fi

    # 4. Construir ruta destino COMPLETA
    # Estructura: Destino / Categoría / EXTENSIÓN / Año / Mes
    target_path="$abs_dest/$category_folder/$ext_folder/$year/$month"
    mkdir -p "$target_path"

    # 5. Lógica de renombrado (evitar colisiones)
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

    # 6. Copiar archivo
    cp -p "$file" "$full_new_path"

    # Barra de progreso
    processed_files=$((processed_files+1))
    progress=$((processed_files * 100 / total_files))
    num_hashes=$((progress / 2))
    bar=$(printf "%0.s#" $(seq 1 $num_hashes))
    printf "\rProgreso: [%-50s] %d%% (%d/%d)" "$bar" "$progress" "$processed_files" "$total_files"

done

echo ""
echo ""
echo "======================================================="
echo "   ✅ ¡ORGANIZACIÓN COMPLETADA!"
echo "   Estructura creada en: $abs_dest"
echo "   (Categoría -> Extensión -> Año -> Mes)"
echo "======================================================="