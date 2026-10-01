# a monochrome gnome rice

Screenshots:

<img width="1366" height="768" alt="Monochrome Desktop" src="previews/desktop.png" />
<img width="1366" height="768" alt="Monochrome Apps and Terminal" src="previews/apps.png" />

# Installation:
I have made a little shell script for automated installation, for that just run this in the terminal:

```bash
git clone https://github.com/af44n/Monochrome-Gnome-Rice && cd Monochrome-Gnome-Rice
chmod +x install.sh
./install.sh
```

if that doesn't work, here's the manual stuff:

## Manual Installation:

### GTK & Shell Theme:
The theme files are included in the `themes/dark-bs` directory.

To apply manually:
Copy `themes/dark-bs` to `~/.themes/` and `~/.local/share/themes/`.

If for some reason after restarting the theme isn't applied to GTK4/Libadwaita apps, copy the contents of `config/gtk-4.0/` and `config/gtk-3.0/` to your `~/.config/gtk-4.0/` and `~/.config/gtk-3.0/` folders, then log out and log back in.

- **Icons:** [YAMIS](https://www.gnome-look.org/p/1477945/) (included in `icons/YAMIS`, copy to `~/.icons/` and `~/.local/share/icons/`)
- **Cursor:** [Bibata-Modern-Ice](https://github.com/ful1e5/Bibata_Cursor) (included in `cursors/Bibata-Modern-Ice`)
- **Wallpaper:** included in `wallpapers/background.png`
- **Fonts:** [JetBrains Mono](https://www.jetbrains.com/lp/mono/)

### Extensions:
- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
- [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
- [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
- [Clipboard Indicator](https://extensions.gnome.org/extension/779/clipboard-indicator/)
- [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)
- [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/)
- [Logo Menu](https://extensions.gnome.org/extension/4451/logo-menu/)
- [Space Bar](https://extensions.gnome.org/extension/5090/space-bar/)
- [Top Bar Organizer](https://extensions.gnome.org/extension/4356/top-bar-organizer/)
- [Top Hat](https://extensions.gnome.org/extension/5219/tophat/)

To restore the exact extension configuration, run:
```bash
dconf load /org/gnome/shell/extensions/ < config/dconf/extensions.dconf
```

### Terminal:
For the shell, I'm using [fish shell](https://fishshell.com/)
and for theme, I'm using [omf](https://github.com/oh-my-fish/oh-my-fish)
and after installation, you can type `omf install agnoster` to get the theme variant.

For fastfetch, configure your config to use a monochrome ASCII art or icon layout.

### Some tips:
rice is fun if every app and website follows it, for that you can checkout the [Stylus](https://chromewebstore.google.com/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne) browser extension to install custom dark/monochrome styles for web pages.
Also flatpak packages sometimes don't support custom gtk themes out of the box, so run:
```bash
flatpak override --user --filesystem=xdg-config/gtk-4.0
flatpak override --user --filesystem=xdg-config/gtk-3.0
flatpak override --user --filesystem=~/.themes
flatpak override --user --filesystem=~/.icons
```

That's about it :), if you like the rice, do star the repo :)
Also if you need any help, you can open an issue here, I would love to help out :D Happy Ricing!
