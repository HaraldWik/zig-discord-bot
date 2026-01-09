# Zig Discord Bot

## Installation

Ubuntu and Debian

`apt update && apt install -y libcurl4-openssl-dev`

Void Linux

`xbps-install -S libcurl-devel`

Alpine

`apk add curl-dev`

FreeBSD

`pkg install curl`

OS X

    Note: you will need to install Xcode, or at a minimum, the command-line tools with xcode-select --install.

`$ brew install curl (Homebrew)`
`$ port install curl (MacPorts)`

Arch Linux / Manjaro (Arch based)

```
git clone https://aur.archlinux.org/concord-git.git
cd concord-git
makepkg -Acs
pacman -U concord-git-version-any.pkg.tar.zst
```

Alternatively, you can use an AUR helper:

`yay -S concord-git`

### Token

The token can alternatively be stored in the DISCORD_TOKEN enviorment variable or the token can be stored in src/TOKEN

### Leveling

There is a level_table.json that stores all information needed, fill this out with the correct guild (server) id, channel id where the level up notifications will be sent and ofc the xp needed for a level and the role id that the user will receive on level up this field is optional but recommended. 

### Zig

And when curl is installed just run 
`zig build run`