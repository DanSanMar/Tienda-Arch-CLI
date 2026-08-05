# Tienda-Arch-CLI
Un gestor de paquetes interactivo para Arch Linux. Busca, instala y elimina paquetes de los repositorios oficiales y AUR usando fzf y paru.

<img width="1920" height="1080" alt="imagen" src="https://github.com/user-attachments/assets/73b10137-5a34-44e2-9cb9-d00096dccd8e" />


## Requisitos del Sistema

Para que la interfaz y las funciones operen correctamente, necesitas tener instalado lo siguiente:
   ```bash
   sudo pacman -S bash fzf pacman


## AUR Helper (paru): El script utiliza paru como motor principal para gestionar AUR. Si no lo tienes, instálalo:

sudo pacman -S --needed base-devel
git clone [https://aur.archlinux.org/paru.git](https://aur.archlinux.org/paru.git)
cd paru
makepkg -si


Nota:
Fuentes (Opcional pero recomendado): El menú utiliza íconos de Nerd Fonts. Para que se visualicen correctamente, asegúrate de usar una tipografía parcheada (como JetBrainsMono Nerd Font, Hack Nerd Font, etc.) en tu emulador de terminal.
