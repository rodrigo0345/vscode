#!/bin/zsh

# Define variables
CODE_CONFIG_DIR="$HOME/.config/Code\ ~\ OSS/User"
FONT_DIR="$HOME/.local/share/fonts"
JETBRAINS_NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
TEMP_ZIP="JetBrainsMono.zip"
EXTENSIONS_FILE="vscode_extensions.txt"

if ! command -v code &> /dev/null; then
    # install code if not installed
    echo "Installing VS Code..."
    yay -S code --noconfirm
fi

echo "Installing VS Code extensions from $EXTENSIONS_FILE..."
if [[ -f "$EXTENSIONS_FILE" ]]; then
    while read -r ext; do
        if [[ -n "$ext" ]]; then
            echo "Installing extension: $ext"
            code --install-extension "$ext" --force
        fi
    done < "$EXTENSIONS_FILE"
else
    echo "Error: $EXTENSIONS_FILE not found. Please ensure it is in the same directory as this script."
    exit 1
fi

echo "Installing JetBrains Mono Nerd Font..."
if [[ ! -d "$FONT_DIR" ]]; then
    mkdir -p "$FONT_DIR"
fi

if [[ ! -f "$FONT_DIR/JetBrainsMono-Regular.ttf" ]]; then
    echo "Downloading JetBrains Mono Nerd Font..."
    curl -L "$JETBRAINS_NERD_FONT_URL" -o "$TEMP_ZIP"
    if [[ -f "$TEMP_ZIP" ]]; then
        unzip -o "$TEMP_ZIP" -d "$FONT_DIR"
        rm -f "$TEMP_ZIP"
        echo "Updating font cache..."
        fc-cache -fv
    else
        echo "Failed to download font. Please check the URL or internet connection."
        exit 1
    fi
else
    echo "JetBrains Mono Nerd Font already installed. Updating font cache..."
    fc-cache -fv
fi

echo "Setting current VS Code settings as default..."
if [[ -f "settings.json" ]]; then
    if [[ -f "$VSCODE_CONFIG_DIR/settings.json" ]]; then
        mv "$VSCODE_CONFIG_DIR/settings.json" "$VSCODE_CONFIG_DIR/settings.json.bak"
    fi
    cp "settings.json" "$VSCODE_CONFIG_DIR/settings.json"
    echo "Settings applied from backup."
else
    echo "Warning: settings.json not found. Please provide it in the same directory as this script."
fi

echo "Configuring VS Code terminal to use JetBrains Mono Nerd Font..."
if [[ -f "$VSCODE_CONFIG_DIR/settings.json" ]]; then
    if ! grep -q "terminal.integrated.fontFamily" "$VSCODE_CONFIG_DIR/settings.json"; then
        echo "\"terminal.integrated.fontFamily\": \"JetBrainsMono Nerd Font\"," >> "$VSCODE_CONFIG_DIR/settings.json"
    fi
else
    echo "{\"terminal.integrated.fontFamily\": \"JetBrainsMono Nerd Font\"}" > "$VSCODE_CONFIG_DIR/settings.json"
fi

echo "Setting up Vim keybindings..."
if [[ -f "keybindings.json" ]]; then
    if [[ -f "$VSCODE_CONFIG_DIR/keybindings.json" ]]; then
        mv "$VSCODE_CONFIG_DIR/keybindings.json" "$VSCODE_CONFIG_DIR/keybindings.json.bak"
    fi
    cp "keybindings.json" "$VSCODE_CONFIG_DIR/keybindings.json"
    echo "Keybindings applied from backup."
else
    echo "Warning: keybindings.json not found. Please run the script inside the project directory."
fi

echo "VS Code environment recovery complete. Restart VS Code to apply changes."
