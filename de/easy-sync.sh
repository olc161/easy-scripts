#!/bin/bash
clear
# ===========================
# Farben & Symbole
# ===========================
C_RESET="\033[0m"
C_INFO="\033[0;36m"
C_SUCCESS="\033[0;32m"
C_ERROR="\033[0;31m"
C_WARN="\033[0;33m"
C_TITLE="\033[1;37m"

ICON_INFO="ℹ️"
ICON_OK="✅"
ICON_ERR="❌"
ICON_WARN="⚠️"
ICON_FILE="📂"
ICON_UPLOAD="📤"
ICON_DOWNLOAD="📥"
ICON_SYNC="🔁"
ICON_SERVER="🖥️"

msg() {
  case "$1" in
    info) echo -e "${C_INFO}${ICON_INFO}  $2${C_RESET}" ;;
    ok) echo -e "${C_SUCCESS}${ICON_OK}  $2${C_RESET}" ;;
    err) echo -e "${C_ERROR}${ICON_ERR}  $2${C_RESET}" ;;
    warn) echo -e "${C_WARN}${ICON_WARN}  $2${C_RESET}" ;;
    title) echo -e "\n${C_TITLE}=== $2 ===${C_RESET}" ;;
    *) echo "$2" ;;
  esac
}

# ===========================
# Funktionen
# ===========================

download_from_server() {
  clear
  msg title "Download vom Server"
  read -p "${ICON_SERVER} Server (user@host): " SERVER
  read -e -p "${ICON_FILE} Remote Pfad (z.B. /path/on/server/): " REMOTE_PATH
  read -e -p "${ICON_FILE} Lokaler Zielordner: " LOCAL_PATH

  rsync -avz --progress "$SERVER:$REMOTE_PATH" "$LOCAL_PATH"
  if [ $? -eq 0 ]; then
    msg ok "Download erfolgreich abgeschlossen."
  else
    msg err "Fehler beim Download."
  fi
}

upload_to_server() {
  clear
  msg title "Upload zum Server"
  read -p "${ICON_SERVER} Server (user@host): " SERVER
  read -e -p "${ICON_FILE} Lokaler Pfad (z.B. ./folder/): " LOCAL_PATH
  read -e -p "${ICON_FILE} Zielpfad auf Server: " REMOTE_PATH

  rsync -avz --progress "$LOCAL_PATH" "$SERVER:$REMOTE_PATH"
  if [ $? -eq 0 ]; then
    msg ok "Upload erfolgreich abgeschlossen."
  else
    msg err "Fehler beim Upload."
  fi
}

sync_bidirectional() {
  clear
  msg title "Bidirektionaler Sync"
  read -p "${ICON_SERVER} Server (user@host): " SERVER
  read -e -p "${ICON_FILE} Lokaler Pfad: " LOCAL_PATH
  read -e -p "${ICON_FILE} Remote Pfad auf Server: " REMOTE_PATH

  msg info "Synchronisiere vom Server zum lokalen System..."
  rsync -avz --progress "$SERVER:$REMOTE_PATH" "$LOCAL_PATH"

  msg info "Synchronisiere vom lokalen System zum Server..."
  rsync -avz --progress "$LOCAL_PATH" "$SERVER:$REMOTE_PATH"

  msg ok "Bidirektionaler Sync abgeschlossen."
}

dry_run_sync() {
  clear
  msg title "Trockenlauf (Dry Run)"
  read -p "${ICON_SERVER} Server (user@host): " SERVER
  read -e -p "${ICON_FILE} Lokaler Pfad: " LOCAL_PATH
  read -e -p "${ICON_FILE} Remote Pfad auf Server: " REMOTE_PATH

  rsync -avzn --progress "$LOCAL_PATH" "$SERVER:$REMOTE_PATH"
  msg info "Dies war nur ein Testlauf – keine Daten wurden übertragen."
}

# ===========================
# Hauptmenü
# ===========================
while true; do
  msg title "Rsync Management Menü"
  echo "1) ${ICON_DOWNLOAD} Vom Server herunterladen"
  echo "2) ${ICON_UPLOAD} Auf Server hochladen"
  echo "3) ${ICON_SYNC} Bidirektionaler Sync (beide Richtungen)"
  echo "4) 🧪 Trockenlauf (Dry Run)"
  echo "0) 🚪 Beenden"

  read -p "Auswahl: " CHOICE

  case $CHOICE in
    1) download_from_server ;;
    2) upload_to_server ;;
    3) sync_bidirectional ;;
    4) dry_run_sync ;;
    0) msg info "Beende Rsync-Manager. Tschüss!"; exit 0 ;;
    *) msg err "Ungültige Auswahl!" ;;
  esac
done
