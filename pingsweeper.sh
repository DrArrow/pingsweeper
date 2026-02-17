#!/bin/bash

# ================= COLORS =================
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"
BLUE="\e[34m"; CYAN="\e[36m"; RESET="\e[0m"; BOLD="\e[1m"

PROTOCOL="icmp"
TCP_PORTS=(22 80 443)
UDP_PORTS=(53 123)

# ================= BANNER =================
banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ____  _             _____                                     "
    echo " |  _ \(_)           / ____|                                    "
    echo " | |_) |_ _ __   ___| (_____      _____  ___ _ __   ___ _ __   "
    echo " |  __/| | '_ \ / _ \\___ \ \ /\ / / _ \/ _ \ '_ \ / _ \ '__|  "
    echo " | |   | | | | |  __/____) \ V  V /  __/  __/ |_) |  __/ |     "
    echo " |_|   |_|_| |_|\___|_____/ \_/\_/ \___|\___| .__/ \___|_|     "
    echo "                                              | |              "
    echo "                                              |_|              "
    echo "        Ping Sweeper (Native Linux Edition)"
    echo -e "${RESET}"
}

# ================= USAGE =================
usage() {
    echo -e "${YELLOW}${BOLD}Usage:${RESET}"
    echo "  ping_sweeper.sh -p <icmp|tcp|udp|arp> <start-ip> <end-ip>"
    echo
    echo -e "${YELLOW}${BOLD}Examples:${RESET}"
    echo "  ./ping_sweeper.sh -p icmp 192.168.1.1 .254"
    echo "  ./ping_sweeper.sh -p tcp  192.168.1.1 .254"
    echo "  ./ping_sweeper.sh -p udp  192.168.1.1 .254"
    echo "  sudo ./ping_sweeper.sh -p arp 192.168.1.1 .254"
    echo
    echo "  -h, --help     Show help"
    exit 0
}

# ================= ARG PARSING =================
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        -p|--protocol) PROTOCOL="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option"; usage ;;
    esac
done

[ $# -ne 2 ] && usage

START_IP="$1"
END_INPUT="$2"

# ================= HELPERS =================
expand_end_ip() {
    IFS='.' read -r s1 s2 s3 s4 <<< "$1"
    IFS='.' read -r e1 e2 e3 <<< "${2#.}"
    case $(echo "$2" | tr -cd '.' | wc -c) in
        1) echo "$s1.$s2.$s3.$e1" ;;
        2) echo "$s1.$s2.$e1.$e2" ;;
        3) echo "$s1.$e1.$e2.$e3" ;;
        *) echo "$2" ;;
    esac
}

ip_to_int() {
    IFS='.' read -r a b c d <<< "$1"
    echo $((a<<24 | b<<16 | c<<8 | d))
}

int_to_ip() {
    echo "$((($1>>24)&255)).$((($1>>16)&255)).$((($1>>8)&255)).$(( $1&255 ))"
}

[[ "$END_INPUT" == .* ]] && END_IP=$(expand_end_ip "$START_IP" "$END_INPUT") || END_IP="$END_INPUT"

START_INT=$(ip_to_int "$START_IP")
END_INT=$(ip_to_int "$END_IP")

banner
echo -e "${BLUE}Protocol:${RESET} ${BOLD}$PROTOCOL${RESET}"
echo -e "${BLUE}Range:${RESET} ${BOLD}$START_IP → $END_IP${RESET}"
echo

# ================= SCANS =================
for ((ip=START_INT; ip<=END_INT; ip++)); do
    TARGET=$(int_to_ip "$ip")

    case "$PROTOCOL" in

    icmp)
        ping -c 1 -W 1 "$TARGET" &>/dev/null && \
        echo -e "${GREEN}[ICMP] Alive:${RESET} $TARGET" &
        ;;

    tcp)
        for port in "${TCP_PORTS[@]}"; do
            nc -z -w1 "$TARGET" "$port" &>/dev/null && {
                echo -e "${GREEN}[TCP] Alive:${RESET} $TARGET (port $port)"
                break
            }
        done &
        ;;

    udp)
        for port in "${UDP_PORTS[@]}"; do
            echo "" | nc -u -w1 "$TARGET" "$port" &>/dev/null && {
                echo -e "${GREEN}[UDP] Possible alive:${RESET} $TARGET"
                break
            }
        done &
        ;;

    arp)
        ping -c 1 -W 1 "$TARGET" &>/dev/null
        MAC=$(ip neigh show "$TARGET" | awk '{print $5}')
        if [[ -n "$MAC" ]]; then
            VENDOR=$(grep -i "${MAC:0:8}" /usr/share/ieee-data/oui.txt 2>/dev/null | head -1 | cut -d$'\t' -f3-)
            echo -e "${GREEN}[ARP]${RESET} $TARGET  ${CYAN}$MAC${RESET}  ${YELLOW}${VENDOR:-Unknown}${RESET}"
        fi
        ;;

    *)
        echo "Invalid protocol"
        exit 1
        ;;
    esac
done

wait
echo
echo -e "${CYAN}${BOLD}Scan completed.${RESET}"
