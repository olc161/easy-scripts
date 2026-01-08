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
ICON_KEY="🔑"
ICON_FILE="📂"

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
# Aktionen
# ===========================
generate_key() {
  clear
  msg info "Starte GPG Key Erstellung..."
  gpg --full-generate-key
}

list_public_keys() {
  clear
  msg title "Öffentliche Schlüssel"
  gpg --list-keys --with-colons | awk -F: '
    $1 == "pub" {algo=$4; keyid=$5}
    $1 == "fpr" {fpr=$10}
    $1 == "uid" {
      print "🔑  " fpr " [" algo "]"
      print "    📧  " $10
    }
  '
}

list_private_keys() {
  clear
  msg title "Private Schlüssel"
  gpg --list-secret-keys --with-colons | awk -F: '
    $1 == "sec" {algo=$4; keyid=$5}
    $1 == "fpr" {fpr=$10}
    $1 == "uid" {
      print "🔐  " fpr " [" algo "]"
      print "    📧  " $10
    }
  '
}


export_key() {
  read -p "Key-ID eingeben: " KEYID
  read -e -p "Dateiname für Export (z.B. key.asc): " FILE
  gpg --armor --export "$KEYID" > "$FILE"
  msg ok "Schlüssel exportiert nach ${ICON_FILE} $FILE"
}

export_private_key() {
  read -p "Key-ID eingeben: " KEYID
  read -e -p "Dateiname für Export (z.B. privkey.gpg): " FILE
  gpg --armor --export-secret-keys "$KEYID" > "$FILE"
  msg ok "Privater Schlüssel exportiert nach ${ICON_FILE} $FILE"
}

import_key() {
  clear
  read -e -p "Pfad zur Schlüsseldatei: " FILE
  gpg --import "$FILE"
  msg ok "Schlüssel importiert."
}

delete_key() {
  read -p "Key-ID eingeben: " KEYID
  gpg --delete-secret-and-public-keys "$KEYID"
  msg warn "Schlüssel $KEYID gelöscht."
}

edit_key() {
  read -p "Key-ID eingeben: " KEYID
  gpg --edit-key "$KEYID"
}

encrypt_file() {
  clear
  read -e -p "Datei/Ordner zum Verschlüsseln: " FILE
  read -p "Empfänger (Email oder Key-ID): " RECIPIENT
  read -e -p "Ausgabe-Datei (z.B. file.gpg): " OUT
  gpgtar --encrypt --output "$OUT" --recipient "$RECIPIENT" "$FILE"
  msg ok "Datei erfolgreich verschlüsselt → ${ICON_FILE} $OUT"
}

encrypt_file_symmetric() {
  clear
  read -e -p "Datei zum Verschlüsseln: " FILE
  read -e -p "Ausgabe-Datei (z.B. file.gpg): " OUT
  gpg --symmetric --cipher-algo AES256 --output "$OUT" "$FILE"
  msg ok "Datei symmetrisch verschlüsselt → ${ICON_FILE} $OUT"
}

decrypt_file() {
  clear
  read -e -p "Datei zum Entschlüsseln: " FILE
  read -e -p "Ausgabe-Datei (z.B. out.txt): " OUT
  gpg --output "$OUT" --decrypt "$FILE"
  msg ok "Datei entschlüsselt → ${ICON_FILE} $OUT"
}

# ===========================
# Hauptmenü
# ===========================
while true; do
  msg title "GPG Management Menü"
  echo "1) ${ICON_KEY} Neuen Schlüssel erstellen"
  echo "2) ${ICON_KEY} Öffentliche Schlüssel anzeigen"
  echo "3) ${ICON_KEY} Private Schlüssel anzeigen"
  echo "4) ${ICON_FILE} Schlüssel exportieren"
  echo "5) ${ICON_FILE} Privaten Schlüssel exportieren"
  echo "6) ${ICON_FILE} Schlüssel importieren"
  echo "7) ${ICON_WARN} Schlüssel löschen"
  echo "8) ${ICON_KEY} Schlüssel bearbeiten"
  echo "9) 🔒 Datei/Ordner verschlüsseln (Empfänger)"
  echo "10) 🔑 Datei symmetrisch verschlüsseln"
  echo "11) 🔓 Datei entschlüsseln"
  echo "0) 🚪 Beenden"

  read -p "Auswahl: " CHOICE

  case $CHOICE in
    1) generate_key ;;
    2) list_public_keys ;;
    3) list_private_keys ;;
    4) export_key ;;
    5) export_private_key ;;
    6) import_key ;;
    7) delete_key ;;
    8) edit_key ;;
    9) encrypt_file ;;
    10) encrypt_file_symmetric ;;
    11) decrypt_file ;;
    0) msg info "Beende Script."; exit 0 ;;
    *) msg err "Ungültige Auswahl!" ;;
  esac
done
