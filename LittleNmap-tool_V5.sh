#!/bin/bash

# --- CONFIGURACIÓN DE COLORES ---
R='\033[0;31m'
V='\033[0;32m'
A='\033[1;33m'
M='\033[0;35m'
CYAN='\033[0;36m'
G='\033[0;37m'
W='\033[1;37m'
NC='\033[0m'

# --- FUNCIONES EXTRA ---
pausa(){
    echo -e "\n${A}Pulsa ENTER para continuar...${NC}"
    read
}

explicar(){
    echo -e "\n${CYAN}📖 EXPLICACIÓN:${NC}"
    echo -e "${G}$1${NC}"
}

mostrar_comando(){
    echo -e "${M}[*] Comando:${NC} $1"
}

confirmar(){
    echo -e "\n${A}¿Ejecutar comando? (s/n):${NC}"
    read conf
    [[ "$conf" != "s" ]] && return 1
    return 0
}

# --- FUNCIÓN DE BANNER ---
dibujar_banner() {
    clear
    echo -e "${G}  ░▒▓████████████████████████████████████████████████████████████▓▒░${NC}"
    echo -e "${M}   _     _ _   _   _                _   _                         ${NC}"
    echo -e "${M}  | |   (_) |_| |_| | ___          | \ | |_ __ ___   __ _ _ __    ${NC}"
    echo -e "${M}  | |   | | __| __| |/ _ \  _____  |  \| | '_ ' _ \ / _' | '_ \   ${NC}"
    echo -e "${M}  | |___| | |_| |_| |  __/ |_____| | |\  | | | | | | (_| | |_) |  ${NC}"
    echo -e "${M}  |_____|_|\__|\__|_|\___|         |_| \_|_| |_| |_|\__,_| .__/   ${NC}"
    echo -e "${M}                                                         |_|      ${NC}"
    echo -e "${M}                          T  O  O  L                              ${NC}"
    
    local kernel_val=$(uname -r | cut -d'-' -f1)
    local user_val=$(whoami)
    local ip_val=$(hostname -I | awk '{print $1}')
    [[ -z "$ip_val" ]] && ip_val="Offline"
    local os_val="Kali"

    local raw_info=" KERNEL: ${kernel_val} │ USER: ${user_val} │ IP: ${ip_val} │ OS: ${os_val} "
    local len=${#raw_info}

    echo -ne "  ${CYAN}┏"
    printf '%.0s━' $(seq 1 $len)
    echo -e "┓${NC}"
    echo -e "  ${CYAN}┃${NC}${W} KERNEL:${NC} ${kernel_val} ${G}│${NC} ${W}USER:${NC} ${V}${user_val}${NC} ${G}│${NC} ${W}IP:${NC} ${A}${ip_val}${NC} ${G}│${NC} ${W}OS:${NC} ${os_val} ${CYAN}┃${NC}"
    echo -ne "  ${CYAN}┗"
    printf '%.0s━' $(seq 1 $len)
    echo -e "┛${NC}"
}

# --- FUNCIÓN TARGET ---
get_target() {
    echo -e "\n ${A}» Introduce la IP o URL objetivo:${NC}"
    read -r TARGET
    if [ -z "$TARGET" ]; then
        echo -e " ${R}[!] El objetivo no puede estar vacío.${NC}"
        sleep 2
        return 1
    fi
    OUTPUT_DIR="nmap_$TARGET"
    mkdir -p "$OUTPUT_DIR"
    return 0
}

# --- BUCLE PRINCIPAL ---
while true; do
    dibujar_banner
    
    echo -e "\n  ${G}${CYAN}┌───────────────── 🛠  OPCIONES DE LITTLE NMAP TOOL 🛠 ──────────────────┐${NC}"
    echo -e "      ${V}[01]${NC} ${W}ESCANEO RÁPIDO${NC}               ${G}▶${NC}          ${A}nmap -sC -sV -T4${NC}"
    echo -e "      ${V}[02]${NC} ${W}PUERTOS ESPECÍFICOS${NC}          ${G}▶${NC}          ${A}nmap -p <puertos>${NC}"
    echo -e "      ${V}[03]${NC} ${W}ESCANEO COMPLETO${NC}             ${G}▶${NC}          ${A}nmap -p- -T4${NC}"
    echo -e "      ${V}[04]${NC} ${W}DETECCIÓN VULNS${NC}              ${G}▶${NC}          ${A}nmap --script vuln${NC}"
    echo -e "      ${V}[05]${NC} ${W}AUDITORÍA DE RED${NC}             ${G}▶${NC}          ${A}nmap -sn <red>${NC}"
    echo -e "      ${V}[06]${NC} ${W}ESC. PERSONALIZADO${NC}           ${G}▶${NC}          ${A}nmap [flags]${NC}"
    echo -e "      ${R}[07]${NC} ${W}CREDENCIALES${NC}                 ${G}▶${NC}          ${A}info del script${NC}"
    echo -e "      ${R}[08]${NC} ${W}SALIR${NC}                        ${G}▶${NC}          ${A}exit${NC}"
    echo -e "  ${G}${CYAN}└──────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -ne " ${M}LMT_COMMANDER:${NC}${W}# ${NC}"
    read opcion

    case $opcion in
        01|1)
            get_target && { 
                explicar "-sC scripts básicos | -sV versiones | -T4 rápido"
                mostrar_comando "nmap -sC -sV -T4 $TARGET"
                confirmar && sudo nmap -sC -sV -T4 "$TARGET" -oN "$OUTPUT_DIR/quick.txt"
                pausa
            }
            ;;
        02|2)
            get_target && {
                echo -e "${A}» Puertos:${NC}"
                read -r PORTS
                explicar "-p puertos específicos"
                mostrar_comando "nmap -p $PORTS -sC -sV $TARGET"
                confirmar && sudo nmap -p "$PORTS" -sC -sV "$TARGET" -oN "$OUTPUT_DIR/specific.txt"
                pausa
            }
            ;;
        03|3)
            get_target && {
                explicar "-p- todos los puertos"
                mostrar_comando "nmap -p- -T4 $TARGET"
                confirmar && sudo nmap -p- -T4 -v "$TARGET" -oN "$OUTPUT_DIR/full_ports.txt"
                pausa
            }
            ;;
        04|4)
            get_target && {
                explicar "--script vuln busca vulnerabilidades"
                mostrar_comando "nmap -sV --script vuln $TARGET"
                confirmar && sudo nmap -sV --script vuln "$TARGET" -oN "$OUTPUT_DIR/vulns.txt"
                pausa
            }
            ;;
        05|5)
            echo -e "${A}» Rango de red:${NC}"
            read -r RANGE
            explicar "-sn detecta hosts activos"
            mostrar_comando "nmap -sn $RANGE"
            confirmar && sudo nmap -sn "$RANGE" -oN "network_discovery.txt"
            pausa
            ;;
        06|6)
            get_target && {
                T="" ; P="" ; SPEED="4"
                echo -e "\n${V}1. SELECCIONA LA TÉCNICA DE ESCANEO:${NC}"
                echo -e "   ${G}[1] SYN Scan (-sS)${NC} -> ${W}Rápido y sigiloso (no completa conexión).${NC}"
                echo -e "   ${G}[2] TCP Connect (-sT)${NC} -> ${W}Más ruidoso, completa el handshake.${NC}"
                echo -e "   ${G}[3] UDP Scan (-sU)${NC} -> ${W}Para DNS, DHCP, etc. (Muy lento).${NC}"
                echo -ne " ${M}Selección [1-3]:${NC} "
                read -r TEC
                case "$TEC" in
                    1) T="-sS" ; DESC="SYN Stealth Scan" ;;
                    2) T="-sT" ; DESC="TCP Connect Scan" ;;
                    3) T="-sU" ; DESC="UDP Scan" ;;
                    *) T="-sS" ; DESC="SYN Stealth Scan (por defecto)" ;;
                esac

                echo -e "\n${V}2. AGRESIVIDAD (VELOCIDAD):${NC}"
                echo -e "   ${W}T0-T2: Lento (evadir IDS) | T4: Recomendado | T5: Insano (puede fallar).${NC}"
                echo -ne " ${M}Velocidad (0-5) [4]:${NC} "
                read -r SPEED
                [[ ! "$SPEED" =~ ^[0-5]$ ]] && SPEED="4"

                echo -e "\n${V}3. ¿SALTAR PING? (-Pn):${NC}"
                echo -e "   ${W}Útil si el objetivo bloquea el ICMP (ping) pero está activo.${NC}"
                echo -ne " ${M}¿Activar -Pn? (s/n):${NC} "
                read -r SKIP
                [[ "$SKIP" == "s" || "$SKIP" == "S" ]] && P="-Pn" || P=""

                echo -e "\n${A}--------------------------------------------------${NC}"
                echo -e "${W}RESUMEN DEL ESCANEO PERSONALIZADO:${NC}"
                echo -e "${G}Técnica:${NC} $DESC ($T)"
                echo -e "${G}Velocidad:${NC} T$SPEED"
                echo -e "${G}Omitir Ping:${NC} ${P:-No}"
                mostrar_comando "nmap $T -T$SPEED $P $TARGET"
                echo -e "${A}--------------------------------------------------${NC}"

                confirmar && sudo nmap $T -T$SPEED $P "$TARGET" -oN "$OUTPUT_DIR/custom_scan.txt"
                pausa
            }
            ;;
        07|7)
            clear
            echo -e "${MAGENTA}"
            echo -e "  ██╗      ███╗   ██╗████████╗"
            echo -e "  ██║      ████╗  ██║╚══██╔══╝"
            echo -e "  ██║      ██╔██╗ ██║   ██║   "
            echo -e "  ██║      ██║╚██╗██║   ██║   "
            echo -e "  ███████╗ ██║ ╚████║   ██║   "
            echo -e "  ╚══════╝ ╚═╝  ╚═══╝   ╚═╝   "
            echo -e "${NC}"

            echo -e "  ${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
            echo -e "  ${CYAN}┃${NC} ${BLANCO}>> INFO DEL DESARROLLADOR${NC}                                     ${CYAN}┃${NC}"
            echo -e "  ${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
            echo -e ""
            echo -e "  ${BLANCO}AUTOR:     ${MAGENTA}@Ismael.1509${NC}"
            echo -e "  ${BLANCO}VERSIÓN:   ${VERDE}5.7.0 Pro Edition${NC}"
            echo -e "  ${BLANCO}ACADEMIA:  ${AMARILLO}IFPS Puenteuropa - SMR1${NC}"
            echo -e "  ${BLANCO}AÑO:       ${CYAN}2025/2026${NC}"
            echo -e ""
            echo -e "  ${CYAN}Este script ha sido diseñado para auditorias de laboratorios de la clase.${NC}"
            echo -e ""
            read -p "  Presione Enter para volver..."
            ;;
        08|8)
            echo -e "\n${B}────────────────────────────────────────────────────────────${NC}"
            echo -e " ${V}👋 Little nmap-Tool v5 finalizada con éxito.${NC}"
            echo -e " ${W}¡Buen trabajo, $USUARIO!${NC}"
            echo -e "${B}────────────────────────────────────────────────────────────${NC}"
            sleep 1.2
            exit 0
            ;;
        *)
            echo -e "${R}Opción no válida.${NC}"
            sleep 1
            ;;
    esac
done
