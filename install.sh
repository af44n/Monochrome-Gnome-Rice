#!/usr/bin/env bash
# =============================================================
#  monochrome gnome rice – setup script
#  Installs the Dark BS GTK theme, YAMIS monochrome icons,
#  Bibata cursor, GNOME Tweaks, User Themes extension,
#  fish shell, OMF + agnoster, GNOME extensions, Flatpak theming,
#  and sets the monochromatic wallpaper automatically.
# =============================================================

set -eo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${GREEN}[rice]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC} $*"; }
step() { echo -e "${CYAN}::${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Bibata cursor install helper ──────────────────────────────
install_bibata_from_github() {
    local dest_tmp
    dest_tmp=$(mktemp -d)

    info "Fetching Bibata cursor release info from GitHub API..."
    local api_url="https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest"
    local download_url
    download_url=$(curl -sfL "$api_url" \
        | grep '"browser_download_url"' \
        | grep 'Bibata-Modern-Ice\.tar\.xz' \
        | grep -v 'Right' \
        | head -1 \
        | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')

    if [ -z "$download_url" ]; then
        warn "Could not resolve Bibata download URL from GitHub API. Trying fallback URL..."
        download_url="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.6/Bibata-Modern-Ice.tar.xz"
    fi

    info "Downloading Bibata cursor from: $download_url"
    local tarball="$dest_tmp/Bibata-Modern-Ice.tar.xz"
    if ! curl -L --fail --retry 3 --retry-delay 2 -o "$tarball" "$download_url"; then
        warn "Download failed. Install manually: https://github.com/ful1e5/Bibata_Cursor/releases/latest"
        rm -rf "$dest_tmp"
        return 1
    fi

    if ! file "$tarball" | grep -qiE 'XZ compressed|xz compressed'; then
        warn "Downloaded file is not a valid .tar.xz archive (got: $(file "$tarball"))."
        warn "Install manually: https://github.com/ful1e5/Bibata_Cursor/releases/latest"
        rm -rf "$dest_tmp"
        return 1
    fi

    info "Extracting Bibata cursor..."
    tar -xf "$tarball" -C "$dest_tmp"
    mkdir -p "$HOME/.local/share/icons" "$HOME/.icons"
    cp -r "$dest_tmp/Bibata-Modern-Ice" "$HOME/.local/share/icons/"
    cp -r "$dest_tmp/Bibata-Modern-Ice" "$HOME/.icons/"
    rm -rf "$dest_tmp"
    info "Bibata-Modern-Ice cursor installed."
}

# ── sudo shim ────────────────────────────────────────────────
if command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

# ── detect distro ────────────────────────────────────────────
if command -v pacman &>/dev/null; then
    DISTRO="arch"
elif command -v apt &>/dev/null; then
    DISTRO="debian"
elif command -v dnf &>/dev/null; then
    DISTRO="fedora"
elif command -v zypper &>/dev/null; then
    DISTRO="opensuse"
else
    warn "Could not detect distro. You may need to install dependencies manually."
    DISTRO="unknown"
fi

info "Detected distro family: $DISTRO"

# ── install dependencies ──────────────────────────────────────
info "Installing dependencies..."

case "$DISTRO" in
    arch)
        $SUDO pacman -Sy --needed --noconfirm \
            sassc gnome-themes-extra gnome-tweaks gnome-shell-extensions \
            fish git curl unzip ttf-jetbrains-mono python-pipx

        if command -v yay &>/dev/null; then
            yay -S --needed --noconfirm gtk-engine-murrine
        elif command -v paru &>/dev/null; then
            paru -S --needed --noconfirm gtk-engine-murrine
        else
            warn "gtk-engine-murrine is AUR-only. Install it with: yay -S gtk-engine-murrine"
        fi

        $SUDO pacman -R --noconfirm illogical-impulse-bibata-modern-classic-bin 2>/dev/null || true
        if command -v paru &>/dev/null; then
            paru -S --noconfirm bibata-cursor-theme-bin
        elif command -v yay &>/dev/null; then
            yay -S --noconfirm bibata-cursor-theme-bin
        fi
        ;;
    debian)
        $SUDO apt update
        $SUDO apt install -y \
            sassc gtk2-engines-murrine gnome-themes-extra gnome-tweaks \
            gnome-shell-extensions fish git curl unzip fonts-jetbrains-mono \
            python3-pip pipx
        if $SUDO apt install -y bibata-cursor-theme 2>/dev/null; then
            info "Bibata cursor installed via apt."
        fi
        ;;
    fedora)
        $SUDO dnf install -y \
            sassc gtk-murrine-engine gnome-themes-extra gnome-tweaks \
            gnome-shell-extension-user-theme fish git curl unzip jetbrains-mono-fonts \
            pipx
        $SUDO dnf copr enable -y peterwu/rendezvous 2>/dev/null || true
        $SUDO dnf install -y bibata-cursor-themes 2>/dev/null || true
        ;;
    opensuse)
        $SUDO zypper install -y \
            sassc gtk2-engine-murrine gnome-themes-extra gnome-tweaks \
            fish git curl unzip jetbrains-mono python3-pipx
        ;;
    *)
        warn "Skipping auto-install. Install manually: sassc, gtk-engine-murrine, gnome-themes-extra, gnome-tweaks, gnome-shell-extensions, fish, git, pipx"
        ;;
esac

# ── create target directories ────────────────────────────────
mkdir -p "$HOME/.themes"
mkdir -p "$HOME/.icons"
mkdir -p "$HOME/.local/share/themes"
mkdir -p "$HOME/.local/share/icons"
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/Pictures/Wallpapers"

# ── Dark BS Theme ─────────────────────────────────────────────
info "Installing Dark BS theme..."
THEME_NAME="dark-bs"

if [ -d "$SCRIPT_DIR/themes/$THEME_NAME" ]; then
    rm -rf "$HOME/.themes/$THEME_NAME" "$HOME/.local/share/themes/$THEME_NAME"
    cp -rf "$SCRIPT_DIR/themes/$THEME_NAME" "$HOME/.themes/"
    cp -rf "$SCRIPT_DIR/themes/$THEME_NAME" "$HOME/.local/share/themes/" 2>/dev/null || true
    info "Dark BS theme copied to ~/.themes and ~/.local/share/themes"
else
    warn "Theme directory not found in repository ($SCRIPT_DIR/themes/$THEME_NAME)"
fi

# ── GTK 3 & GTK 4 / Libadwaita overrides ──────────────────────
info "Applying GTK 3.0 and GTK 4.0 configuration..."
if [ -d "$SCRIPT_DIR/config/gtk-3.0" ]; then
    rm -rf "$HOME/.config/gtk-3.0/assets" "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk-dark.css" "$HOME/.config/gtk-3.0/thumbnail.png"
    cp -rf "$SCRIPT_DIR/config/gtk-3.0/"* "$HOME/.config/gtk-3.0/"
fi

if [ -d "$SCRIPT_DIR/config/gtk-4.0" ]; then
    rm -rf "$HOME/.config/gtk-4.0/assets" "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/thumbnail.png"
    cp -rf "$SCRIPT_DIR/config/gtk-4.0/"* "$HOME/.config/gtk-4.0/"
fi

# Apply dark-mode preferences and GTK theme via gsettings
info "Configuring GNOME theme settings..."
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || warn "Could not set GTK theme."

# ── Icon Pack (YAMIS) ─────────────────────────────────────────
info "Installing YAMIS icon theme..."
ICON_THEME="YAMIS"

if [ -d "$SCRIPT_DIR/icons/$ICON_THEME" ]; then
    rm -rf "$HOME/.icons/$ICON_THEME" "$HOME/.local/share/icons/$ICON_THEME"
    cp -rf "$SCRIPT_DIR/icons/$ICON_THEME" "$HOME/.icons/"
    cp -rf "$SCRIPT_DIR/icons/$ICON_THEME" "$HOME/.local/share/icons/"
    info "YAMIS icons copied to ~/.icons and ~/.local/share/icons"
else
    warn "Icon directory not found in repository ($SCRIPT_DIR/icons/$ICON_THEME)"
fi

gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null || warn "Could not set icon theme."

# ── Cursor Theme (Bibata-Modern-Ice) ──────────────────────────
info "Installing Bibata Modern Ice cursor..."
CURSOR_NAME="Bibata-Modern-Ice"

if [ -d "$SCRIPT_DIR/cursors/$CURSOR_NAME" ]; then
    rm -rf "$HOME/.icons/$CURSOR_NAME" "$HOME/.local/share/icons/$CURSOR_NAME"
    cp -rf "$SCRIPT_DIR/cursors/$CURSOR_NAME" "$HOME/.icons/"
    cp -rf "$SCRIPT_DIR/cursors/$CURSOR_NAME" "$HOME/.local/share/icons/"
    info "Bibata-Modern-Ice cursor copied from repository."
elif [ ! -d "$HOME/.icons/$CURSOR_NAME" ] && [ ! -d "/usr/share/icons/$CURSOR_NAME" ]; then
    install_bibata_from_github || true
fi

gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_NAME" 2>/dev/null || warn "Could not set cursor theme."

# ── Font ──────────────────────────────────────────────────────
info "Setting default interface font..."
gsettings set org.gnome.desktop.interface font-name "JetBrains Mono 11" 2>/dev/null \
    || warn "Could not set font. Make sure JetBrains Mono is installed."

# ── Wallpaper ─────────────────────────────────────────────────
info "Setting monochrome wallpaper..."
WALLPAPER_DEST="$HOME/Pictures/Wallpapers/monochrome-background.png"

if [ -f "$SCRIPT_DIR/wallpapers/background.png" ]; then
    cp "$SCRIPT_DIR/wallpapers/background.png" "$WALLPAPER_DEST"
    cp "$SCRIPT_DIR/wallpapers/background.png" "$HOME/.config/background" 2>/dev/null || true

    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_DEST" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_DEST" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-options "zoom" 2>/dev/null || true
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALLPAPER_DEST" 2>/dev/null || true
    info "Monochrome wallpaper set: $WALLPAPER_DEST"
else
    warn "Wallpaper file not found in $SCRIPT_DIR/wallpapers/background.png"
fi

# ── GNOME extensions ──────────────────────────────────────────
info "Installing and configuring GNOME extensions..."
export PATH="$HOME/.local/bin:$PATH"

if ! command -v gext &>/dev/null; then
    pipx install gnome-extensions-cli --system-site-packages 2>/dev/null \
        || pip3 install --user gnome-extensions-cli 2>/dev/null \
        || true
fi

# Enable user extensions globally
gsettings set org.gnome.shell disable-user-extensions false 2>/dev/null || true

declare -A EXTENSIONS=(
    ["user-theme@gnome-shell-extensions.gcampax.github.com"]="19"
    ["blur-my-shell@aunetx"]="3193"
    ["caffeine@patapon.info"]="517"
    ["clipboard-indicator@tudmotu.com"]="779"
    ["dash-to-dock@micxgx.gmail.com"]="307"
    ["just-perfection-desktop@just-perfection"]="3843"
    ["logomenu@aryan_k"]="4451"
    ["space-bar@luchrioh"]="5090"
    ["top-bar-organizer@julian.gse.jsts.xyz"]="4356"
    ["tophat@fflewddur.github.io"]="5219"
)

install_extension() {
    local uuid="$1"
    local ext_id="$2"

    info "  → Installing: $uuid (ID: $ext_id)"

    # 1. Try gext in filesystem mode (avoids DBus prompt hangs/failures)
    if command -v gext &>/dev/null; then
        if gext -F install "$uuid" 2>/dev/null || gext -F install "$ext_id" 2>/dev/null; then
            command -v gnome-extensions &>/dev/null && gnome-extensions enable "$uuid" 2>/dev/null || true
            return 0
        fi
    fi

    # 2. Direct fallback via extensions.gnome.org API
    local api_resp
    api_resp=$(curl -sfL "https://extensions.gnome.org/extension-info/?pk=$ext_id" 2>/dev/null || true)
    if [ -n "$api_resp" ]; then
        local download_tag
        download_tag=$(python3 -c "
import json
try:
    data = json.loads('''$api_resp''')
    versions = data.get('shell_version_map', {})
    if versions:
        print(list(versions.values())[-1].get('pk'))
except Exception:
    pass
" 2>/dev/null || true)

        if [ -n "$download_tag" ]; then
            local tmp_zip
            tmp_zip=$(mktemp --suffix=.zip)
            if curl -sfL "https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${download_tag}" -o "$tmp_zip"; then
                local ext_dest="$HOME/.local/share/gnome-shell/extensions/$uuid"
                mkdir -p "$ext_dest"
                unzip -qo "$tmp_zip" -d "$ext_dest" 2>/dev/null || true
                if [ -d "$ext_dest/schemas" ] && command -v glib-compile-schemas &>/dev/null; then
                    glib-compile-schemas "$ext_dest/schemas" 2>/dev/null || true
                fi
                rm -f "$tmp_zip"
                command -v gnome-extensions &>/dev/null && gnome-extensions enable "$uuid" 2>/dev/null || true
                return 0
            fi
            rm -f "$tmp_zip"
        fi
    fi

    warn "    Could not auto-install $uuid — visit https://extensions.gnome.org/extension/$ext_id/"
    return 1
}

ENABLED_UUIDS=""
for UUID in "${!EXTENSIONS[@]}"; do
    EXT_ID="${EXTENSIONS[$UUID]}"
    install_extension "$UUID" "$EXT_ID" || true
    ENABLED_UUIDS="${ENABLED_UUIDS:+$ENABLED_UUIDS, }'$UUID'"
done

# Enable all extensions in one gsettings call
gsettings set org.gnome.shell enabled-extensions "[$ENABLED_UUIDS]" 2>/dev/null \
    || warn "Could not set enabled-extensions via gsettings."

info "All extensions installed and queued — they will activate after logout/login."

# Queue the shell theme (user-theme extension must be active)
gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME" 2>/dev/null || true
info "Shell theme queued: $THEME_NAME"

# ── Flatpak theming ───────────────────────────────────────────
if command -v flatpak &>/dev/null; then
    info "Applying Flatpak theme overrides..."
    $SUDO flatpak override --filesystem="$HOME/.themes" 2>/dev/null || true
    $SUDO flatpak override --filesystem="$HOME/.icons" 2>/dev/null || true
    flatpak override --user --filesystem="$HOME/.themes" 2>/dev/null || true
    flatpak override --user --filesystem="$HOME/.icons" 2>/dev/null || true
    flatpak override --user --filesystem=xdg-config/gtk-3.0 2>/dev/null || true
    flatpak override --user --filesystem=xdg-config/gtk-4.0 2>/dev/null || true
fi

# ── Fish shell ────────────────────────────────────────────────
if command -v fish &>/dev/null; then
    info "Setting fish as default shell..."
    FISH_PATH=$(command -v fish)
    if ! grep -qF "$FISH_PATH" /etc/shells 2>/dev/null; then
        echo "$FISH_PATH" | $SUDO tee -a /etc/shells > /dev/null
    fi
    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7 2>/dev/null || echo "$SHELL")
    if [ "$CURRENT_SHELL" = "$FISH_PATH" ]; then
        info "fish is already the default shell."
    else
        chsh -s "$FISH_PATH" || warn "Could not set fish as default shell. Run: chsh -s $FISH_PATH"
    fi
fi

# ── Oh My Fish + agnoster theme ───────────────────────────────
if command -v fish &>/dev/null; then
    info "Installing Oh My Fish and agnoster theme..."
    curl -sL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o /tmp/omf-install

    fish -c "
        source /tmp/omf-install --noninteractive --yes
        omf install agnoster
        omf theme agnoster
    " 2>/dev/null || warn "OMF auto-install had issues. In fish, run:
        curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
        omf install agnoster"

    rm -f /tmp/omf-install
fi

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Monochrome GNOME Rice setup complete :D           ${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo ""
echo "  Remaining steps:"
echo "  1. Log out and back in (required for extensions + shell theme + fish to take effect)"
echo "  2. Open GNOME Tweaks → Appearance to verify Dark BS theme, YAMIS icons, and Bibata cursor"
echo "  3. Configure individual extensions via GNOME Extensions app"
echo ""
echo "  Applied Theme Details:"
echo "    • GTK & Shell Theme : Dark BS (Monochrome)"
echo "    • Icons             : YAMIS"
echo "    • Cursor            : Bibata-Modern-Ice"
echo "    • Font              : JetBrains Mono"
echo "    • GTK 3/4 & Libadwaita styling overrides applied"
echo "    • Flatpak overrides applied"
echo ""
echo "  Enjoy your clean monochrome rice! 🖤"
