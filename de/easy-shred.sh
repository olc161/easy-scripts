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
ICON_TRASH="🗑️"
ICON_BURN="🔥"

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

get_shred_options() {
  msg title "Wähle Shred-Optionen"
  echo "Wähle, wie oft du die Datei überschreiben möchtest:"
  read -p "Wie oft überschreiben (z. B. 3): " NUM_OVERWRITES

  echo "Wähle die Shred-Optionen aus:"
  echo "1) ${ICON_BURN} -z (Datei nach dem Löschen mit Nullen überschreiben)"
  echo "2) ${ICON_BURN} -u (Datei löschen, nachdem sie überschrieben wurde)"
  echo "3) ${ICON_BURN} -v (Verlauf während des Shred-Vorgangs anzeigen)"
  echo "4) ${ICON_BURN} Keine (keine zusätzliche Option)"

  read -p "Optionen (z.B. -zv): " OPTIONS

  # Standardmäßig keine Optionen, wenn nichts angegeben wird
  [ -z "$OPTIONS" ] && OPTIONS=""

  echo -e "\nAusgewählte Optionen: -$OPTIONS"
  echo -e "Anzahl der Überschreibungen: $NUM_OVERWRITES\n"

  SHRED_CMD="-$OPTIONS"
}

shred_file() {
  clear
  msg title "Sicheres Löschen einer Datei"
  read -e -p "${ICON_FILE} Datei zum Löschen: " FILE
  if [ ! -f "$FILE" ]; then
    msg err "Datei $FILE existiert nicht."
    return
  fi

  get_shred_options

  read -p "${ICON_BURN} Willst du die Datei wirklich löschen? (y/n): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    shred $SHRED_CMD -n "$NUM_OVERWRITES" "$FILE"
    if [ $? -eq 0 ]; then
      msg ok "Datei erfolgreich gelöscht."
    else
      msg err "Fehler beim Löschen der Datei."
    fi
  else
    msg warn "Löschen abgebrochen."
  fi
}

shred_directory() {
  clear
  msg title "Sicheres Löschen eines Ordners"
  read -e -p "${ICON_FILE} Ordner zum Löschen: " DIR
  if [ ! -d "$DIR" ]; then
    msg err "Ordner $DIR existiert nicht."
    return
  fi

  get_shred_options

  read -p "${ICON_BURN} Willst du den Ordner wirklich löschen? (y/n): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    find "$DIR" -type f -exec shred $SHRED_CMD -n "$NUM_OVERWRITES" {} \;
    if [ $? -eq 0 ]; then
      rm -rf "$DIR"
      msg ok "Ordner und Dateien erfolgreich gelöscht."
    else
      msg err "Fehler beim Löschen des Ordners."
    fi
  else
    msg warn "Löschen abgebrochen."
  fi
}

wipe_free_space() {
  clear
  msg title "Freien Speicher löschen"
  read -e -p "${ICON_FILE} Pfad zum Verzeichnis (z.B. /home/user): " DIR

  if [ ! -d "$DIR" ]; then
    msg err "Verzeichnis $DIR existiert nicht."
    return
  fi

  read -p "${ICON_BURN} Alle freien Bereiche im angegebenen Verzeichnis löschen? (y/n): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    # Schreibe zufällige Daten auf den freien Speicherplatz und lösche sie anschließend
    dd if=/dev/urandom of="$DIR/secure_wipe_test_file" bs=1M count=100 &>/dev/null
    rm -f "$DIR/secure_wipe_test_file"
    msg ok "Freier Speicher erfolgreich überschrieben."
  else
    msg warn "Löschen abgebrochen."
  fi
}

# ===========================
# Hauptmenü
# ===========================
while true; do
  msg title "Shred-Manager Menü"
  echo "1) ${ICON_BURN} Datei sicher löschen"
  echo "2) ${ICON_BURN} Ordner sicher löschen"
  echo "3) ${ICON_BURN} Freien Speicher überschreiben"
  echo "0) 🚪 Beenden"

  read -p "Auswahl: " CHOICE

  case $CHOICE in
    1) shred_file ;;
    2) shred_directory ;;
    3) wipe_free_space ;;
    0) msg info "Beende Shred-Manager. Tschüss!"; exit 0 ;;
    *) msg err "Ungültige Auswahl!" ;;
  esac
done
