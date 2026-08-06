#!/usr/bin/env bash

TMP_VIEW="/tmp/arch_store_view_$$"

# puedes poner el mensaje de salida que quieras
limpiar_salida() {
    
    rm -f "$TMP_VIEW"
    
    # Mensaje de despedida
    echo -e "\n\033[1;32m[✓] Archivos temporales limpiados. ¡Archstaluego!\033[0m"
    sleep 1
    clear
}

trap limpiar_salida EXIT


# Función para comprobar e instalar dependencias faltantes
comprobar_dependencias() {
    local faltantes=()

    # Detectar qué comandos no están instalados
    for cmd in fzf paru pacman; do
        if ! command -v "$cmd" &> /dev/null; then
            faltantes+=("$cmd")
        fi
    done

    # Si no falta nada, continuamos
    if [ ${#faltantes[@]} -eq 0 ]; then
        return 0
    fi

    echo -e "\033[1;33m[!] Faltan las siguientes herramientas requeridas:\033[0m ${faltantes[*]}"
    read -rp "¿Deseas intentarlo instalar automáticamente? (s/N): " instalar_auto

    if [[ "$instalar_auto" =~ ^[Ss]$ ]]; then
        for cmd in "${faltantes[@]}"; do
            echo -e "\n\033[1;34m==> Instalando $cmd...\033[0m"
            case "$cmd" in
                pacman|fzf)
                    sudo pacman -S --needed --noconfirm "$cmd"
                    ;;
                paru)
                    # 1. Asegurar dependencias de compilación
                    echo "Instalando dependencias necesarias (base-devel, git, rust)..."
                    sudo pacman -S --needed base-devel git

                    # 2. Crear directorio temporal y clonar
                    tmp_dir=$(mktemp -d)
                    git clone https://aur.archlinux.org/paru.git "$tmp_dir"
                    
                    # 3. Entrar al directorio y compilar de forma interactiva
                    pushd "$tmp_dir" >/dev/null || exit 1
                    makepkg -si
                    popd >/dev/null || exit 1

                    # 4. Limpiar temporal
                    rm -rf "$tmp_dir"
                    ;;
            esac
        done
        
        # Verificar si realmente se instaló
        if command -v paru &> /dev/null; then
            echo -e "\n\033[1;32m[✓] ¡Todas las herramientas se han instalado correctamente!\033[0m"
            sleep 2
        else
            echo -e "\n\033[1;31m[X] Ocurrió un error al compilar/instalar paru.\033[0m"
            exit 1
        fi
    else
        echo -e "\n\033[1;31mNo se instalaron las dependencias.\033[0m Puedes instalarlas manualmente con los siguientes comandos:\n"
        for cmd in "${faltantes[@]}"; do
            case "$cmd" in
                pacman|fzf)
                    echo -e "  \033[1msudo pacman -S $cmd\033[0m"
                    ;;
                paru)
                    echo -e "  \033[1msudo pacman -S --needed base-devel git\033[0m"
                    echo -e "  \033[1mgit clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si\033[0m"
                    ;;
            esac
        done
        echo ""
        exit 1
    fi
}

comprobar_dependencias

# Función para desbloquear pacman si hubo un error previo
comprobar_bloqueo() {
    if [ -f /var/lib/pacman/db.lck ]; then
        clear
        echo -e "\033[1m¡ATENCIÓN!\033[0m La base de datos de Pacman está bloqueada."
        echo "Esto suele pasar si una instalación anterior se interrumpió."
        read -p "¿Quieres desbloquearla ahora? (s/n): " desbloquear
        if [[ "$desbloquear" =~ ^[Ss]$ ]]; then
            sudo rm /var/lib/pacman/db.lck
            echo "Desbloqueada con éxito."
            sleep 1
        else
            exit 1
        fi
    fi
}

buscar_e_instalar() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== BUSCAR EN REPOSITORIOS Y AUR ===\033[0m"
    echo "Escribe el nombre del paquete. Presiona Enter vacío para volver."
    echo "----------------------------------------------------"
    
    read -p "Término de búsqueda: " busqueda
    
    if [ -n "$busqueda" ]; then
        seleccion=$(paru -Ssq "$busqueda" | fzf \
            --prompt="Instalar  " \
            --height=80% \
            --layout=reverse \
            --border=rounded \
            --preview="paru -Si {}" \
            --preview-window=right:60%:wrap)

        if [ -n "$seleccion" ]; then
            clear
            echo -e "\033[1mInstalando:\033[0m $seleccion"
            paru -S "$seleccion"
            read -p "Presiona Enter para volver al menú..."
        fi
    fi
}

ver_y_remover() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== TUS APLICACIONES INSTALADAS (REMOVER) ===\033[0m"
    echo "----------------------------------------------------"
    
    seleccion=$(pacman -Qqe | fzf \
        --prompt="Remover  " \
        --height=80% \
        --layout=reverse \
        --border=rounded \
        --color="prompt:red,border:red" \
        --preview="pacman -Qi {}" \
        --preview-window=right:60%:wrap)

    if [ -n "$seleccion" ]; then
        clear
        echo -e "\033[1m¡ATENCIÓN! Vas a desinstalar:\033[0m $seleccion"
        read -p "¿Confirmas la eliminación segura (-Rns)? (s/n): " confirmar
        if [[ "$confirmar" =~ ^[Ss]$ ]]; then
            sudo pacman -Rns "$seleccion"
            read -p "Presiona Enter para volver al menú..."
        fi
    fi
}

explorar_paquetes() {
    clear
    echo -e "\033[1m=== EXPLORAR PAQUETES INSTALADOS ===\033[0m"
    echo "Selecciona una categoría:"
    echo "----------------------------------------------------"
    
    tipo=$(printf "1.  Paquetes Oficiales (Repositorios)\n2. 󰣇 Paquetes de AUR\n3. 󰈆 Volver al Menú" | fzf \
        --prompt="Categoría  " \
        --height=9 \
        --layout=reverse \
        --border=rounded)
        
    case "$tipo" in
        *"Oficiales"*)
            pacman -Qn | awk '{print $1}' | fzf \
                --prompt="Oficiales  " \
                --height=80% \
                --layout=reverse \
                --border=rounded \
                --preview="pacman -Qi {}" \
                --preview-window=right:60%:wrap
            read -p "Presiona Enter para continuar..."
            explorar_paquetes
            ;;
        *"AUR"*)
            echo "info" > /tmp/arch_store_view
            
            preview_cmd='bash -c '\''
                mode=$(cat /tmp/arch_store_view 2>/dev/null || echo "info")
                if [ "$mode" = "pkgbuild" ]; then
                    paru -Gp {} 2>/dev/null || echo "No se pudo cargar el PKGBUILD"
                else
                    pacman -Qi {}
                fi
            '\'''

            bind_cmd='ctrl-k:execute-silent(bash -c '\''
                if [ "$(cat /tmp/arch_store_view 2>/dev/null)" = "pkgbuild" ]; then
                    echo "info" > /tmp/arch_store_view
                else
                    echo "pkgbuild" > /tmp/arch_store_view
                fi
            '\'')+refresh-preview'
            
            pacman -Qm | awk '{print $1}' | fzf \
                --prompt="AUR  " \
                --height=80% \
                --layout=reverse \
                --border=rounded \
                --header="[Ctrl+K] Alternar Info / PKGBUILD" \
                --preview="$preview_cmd" \
                --preview-window=right:65%:wrap \
                --bind="$bind_cmd"
            read -p "Presiona Enter para continuar..."
            explorar_paquetes
            ;;
        *)
            return
            ;;
    esac
}

actualizar_sistema() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== ACTUALIZANDO ARCH LINUX ===\033[0m"
    echo "----------------------------------------------------"
    paru -Syu
    read -p "Proceso finalizado. Presiona Enter para volver..."
}

limpiar_sistema() {
    comprobar_bloqueo
    clear
    echo -e "\033[1m=== LIMPIEZA DE SISTEMA ===\033[0m"
    echo "----------------------------------------------------"
    
    echo "1. Limpiando archivos temporales residuales..."
    sudo rm -f /var/cache/pacman/pkg/download-* 2>/dev/null
    
    echo "2. Limpiando caché (Repos y AUR)..."
    sudo pacman -Sc --noconfirm
    yes | paru -Sc >/dev/null 2>&1
    
    echo -e "\n3. Buscando paquetes huérfanos..."
    huerfanos=$(pacman -Qdtq)
    
    if [ -n "$huerfanos" ]; then
        echo -e "\033[1mSe encontraron estos paquetes huérfanos:\033[0m"
        echo "$huerfanos"
        echo ""
        read -p "¿Deseas eliminarlos para liberar espacio? (s/n): " confirmar
        if [[ "$confirmar" =~ ^[Ss]$ ]]; then
            sudo pacman -Rns $huerfanos
            echo "Huérfanos eliminados."
        else
            echo "Huérfanos conservados."
        fi
    else
        echo "Tu sistema está limpio. No hay paquetes huérfanos."
    fi
    
    echo -e "\n¡Mantenimiento completado!"
    read -p "Presiona Enter para volver..."
}

while true; do
    clear
    echo -e "\033[1m\033[36m"
    cat << 'EOF'
    _             _       _     _                  
   / \   _ __ ___| |__   | |   (_)_ __  _   ___  __ 
  / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ / 
 / ___ \| | | (__| | | | | |___| | | | | |_| |>  <  
/_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\ 
EOF

echo -e "\033[0m"
    echo -e "\033[1m\033[35m   ╭───────────────────────────────────╮\033[0m"
    echo -e "\033[1m\033[35m   │     ADMINISTRADOR DE PAQUETES     │\033[0m"
    echo -e "\033[1m\033[35m   ╰───────────────────────────────────╯\033[0m"
    echo ""
    
    opcion=$(printf "1. 󰏖 Buscar e Instalar\n2. 󰛌 Ver Instalados y Remover\n3. 󰮯 Explorar Paquetes Instalados\n4. 󰚰 Actualizar Sistema\n5. 󰃢 Limpiar Sistema\n6. 󰈆 Salir" | fzf \
        --prompt="Selecciona una acción  " \
        --height=15 \
        --layout=reverse \
        --border=rounded)

    case "$opcion" in
        *"Buscar e Instalar"*) buscar_e_instalar ;;
        *"Ver Instalados y Remover"*) ver_y_remover ;;
        *"Explorar Paquetes Instalados"*) explorar_paquetes ;;
        *"Actualizar Sistema"*) actualizar_sistema ;;
        *"Limpiar Sistema"*) limpiar_sistema ;;
        *"Salir"*|"") clear; exit 0 ;;
    esac
done
