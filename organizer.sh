#!/bin/bash

# 1. Solicitar ruta
printf "Introduce el nombre de la carpeta o la ruta completa (ej: /media/disco/fotos): "
read -r input_dir

# 2. Configurar directorio de salida
if [ -z "$input_dir" ]; then
    # Opción por defecto
    output_dir="./Archivos_Organizados"
    is_absolute=0
else
    # Comprobar si es ruta absoluta (empieza por /)
    if [[ "$input_dir" == /* ]]; then
        output_dir="$input_dir"
        is_absolute=1
    else
        output_dir="./$input_dir"
        is_absolute=0
    fi
fi

echo "---------------------------------------------------"
echo "Destino seleccionado: $output_dir"
echo "---------------------------------------------------"
sleep 1

# 3. Calcular total de archivos y definir el comando find
# Si es absoluta (disco externo), no necesitamos excluir nada (-prune) porque find . no llegará allí.
# Si es relativa, usamos -path en lugar de -name para evitar errores con barras.

if [ "$is_absolute" -eq 1 ]; then
    # Ruta absoluta: buscamos todo, ya que el destino está fuera
    total_files=$(find . -type f | wc -l)
    find_cmd="find . -type f -print0"
else
    # Ruta relativa: hay que excluir la carpeta de destino para no hacer bucle
    # Usamos -path para permitir subcarpetas (ej: ./backup/fotos)
    total_files=$(find . -path "$output_dir" -prune -o -type f | wc -l)
    find_cmd="find . -path $output_dir -prune -o -type f -print0"
fi

processed_files=0
echo "Iniciando organización de $total_files archivos..."

# 4. Ejecutar el bucle con el comando dinámico
eval "$find_cmd" | while IFS= read -r -d '' file; do
    
    timestamp=$(stat -c %y "$file")
    year=${timestamp:0:4}
    month=${timestamp:5:2}
    day=${timestamp:8:2}
    hour=${timestamp:11:2}
    minute=${timestamp:14:2}

    base_file=$(basename "$file")
    extension="${base_file##*.}"

    # Construye la ruta de destino
    target_path="$output_dir/$year/$month"
    
    mkdir -p "$target_path"

    counter=0
    counter_formatted=$(printf "%05d" $counter)

    new_filename="${year}_${month}_${day}_${hour}_${minute}_${counter_formatted}"
    
    if [ -n "$extension" ] && [ "$extension" != "$base_file" ]; then
        new_filename="$new_filename.$extension"
    else
        new_filename="$new_filename" 
    fi
    
    full_new_path="$target_path/$new_filename"

    # Evita sobrescribir
    while [ -e "$full_new_path" ]; do
        counter=$((counter+1))
        counter_formatted=$(printf "%05d" $counter)
        
        new_filename="${year}_${month}_${day}_${hour}_${minute}_${counter_formatted}"
        if [ -n "$extension" ] && [ "$extension" != "$base_file" ]; then
            new_filename="$new_filename.$extension"
        fi
        full_new_path="$target_path/$new_filename"
    done

    # Copia el archivo
    cp -p "$file" "$full_new_path"

    # --- Barra de Progreso ---
    processed_files=$((processed_files+1))
    
    if [ "$total_files" -gt 0 ]; then
        progress=$((processed_files * 100 / total_files))
        num_hashes=$((progress / 2))
        bar=$(printf "%0.s#" $(seq 1 $num_hashes))
        printf "\rProgreso: [%-50s] %d%% (%d/%d)" "$bar" "$progress" "$processed_files" "$total_files"
    fi

done

printf "\n\n¡Proceso finalizado! Tus archivos están en: %s\n\n" "$output_dir"
