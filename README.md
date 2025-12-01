# 📂 Organizador Maestro de Archivos (Bash Script)

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![System](https://img.shields.io/badge/System-Linux%20%7C%20macOS%20%7C%20WSL-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

Un script de automatización de alto nivel diseñado para poner orden en el caos digital. Escanea cualquier origen, clasifica los archivos por **Categoría**, **Extensión** y **Fecha**, y genera una copia exacta y organizada preservando todos los metadatos originales.

## 🚀 Características Premium

### 1. Clasificación Profunda (Deep Sorting)
El script no solo ordena por fecha. Crea una jerarquía lógica inteligente:
* **Nivel 1:** Categoría (Imágenes, Documentos, Vídeos, Certificados...).
* **Nivel 2:** Extensión Específica (JPG, PNG, PDF, DOCX...).
* **Nivel 3:** Cronología (Año / Mes).

### 2. Seguridad y Auditoría
* **Sistema de Logs:** Genera dos archivos al finalizar (`registro_exito.csv` y `registro_errores.txt`) para que puedas auditar cada byte copiado.
* **Preservación de Metadatos:** Utiliza `cp -p` para mantener intactas la fecha de modificación original, permisos y propietario.
* **Gestión de Colisiones:** Nunca sobrescribe. Si dos archivos se llaman igual y tienen la misma fecha, usa contadores inteligentes (`_00001`).

### 3. Interfaz Robusta
* **Selección de Origen/Destino:** Te solicita explícitamente dónde buscar y dónde guardar.
* **Protección Anti-Bucle:** Detecta si intentas guardar la copia dentro de la carpeta original y aísla el destino para evitar bucles infinitos.
* **Barra de Progreso Visual:** Indicador en tiempo real limpio y estable.

---

## 📋 Categorías Soportadas

El script reconoce automáticamente cientos de extensiones y las agrupa:

| Categoría | Ejemplos de Extensiones |
| :--- | :--- |
| **📄 Documentos** | pdf, docx, xlsx, pptx, txt, md, pages, numbers... |
| **📷 Imágenes** | jpg, png, heic, raw, neff, cr2, svg, psd, ai... |
| **🎥 Vídeos** | mp4, mov, avi, mkv, webm, 3gp... |
| **🎵 Sonidos** | mp3, wav, flac, aac, ogg, mid... |
| **📦 Comprimidos** | zip, rar, 7z, tar.gz, iso, dmg... |
| **🔐 Certificados** | p12, pfx, pem, crt, key... |
| **🗂️ Varios** | Cualquier otro archivo no reconocido. |

---

## 🛠️ Instalación y Uso

1.  **Descarga** el script (ej. `organizador_maestro.sh`).
2.  **Dale permisos** de ejecución:
    ```bash
    chmod +x organizador_maestro.sh
    ```
3.  **Ejecuta**:
    ```bash
    ./organizador_maestro.sh
    ```
4.  **Sigue las instrucciones en pantalla:**
    * Introduce la ruta de Origen (puedes arrastrar la carpeta a la terminal).
    * Introduce la ruta de Destino.

---

## 🌲 Ejemplo de Estructura Final

Así se verán tus archivos después de ejecutar el script:

```text
/Mi_Disco_Duro/Archivos_Organizados
├── Documentos
│   ├── PDF
│   │   └── 2023
│   │       └── 05
│   │           └── 2023_05_12_factura.pdf
│   └── DOCX
│       └── 2023 ...
├── Imágenes
│   ├── HEIC
│   │   └── 2022
│   │       └── 08
│   │           └── 2022_08_15_vacaciones.heic
│   └── JPG
│       └── ...
└── Vídeos
    └── MP4
        └── 2024
            └── 01
                └── 2024_01_01_fiesta.mp4
````

-----

## 🔍 Auditoría de Logs

Al finalizar, revisa la carpeta de destino:

  * **`registro_exito.csv`**: Un listado detallado (abrible en Excel) con:
      * Ruta Original -\> Ruta Nueva -\> Fecha
  * **`registro_errores.txt`**: Si algún archivo falló (por permisos o corrupción), aparecerá aquí. Si este archivo está vacío (o solo tiene la cabecera), **la copia fue perfecta**.

-----

## ⚠️ Nota Importante

Este script **COPIA** los archivos.

  * **Ventaja:** Tus archivos originales permanecen 100% seguros e intactos.
  * **Requisito:** Asegúrate de tener espacio suficiente en el disco de destino para duplicar la información. Una vez verifiques los logs, puedes borrar el origen manualmente.

-----

*Desarrollado para máxima eficiencia y tranquilidad digital.*