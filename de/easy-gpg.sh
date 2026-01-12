#!/bin/bash

clear
# ===========================
# Colors & Symbols
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
# Actions
# ===========================
generate_key() {
  clear
  msg info "Starting GPG Key creation..."
  gpg --full-generate-key
}

list_public_keys() {
  clear
  msg title "Public Key"
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
  msg title "Private Key"
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
  read -p "Enter Key-ID: " KEYID
  read -e -p "Filename for export (for example key.asc): " FILE
  gpg --armor --export "$KEYID" > "$FILE"
  msg ok "Exported key to ${ICON_FILE} $FILE"
}

export_private_key() {
  read -p "Enter Key-ID: " KEYID
  read -e -p "Filename for export (for example privkey.gpg): " FILE
  gpg --armor --export-secret-keys "$KEYID" > "$FILE"
  msg ok "Private Key exportet to ${ICON_FILE} $FILE"
}

import_key() {
  clear
  read -e -p "Path to key file: " FILE
  gpg --import "$FILE"
  msg ok "Key Importet."
}

delete_key() {
  read -p "Enter Key-ID: " KEYID
  gpg --delete-secret-and-public-keys "$KEYID"
  msg warn "Key $KEYID deleted."
}

edit_key() {
  read -p "Enter Key-ID: " KEYID
  gpg --edit-key "$KEYID"
}

encrypt_file() {
  clear
  read -e -p "Encrypt file/folder: " FILE
  read -p "Recipient (Email or Key-ID): " RECIPIENT
  read -e -p "Output-file (for example file.gpg): " OUT
  gpgtar --encrypt --output "$OUT" --recipient "$RECIPIENT" "$FILE"
  msg ok "File encrypted → ${ICON_FILE} $OUT"
}

encrypt_file_symmetric() {
  clear
  read -e -p "File to encrypt: " FILE
  read -e -p "Output-file (for example file.gpg): " OUT
  gpg --symmetric --cipher-algo AES256 --output "$OUT" "$FILE"
  msg ok "File symmetrically encrypted → ${ICON_FILE} $OUT"
}

decrypt_file() {
  clear
  read -e -p "File to decrypt: " FILE
  read -e -p "Output-file (z.B. out.txt): " OUT
  gpg --output "$OUT" --decrypt "$FILE"
  msg ok "file decrypted → ${ICON_FILE} $OUT"
}

# ===========================
# Hauptmenü
# ===========================
while true; do
  msg title "GPG Management Menu"
  echo "1) ${ICON_KEY} Create new Key"
  echo "2) ${ICON_KEY} Show Public Keys"
  echo "3) ${ICON_KEY} Show Private Keys"
  echo "4) ${ICON_FILE} Export Keys"
  echo "5) ${ICON_FILE} Export Private Keys"
  echo "6) ${ICON_FILE} Import Key"
  echo "7) ${ICON_WARN} Delete Key"
  echo "8) ${ICON_KEY} Edit Key"
  echo "9) 🔒 Encrypt file/folder (Recipient)"
  echo "10) 🔑 Datei symmetrisch verschlüsseln"
  echo "11) 🔓 Decrypt file"
  echo "0) 🚪 exit"

  read -p "choice: " CHOICE

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
    0) msg info "Ending Script."; exit 0 ;;
    *) msg err "Invalid selection!" ;;
  esac
done
