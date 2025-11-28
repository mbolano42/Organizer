# 📸 Organizador de Fotos de iPhone (Bash Script)

Un script de Bash diseñado para poner orden en el caos de la galería de tu iPhone. Este script recorre todas las subcarpetas extrañas de Apple (como `100APPLE`, `101APPLE`, `CLOUD`...) y unifica todas tus fotos y vídeos en una estructura limpia y ordenada por fecha.

Es ideal para realizar copias de seguridad de tu iPhone a un disco duro externo o a tu PC Linux/Mac.

## 🚀 Características

* **Adiós al caos del DCIM:** Ignora la estructura de carpetas aleatoria del iPhone (`100APPLE`, etc.) y lo centra todo en la fecha real de la foto.
* **Soporte de Formatos Apple:** Funciona perfectamente con `.HEIC`, `.JPG`, `.MOV`, `.PNG` y `.AAE`.
* **Renombrado Cronológico:** Transforma nombres genéricos como `IMG_4821.HEIC` a algo útil como `2023_12_24_10_00_00_00000.HEIC`.
* **Gestión de Ráfagas y Live Photos:** Si tienes varias fotos tomadas en el mismo segundo (o un Live Photo compuesto por imagen + vídeo), el script usa un contador inteligente para no sobrescribir nada y mantener ambos archivos.
* **Copia de Seguridad Segura:** Utiliza `cp -p` (copia preservando metadatos). **Tus archivos originales en el iPhone no se tocan ni se borran**, garantizando que no pierdas nada si hay un error de conexión.

## 🛠️ Instalación

1.  Guarda el código del script en un archivo, por ejemplo `organizar_iphone.sh`.
2.  Dale permisos de ejecución:

```bash
chmod +x organizar_iphone.sh
````

## 📖 Uso Recomendado con iPhone

1.  **Conecta tu iPhone** al ordenador y asegúrate de que está montado y puedes ver los archivos.
2.  Abre la terminal y entra en la carpeta `DCIM` de tu iPhone (o donde tengas todas las carpetas mezcladas).
3.  Ejecuta el script:

<!-- end list -->

```bash
/ruta/a/tu/script/organizar_iphone.sh
```

4.  **Selecciona el destino:**
      * Cuando el script te pregunte, te recomendamos usar una **ruta absoluta** a tu disco duro o carpeta de Backup en tu PC.
      * *Ejemplo:* `/home/usuario/Imágenes/Backup_iPhone_2024`

## 📂 Ejemplo Visual: Antes y Después

El objetivo es transformar el desorden típico de iOS en una estructura archivada perfecta.

### ❌ Antes (Estructura típica DCIM de iPhone)

```text
.
├── 100APPLE
│   ├── IMG_0001.HEIC
│   ├── IMG_0002.MOV
│   └── IMG_0003.JPG
├── 101APPLE
│   ├── IMG_0540.HEIC
│   ├── IMG_E0540.HEIC  (Edición de la anterior)
│   └── IMG_9998.PNG
└── 102APPLE
    ├── A0982312.MOV
    └── IMG_0001.HEIC   (Nombre repetido en otra carpeta)
```

### ✅ Después (Tu carpeta de Destino)

El script detecta la fecha real de creación y renombra todo para evitar conflictos, incluso si los nombres originales (`IMG_0001`) estaban repetidos.

```text
/home/usuario/Backup_iPhone_2024
├── 2022
│   └── 08
│       ├── 2022_08_15_14_30_22_00000.HEIC
│       └── 2022_08_15_14_30_22_00001.MOV
└── 2023
    ├── 12
    │   ├── 2023_12_24_23_59_10_00000.HEIC   (La foto original)
    │   └── 2023_12_24_23_59_50_00000.HEIC   (La edición)
    └── 01
        └── 2023_01_01_00_00_01_00000.PNG
```

## 🔧 Detalles Técnicos

  * **Detección de Archivos:** El script busca recursivamente en todas las subcarpetas (`find . -type f`), por lo que no importa si tienes 5 o 50 carpetas dentro de `DCIM`.
  * **Fecha de Modificación:** Se basa en la fecha de modificación del archivo (`stat -c %y`). En el caso de iPhone montado en Linux/Mac, esto suele corresponderse fielmente con la fecha de captura.
  * **Manejo de Rutas:** Si indicas una ruta de destino externa (ej. un disco duro USB), el script optimiza la búsqueda para ir más rápido y no verificar exclusiones innecesarias.

## ⚠️ Nota sobre el espacio

Este proceso **DUPLICA** los archivos (del iPhone al PC/Disco).

1.  Asegúrate de tener espacio suficiente en el destino.
2.  Una vez verifiques que la carpeta `Backup_iPhone_2024` tiene todas tus fotos ordenadas y correctas, ya puedes proceder a borrar las fotos del iPhone manualmente si deseas liberar espacio.

-----

*Script optimizado para fototecas grandes y desordenadas.*
