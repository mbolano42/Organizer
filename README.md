# 📂 Organizador Inteligente de Archivos (Bash Script)

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20WSL-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

Un script de automatización avanzado diseñado para organizar masivamente fotografías, vídeos y documentos. Transforma directorios caóticos (como las carpetas `DCIM` de un iPhone o copias de seguridad antiguas) en una estructura cronológica limpia y estandarizada, **preservando siempre la integridad y metadatos de los archivos originales**.

---

## 🚀 Características Principales

### 1. Interfaz Interactiva "Origen vs. Destino"
A diferencia de scripts simples que solo ordenan la carpeta actual, este script solicita explícitamente:
* **Origen:** ¿Dónde está el desorden? (Puede ser un USB, disco externo, carpeta local...).
* **Destino:** ¿Dónde quieres guardar los archivos ordenados?

### 2. Preservación Total de Metadatos (`cp -p`)
El script utiliza una copia en modo *preserve*. Esto garantiza que:
* ✅ La **Fecha de Modificación** original se mantiene intacta.
* ✅ Los permisos y el propietario del archivo se respetan.
* ✅ Tus fotos seguirán ordenándose cronológicamente en cualquier visor.

### 3. Renombrado Cronológico Inteligente
Renombra los archivos basándose en su fecha real de creación, no en su nombre original.
* De: `IMG_9021.HEIC` (Nombre genérico)
* A: `2023_12_24_18_30_05_00000.HEIC` (Información útil)

### 4. Gestión de Colisiones (Anti-Duplicados)
Si tienes varias fotos tomadas en el mismo segundo (o ráfagas), el script **nunca sobrescribe**. Añade un contador incremental (`_00000`, `_00001`) para guardar ambas versiones.

### 5. Seguridad Anti-Bucle
El script detecta automáticamente si estás intentando guardar los archivos ordenados *dentro* de la misma carpeta de origen. Si es así, excluye dinámicamente la carpeta de destino del escaneo para evitar bucles infinitos.

---

## 📋 Requisitos

* **Sistema Operativo:** Linux (Ubuntu, Debian, Fedora...), macOS, o Windows a través de WSL (Windows Subsystem for Linux).
* **Dependencias:** Ninguna. Utiliza herramientas nativas de Bash (`find`, `stat`, `cp`, `mkdir`).

---

## 🛠️ Instalación

1.  Descarga el archivo `organizador_pro.sh` o crea uno nuevo con el código.
2.  Otorga permisos de ejecución desde la terminal:

```bash
chmod +x organizador_pro.sh
📖 Guía de Uso
Ejecuta el script. No necesitas pasar parámetros, el asistente te guiará.

Bash

./organizador_pro.sh
Paso a Paso
Solicitud de Origen: El script te pedirá la ruta de la carpeta desordenada.

💡 Tip: Puedes arrastrar la carpeta desde tu escritorio a la terminal para que se escriba la ruta automáticamente.

Solicitud de Destino: Indica dónde quieres crear la nueva estructura organizada.

Procesamiento: Verás una barra de progreso indicando el avance de la copia.

🌲 Ejemplo Visual: Antes y Después
Imagina que quieres organizar las fotos de un iPhone que has copiado a tu PC.

❌ Situación Inicial (El Caos)
Ruta Origen: /media/usb/Backup_Iphone

Plaintext

/media/usb/Backup_Iphone
├── 100APPLE
│   ├── IMG_0001.JPG
│   └── IMG_0002.MOV
├── 101APPLE
│   ├── IMG_0001.JPG  (¡Nombre duplicado en otra carpeta!)
│   └── FOTO_WHATSAPP_2023.JPEG
└── DOCUMENTOS
    └── factura.pdf
✅ Resultado Final (El Orden)
Ruta Destino: /home/usuario/Fotos_Ordenadas

Plaintext

/home/usuario/Fotos_Ordenadas
├── 2022
│   └── 05
│       ├── 2022_05_10_14_00_00_00000.JPG
│       └── 2022_05_10_14_00_00_00001.MOV
├── 2023
│   └── 11
│       ├── 2023_11_20_09_30_00_00000.JPG  (La primera IMG_0001)
│       └── 2023_11_20_09_30_00_00001.JPG  (La segunda IMG_0001, sin colisión)
└── 2024
    └── 01
        └── 2024_01_15_10_00_00_00000.pdf
⚙️ Detalles Técnicos (Cómo funciona por dentro)
Para los usuarios avanzados, esta es la lógica que sigue el script:

Resolución de Rutas: Convierte tanto el origen como el destino a rutas absolutas. Esto es crítico para determinar la relación entre ambas carpetas.

Detección de Jerarquía:

Si Destino empieza por la cadena de texto de Origen, significa que el destino es una subcarpeta.

En este caso, se construye un comando find con la opción -prune para ignorar esa subcarpeta específica durante la búsqueda.

Extracción de Fecha (stat):

Se extrae el mtime (Modification Time). Formato: YYYY-MM-DD HH:MM:SS.

Copia Segura:

Se usa cp -p origen destino. La flag -p preserva: Mode, Ownership, Timestamps.

⚠️ Advertencias y Consejos
Espacio en Disco: Este script COPIA los archivos, no los mueve. Asegúrate de tener suficiente espacio libre en el destino. Una vez verifiques que todo está correcto, puedes borrar el origen manualmente.

Archivos Ocultos: Por defecto, el script busca archivos normales (-type f). No procesa archivos ocultos del sistema (que empiezan por .) a menos que se modifique el comando find.

📄 Licencia
Este proyecto se distribuye bajo la licencia MIT. Eres libre de usarlo, modificarlo y distribuirlo.
