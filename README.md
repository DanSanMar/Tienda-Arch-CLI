# Tienda-Arch-CLI
Un gestor de paquetes interactivo para Arch Linux. Busca, instala y elimina paquetes de los repositorios oficiales y AUR usando fzf y paru.

<img width="1920" height="1080" alt="imagen" src="https://github.com/user-attachments/assets/73b10137-5a34-44e2-9cb9-d00096dccd8e" />



## ✨ Características

* 🔍 **Búsqueda e Instalación Rápida:** Busca simultáneamente en los repositorios oficiales y en AUR. Incluye previsualización en tiempo real de la información del paquete.
* 🗑️ **Gestión Segura:** Visualiza tus aplicaciones instaladas explícitamente y elimínalas de forma segura junto con sus dependencias (`pacman -Rns`).
* 📦 **Explorador Avanzado de Paquetes:** 
  * Filtra entre paquetes Oficiales y de AUR.
  * **[Ctrl + K]**: Alterna al instante entre la información del paquete (`pacman -Qi`) y la lectura del código fuente o `PKGBUILD` (`paru -Gp`).
* 🔄 **Actualización Global:** Con un solo enter, actualiza todo tu sistema (repositorios oficiales y AUR) al mismo tiempo mediante `paru -Syu`.
* 🧹 **Mantenimiento y Limpieza:** Libera espacio eliminando caché antigua, archivos residuales y detectando paquetes huérfanos.
* 🛡️ **Prevención de Errores:** Detecta automáticamente si la base de datos de pacman está bloqueada (`db.lck`) y te ofrece desbloquearla de forma segura.




 
 
 
 
 
 🚀 Instalación y Uso

1. Clona este repositorio:
Bash

git clone [https://github.com/ArchPure/Tienda-Arch-CLI.git](https://github.com/ArchPure/Tienda-Arch-CLI.git)
cd Tienda-Arch-CLI

2. Otorga permisos de ejecución al script:
Bash

chmod +x tienda.sh

3. Ejecución directa:
Puedes usar el script estando dentro de la carpeta clonada:
Bash

./tienda.sh

🌟 Ejecución Global (Recomendado)

Si quieres poder abrir la tienda desde cualquier emulador de terminal simplemente escribiendo la palabra store, sigue estos pasos para añadir el script a tu PATH:

    Crea el directorio de binarios locales (si no existe):
    Bash

    mkdir -p ~/.local/bin

    Copia el script a esa ruta con el nuevo nombre:
    Bash

    cp tienda.sh ~/.local/bin/store

    Asegúrate de que la ruta esté en tu PATH. Añade la siguiente línea al final de tu archivo ~/.bashrc o ~/.zshrc (dependiendo de la shell que uses):
    Bash

    export PATH="$HOME/.local/bin:$PATH"

    Aplica los cambios:
    Bash

    source ~/.bashrc  # o source ~/.zshrc

¡Listo! Ahora solo tienes que escribir store y presionar Enter para lanzar la interfaz al instante.




## Requisitos del Sistema

Para que la interfaz y las funciones operen correctamente, necesitas tener instalado lo siguiente:
```bash
sudo pacman -S bash fzf pacman


# AUR Helper (paru): El script utiliza paru como motor principal para gestionar AUR. Si no lo tienes, instálalo:

sudo pacman -S --needed base-devel
git clone [https://aur.archlinux.org/paru.git](https://aur.archlinux.org/paru.git)
cd paru
makepkg -si


Nota:

Fuentes (Opcional pero recomendado): El menú utiliza íconos de Nerd Fonts. Para que se visualicen correctamente, asegúrate de usar una tipografía parcheada (como JetBrainsMono Nerd Font, Hack Nerd Font, etc.) en tu emulador de terminal.
