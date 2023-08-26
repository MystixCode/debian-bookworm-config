# debian-bookworm-config

This is a bash script to install and configure software on a debian 12 bookworm.

<img src="/screenshot_1.png" width="100%" height="100%">

## HowTo

 1. Download Debian 12 iso
 2. Write iso to usb stick using either Rufus, Balena Etcher or the DD command (replace /dev/sda with your usb device!):
```shell
lsblk -f
sudo dd bs=4M if=$HOME/Downloads/debian-12.1.0-amd64-netinst.iso of=/dev/sda oflag=sync status=progress
```
 3. Boot from usb stick -> Advanced Options -> Expert Install. \
    Install debian minimal without desktop/software!
 4. Login as root
 5. Install git
 ```bash
apt-get install git
su <yourusername>
cd
git config --global user.name "Sarah Smith"
git config --global user.email "sarah.smith@email.com"
mkdir git
cd git
 ```
 6. Download this repo and start script
```bash
git clone https://github.com/MystixCode/debian-bookworm-config.git
cd debian-bookworm-config
chmod u+x debian_bookworm_config.sh
./debian_bookworm_config.sh
```

## Arguments

```
Usage: ./debian_bookworm_config.sh <arg> <arg> <arg>
Starts in interactive mode without arguments

Arguments:
update_system                  Update the system packages
install_kde_plasma_minimal     Install KDE Plasma minimal desktop
reboot_now                     Reboot the system
install_firewall               Install a firewall
install_steam                  Install Steam
install_gimp                   Install GIMP
install_krita                  Install Krita
install_blender                Install Blender
install_go                     Install Go programming language
install_qemu_kvm               Install QEMU-KVM
install_firefox                Install Firefox
install_keepass                Install KeePass password manager
install_thunderbird            Install Thunderbird email client
install_obs_studio             Install OBS Studio
install_baobab                 Install Baobab disk usage analyzer
install_nethogs                Install Nethogs network traffic monitor
install_ark                    Install Ark archive manager
install_kcalc                  Install KCalc calculator
install_kde_spectacle          Install KDE Spectacle screenshot tool
install_okular                 Install Okular document viewer
install_gwenview               Install Gwenview image viewer
install_neofetch               Install Neofetch system information tool
install_htop                   Install htop system monitor
install_plasma_sdk             Install Plasma SDK
install_cava                   Install Cava audio visualizer
install_docker_ce              Install Docker CE
remove_software                Remove specified software
disable_wifi                   Disable Wi-Fi
disable_bluetooth              Disable Bluetooth
enable_airplane_mode           Enable airplane mode
disable_history                Disable kde history (Recent Files, Recent Locations)
disable_mouse_acceleration     Disable mouse acceleration
configure_dolphin              Configure Dolphin file manager
create_file_templates          Create file templates in Dolphin
create_ll_alias                Create 'll' alias and add some color
create_ssh_key                 Create SSH key pair
disable_swap                   Disable swap space
install_simple_menu            Install Simple Menu application launcher
configure_lockscreen           Configure lock screen settings
change_global_theme_dark       Change global theme to dark
change_global_theme_light      Change global theme to light
change_global_theme_to_mystix  Change global theme to Mystix
change_wallpaper               Change wallpaper
restart_ui                     Restart user interface
display_settings               Display settings
-h, --help, help               Display this help menu
```
