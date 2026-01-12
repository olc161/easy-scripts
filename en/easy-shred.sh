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
# Functions
# ===========================

get_shred_options() {
  msg title "Select Shred-Option"
  echo "Choose how many times you want to overwrite the file:"
  read -p "How many times to overwrite (e.g. 3): " NUM_OVERWRITES

  echo "Select Shred-Option:"
  echo "1) ${ICON_BURN} -z (Overwrite file with zeros after deletion)"
  echo "2) ${ICON_BURN} -u (Delete the file after it has been overwritten.)"
  echo "3) ${ICON_BURN} -v (Show progress during the shred process)"
  echo "4) ${ICON_BURN} None (no additional option)"

  read -p "Options (e.g. -zuv): " OPTIONS

  # No options are available by default if nothing is specified
  [ -z "$OPTIONS" ] && OPTIONS=""

  echo -e "\nSelected options: -$OPTIONS"
  echo -e "Number of overwrites: $NUM_OVERWRITES\n"

  SHRED_CMD="-$OPTIONS"
}

shred_file() {
  clear
  msg title "Securely delete a file"
  read -e -p "${ICON_FILE} File to delete: " FILE
  if [ ! -f "$FILE" ]; then
    msg err "File $FILE does not exist."
    return
  fi

  get_shred_options

  read -p "${ICON_BURN} Do you really want to delete the file? (y/n): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    shred $SHRED_CMD -n "$NUM_OVERWRITES" "$FILE"
    if [ $? -eq 0 ]; then
      msg ok "File successfully deleted."
    else
      msg err "Error deleting file."
    fi
  else
    msg warn "Delete cancelled."
  fi
}

shred_directory() {
  clear
  msg title "Securely delete a folder"
  read -e -p "${ICON_FILE} Folder to delete: " DIR
  if [ ! -d "$DIR" ]; then
    msg err "Folder $DIR does not exist."
    return
  fi

  get_shred_options

  read -p "${ICON_BURN} Do you really want to delete the file? (y/n): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    find "$DIR" -type f -exec shred $SHRED_CMD -n "$NUM_OVERWRITES" {} \;
    if [ $? -eq 0 ]; then
      rm -rf "$DIR"
      msg ok "Folder and Files successfully deleted."
    else
      msg err "Error while deleting folder."
    fi
  else
    msg warn "Delete cancelled."
  fi
}

wipe_free_space() {
  clear
  msg title "Delete free space"
  read -e -p "${ICON_FILE} Path to directory (e.g. /home/user): " DIR

  if [ ! -d "$DIR" ]; then
    msg err "directory $DIR does not exist."
    return
  fi

  read -p "${ICON_BURN} Delete all free space in the specified directory? (y/n): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    # Write random data to the free storage space and then delete it
    dd if=/dev/urandom of="$DIR/secure_wipe_test_file" bs=1M count=100 &>/dev/null
    rm -f "$DIR/secure_wipe_test_file"
    msg ok "Free space successfully overwritten."
  else
    msg warn "Delete cancelled."
  fi
}

# ===========================
# Main Menu
# ===========================
while true; do
  msg title "Shred-Manager Menu"
  echo "1) ${ICON_BURN} Securely delete file"
  echo "2) ${ICON_BURN} Securely delete folder"
  echo "3) ${ICON_BURN} wipe free space"
  echo "0) 🚪 exit"

  read -p "Choice: " CHOICE

  case $CHOICE in
    1) shred_file ;;
    2) shred_directory ;;
    3) wipe_free_space ;;
    0) msg info "Exit Shred-Manager. Bye!"; exit 0 ;;
    *) msg err "Invalid selection!" ;;
  esac
done
