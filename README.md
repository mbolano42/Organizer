# 📂 Organizador de Archivos por Fecha (Bash Script)

Un script de Bash robusto y seguro diseñado para organizar grandes cantidades de archivos desordenados. El script escanea el directorio actual (y subdirectorios), extrae la fecha de modificación de cada archivo y los copia organizadamente en carpetas estructuradas por `Año/Mes`.

## 🚀 Características

* **Organización Cronológica:** Crea automáticamente carpetas basadas en la fecha de modificación del archivo (ej. `2023/11`).
* **Renombrado Inteligente:** Estandariza los nombres de archivo al formato `YYYY_MM_DD_HH_MM_SS_Contador` para facilitar la ordenación.
* **Gestión de Duplicados:** Nunca sobrescribe archivos. Si dos archivos tienen la misma fecha y hora exacta, utiliza un contador incremental (00000, 00001...) para diferenciarlos.
* **Soporte de Rutas Flexibles:**
    * Soporta rutas relativas (crea una subcarpeta en el directorio actual).
    * Soporta rutas absolutas (ideal para copiar archivos organizados directamente a discos duros externos o USBs).
* **Seguridad de Datos:** Utiliza `cp -p` (copiar preservando atributos) en lugar de mover. **Tus archivos originales permanecen intactos** por seguridad.
* **Protección contra Bucles:** Detecta automáticamente si la carpeta de destino está dentro del directorio de origen para evitar procesar los archivos que se acaban de organizar.
* **Barra de Progreso:** Muestra una barra visual en tiempo real del estado de la copia.

## 📋 Requisitos

* Sistema operativo tipo Unix (Linux, macOS, WSL en Windows).
* Intérprete Bash.
* Comandos estándar preinstalados: `find`, `stat`, `cp`, `mkdir`.

## 🛠️ Instalación

1.  Descarga el script o crea un archivo nuevo, por ejemplo `organizar.sh`.
2.  Copia el código fuente en el archivo.
3.  Otorga permisos de ejecución:

```bash
chmod +x organizar.sh
````

## 📖 Uso

Ejecuta el script desde la terminal estando en la carpeta que contiene los archivos desordenados:

```bash
./organizar.sh
```

### Flujo de Ejecución

1.  El script te solicitará la **ruta de destino**.
      * **Opción A (Relativa):** Escribe un nombre (ej: `MisFotos`). Se creará `./MisFotos` en la carpeta actual.
      * **Opción B (Absoluta):** Escribe una ruta completa (ej: `/media/usb/Backup`). Se guardará en el disco externo.
      * **Opción C (Por defecto):** Pulsa `Enter` para usar la carpeta `./Archivos_Organizados`.
2.  El script calculará el total de archivos a procesar.
3.  Verás una barra de progreso mientras se copian y organizan los archivos.

## 📂 Ejemplo de Estructura

**Antes (Caos):**

```text
.
├── DCIM_001.jpg
├── documento_final.pdf
├── Captura de pantalla 2023-01.png
└── subcarpeta
    └── IMG_2022.jpg
```

**Después (Organizado):**

```text
/Ruta_Destino
├── 2022
│   └── 05
│       └── 2022_05_12_14_30_00_00000.jpg
└── 2023
    ├── 01
    │   └── 2023_01_15_09_00_00_00000.png
    └── 11
        ├── 2023_11_20_18_45_22_00000.jpg
        └── 2023_11_20_18_45_22_00001.pdf
```

## 🔧 Funcionamiento Técnico

El script sigue esta lógica interna:

1.  **Detección de Ruta:** Analiza si el input del usuario empieza por `/`.
      * Si es ruta absoluta, `find` busca en todo el directorio actual sin restricciones.
      * Si es ruta relativa, `find` utiliza la opción `-prune` para excluir la carpeta de destino y evitar bucles infinitos.
2.  **Extracción de Metadatos:** Utiliza `stat -c %y` para obtener la fecha precisa de modificación.
3.  **Bucle de Colisión:** Antes de copiar, verifica si el nombre de archivo destino ya existe (`while [ -e ... ]`). Si existe, incrementa un contador de 5 dígitos hasta encontrar un nombre libre.
4.  **Copia Segura:** Realiza la copia manteniendo los metadatos originales del archivo (fechas, permisos) gracias al flag `-p`.

## ⚠️ Nota Importante

Este script **COPIA** los archivos, no los mueve.

  * **Ventaja:** Si algo sale mal o no te gusta el resultado, tus archivos originales siguen ahí intactos.
  * **A tener en cuenta:** Necesitas tener suficiente espacio libre en el disco para duplicar la información (los archivos originales + los organizados). Una vez verifiques que todo está correcto, puedes borrar los originales manualmente.

-----

*Script desarrollado para automatización de backups y organización de medios.*

```
