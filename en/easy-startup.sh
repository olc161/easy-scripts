#!/bin/bash

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
ICON_RUN="🚀"
ICON_FLAT="📦"

msg() {
  case "$1" in
    info)  echo -e "${C_INFO}${ICON_INFO}  $2${C_RESET}" ;;
    ok)    echo -e "${C_SUCCESS}${ICON_OK}  $2${C_RESET}" ;;
    err)   echo -e "${C_ERROR}${ICON_ERR}  $2${C_RESET}" ;;
    warn)  echo -e "${C_WARN}${ICON_WARN}  $2${C_RESET}" ;;
    title) echo -e "\n${C_TITLE}=== $2 ===${C_RESET}" ;;
    *) echo "$2" ;;
  esac
}

# ===========================
# Native Programme (Commands)
# ===========================
NATIVE_PROGRAMS=(
  code-insiders
  thunderbird
  sublime-text
)

# ===========================
# Flatpak Programme (Application IDs!)
# ===========================
FLATPAK_PROGRAMS=(
  com.bitwarden.desktop
  org.signal.Signal
)

# ===========================
# Native Programme starten
# ===========================
msg title "Starte native Programme"

for PROG in "${NATIVE_PROGRAMS[@]}"; do
  if command -v "$PROG" &>/dev/null; then
    msg info "Starte $PROG"
    "$PROG" & disown
    msg ok "$PROG gestartet"
  else
    msg err "Nicht gefunden: $PROG"
  fi
done

# ===========================
# Flatpak Programme starten
# ===========================
msg title "Starte Flatpak Programme"

if ! command -v flatpak &>/dev/null; then
  msg err "Flatpak ist nicht installiert."
  exit 1
fi

for APP in "${FLATPAK_PROGRAMS[@]}"; do
  if flatpak info "$APP" &>/dev/null; then
    msg info "${ICON_FLAT} Starte $APP"
    flatpak run "$APP" & disown
    msg ok "$APP gestartet"
  else
    msg warn "Flatpak-App nicht installiert: $APP"
  fi
done

msg title "Alle Programme gestartet"
