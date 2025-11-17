#!/bin/bash

# ===========================
# REMOTE CONTROL PROJECT SCRIPT
# STUDENT NAME: Tomer Deri
# STUDENT CODE: s5
# PROGRAM CODE: nx201
# UNIT CODE: TMagen773637
# LECTURER NAME: EREL REGEV
# ===========================

# ===== Colors =====
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

info() { echo -e "${YELLOW}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# ===== Banner =====
banner() {
echo -e "${BLUE}"
echo "███╗   ███╗ █████╗  ███████╗███████╗███╗   ██╗"
echo "████╗ ████║██╔══██╗ ██╔════╝██╔════╝████╗  ██║"
echo "██╔████╔██║███████║ █████╗  █████╗  ██╔██╗ ██║"
echo "██║╚██╔╝██║██╔══██║ ██╔══╝  ██╔══╝  ██║╚██╗██║"
echo "██║ ╚═╝ ██║██║  ██║ ███████╗███████╗██║ ╚████║"
echo "╚═╝     ╚═╝╚═╝  ╚═╝ ╚══════╝╚══════╝╚═╝  ╚═══╝"
echo -e "${RESET}"
echo -e "${YELLOW}Project: Remote Control Automation Tool${RESET}"
echo ""
}

# ===== Create output directory =====
mkdir -p output
LOG_FILE="output/audit_log_$(date +%Y%m%d_%H%M%S).txt"

# ===== Install Required Tools =====
install_tools() {
    info "Checking and installing required tools..."
    packages=(nmap whois sshpass git curl)
    for pkg in "${packages[@]}"; do
        if ! command -v $pkg &>/dev/null; then
            info "Installing $pkg..."
            sudo apt-get install -y $pkg
        else
            success "$pkg already installed."
        fi
    done

    # Install cpan and Perl modules if needed
    if ! command -v cpan &>/dev/null; then
        info "Installing cpan..."
        sudo apt-get install -y cpanminus
    fi
}

# ===== Install and Setup Nipe =====
install_nipe() {
    if [ ! -d nipe ]; then
        info "Cloning Nipe repository..."
        git clone https://github.com/htrgouvea/nipe.git
        cd nipe
        sudo cpan install Try::Tiny Config::Simple JSON
        sudo perl nipe.pl install
        cd ..
    else
        success "Nipe already exists."
    fi
}

# ===== Start Nipe and Check Anonymity =====
check_anonymity() {
    cd nipe
    sudo perl nipe.pl start
    sudo perl nipe.pl restart
    sleep 5

    tor_status=$(curl -s https://check.torproject.org | grep -o "Congratulations. This browser is configured to use Tor")

    if [[ "$tor_status" != "" ]]; then
        country=$(curl -s https://ipinfo.io/country 2>/dev/null)
        if [[ "$country" == *"<html>"* ]]; then
            country="Unknown (Blocked by ipinfo.io)"
        fi
        success "You are now anonymous. Spoofed country: $country"
    else
        error "Anonymity check failed. You are NOT using Tor."
        exit 1
    fi
    cd ..
}

# ===== Connect and Execute Commands on Remote Server =====
remote_operations() {
    echo ""
    read -p "Enter remote server IP: " server_ip
    read -p "Enter remote username: " user
    read -s -p "Enter remote password: " password
    echo ""
    read -p "Enter target address to scan: " target

    timestamp=$(date +%Y%m%d_%H%M%S)

    info "Connecting to remote server and executing commands..."
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no $user@$server_ip << EOF
        echo "[REMOTE] Server Uptime:"
        uptime
        echo "[REMOTE] Server Country:"
        curl -s ipinfo.io/country

        echo "[REMOTE] Performing WHOIS lookup on $target..."
        whois $target > whois_$target.txt

        echo "[REMOTE] Performing Nmap scan on $target..."
        nmap -Pn $target -oN nmap_$target.txt
EOF

    info "Downloading result files from remote server..."
    sshpass -p "$password" scp $user@$server_ip:whois_$target.txt output/whois_$target_$timestamp.txt
    sshpass -p "$password" scp $user@$server_ip:nmap_$target.txt output/nmap_$target_$timestamp.txt

    success "Files downloaded to output/"

    # Logging
    {
        echo "==================== AUDIT LOG ===================="
        echo "Scan Timestamp: $(date)"
        echo "Target: $target"
        echo "Remote Server IP: $server_ip"
        echo "Spoofed Country: $country"
        echo "Remote Results:"
        echo "- Whois: whois_$target_$timestamp.txt"
        echo "- Nmap:  nmap_$target_$timestamp.txt"
        echo "==================================================="
    } >> "$LOG_FILE"

    success "Audit log created: $LOG_FILE"
}

# ===== MAIN =====
clear
banner
install_tools
install_nipe
check_anonymity
remote_operations
