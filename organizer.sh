#!/bin/bash

# Función para obtener la ruta absoluta (compatible con Linux/Mac)
get_abs_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

clear
echo "======================================================="
echo "   ORGANIZADOR DE ARCHIVOS MASIVO (Modo Avanzado)    "
echo "======================================================="
echo ""

# --- PASO 1: Solicitar y Validar ORIGEN ---
while true; do
    printf "📂 Ruta de la carpeta de ORIGEN (donde está el desorden): "
    read -r source_input
    
    # Si está vacío, asumir directorio actual
    if [ -z "$source_input" ]; then
        source_input="."
    fi

    if [ -d "$source_input" ]; then
        # Convertir a ruta absoluta para evitar confusiones
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

# Si está vacío, crear por defecto en el directorio actual
if [ -z "$dest_input" ]; then
    dest_input="./Archivos_Organizados"
fi

# Crear directorio de destino (si no existe) para poder resolver su ruta absoluta
mkdir -p "$dest_input"
abs_dest=$(cd "$dest_input" && pwd)
echo "   -> Destino configurado: $abs_dest"
echo ""

# --- PASO 3: Configurar lógica de búsqueda (Protección anti-bucle) ---
# Comprobamos si el destino está DENTRO del origen para excluirlo
# Si abs_dest empieza por abs_source...
if [[ "$abs_dest" == "$abs_source"* ]]; then
    echo "⚠️  Nota: El destino está dentro del origen. Se activará la exclusión para evitar bucles."
    # Usamos -path con la ruta absoluta del destino para excluirla
    find_cmd="find \"$abs_source\" -path \"$abs_dest\" -prune -o -type f -print0"
    # Para el conteo, misma lógica
    count_cmd="find \"$abs_source\" -path \"$abs_dest\" -prune -o -type f | wc -l"
else
    # Son rutas separadas (ej: Origen USB -> Destino Disco Duro)
    find_cmd="find \"$abs_source\" -type f -print0"
    count_cmd="find \"$abs_source\" -type f | wc -l"
fi

# --- PASO 4: Ejecución ---
echo "-------------------------------------------------------"
echo "Calculando total de archivos..."
# Usamos eval porque el comando se construyó dinámicamente
total_files=$(eval "$count_cmd")
processed_files=0

if [ "$total_files" -eq 0 ]; then
    echo "❌ No se encontraron archivos en el origen."
    exit 0
fi

echo "Iniciando organización de $total_files archivos..."
sleep 1

# Bucle principal
eval "$find_cmd" | while IFS= read -r -d '' file; do
    
    # Obtener fecha
    timestamp=$(stat -c %y "$file")
    year=${timestamp:0:4}
    month=${timestamp:5:2}
    day=${timestamp:8:2}
    hour=${timestamp:11:2}
    minute=${timestamp:14:2}

    base_file=$(basename "$file")
    extension="${base_file##*.}"

    # Construir ruta destino basada en la ruta absoluta de salida
    target_path="$abs_dest/$year/$month"
    mkdir -p "$target_path"

    # Lógica de renombrado (evitar colisiones)
    counter=0
    counter_formatted=$(printf "%05d" $counter)
    
    new_filename="${year}_${month}_${day}_${hour}_${minute}_${counter_formatted}"
    
    # Manejo de extensión
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

    # Copiar archivo
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
echo "   ✅ ¡PROCESO COMPLETADO CON ÉXITO!"
echo "   Los archivos han sido copiados a: $abs_dest"
echo "======================================================="
