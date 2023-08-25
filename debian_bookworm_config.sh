#!/bin/bash
bold=`echo -en "\e[1m"`
purple=`echo -en "\e[35m"`
orange=`echo -en "\e[33m"`
red=`echo -en "\e[31m"`
green=`echo -en "\e[32m"`
lightblue=`echo -en "\e[94m"`
underline=`echo -en "\e[4m"`
normal=`echo -en "\e[0m"`

sudo_check() {
    #not superuser check
    if ! [ "$EUID" -ne 0 ] ; then
        echo "${orange}Dont run this script as root, run as the user whose environment u want to change.$normal"
        exit
    fi

    #install sudo if not already installed
    if ! hash sudo 2>/dev/null; then
        echo "${purple}installing sudo$normal"
        su -c "DEBIAN_FRONTEND=noninteractive apt-get -yq install sudo"
    fi

    # Check if the current user is in the sudo group
    if grep -qE "^sudo:" /etc/group; then
        if ! groups $USER | grep -q "\bsudo\b"; then
            echo "$USER is not a member of the sudo group. Adding to group..."
            # Add $USER to the sudo group
            su - -c "usermod -aG sudo $USER"
            # TODO: You might need to perform additional steps like logout/restart or sourcing commands.
        fi
    else
        echo "The sudo group does not exist."
    fi
} 

update_system() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq full-upgrade && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq autoremove
} 

install_kde_plasma_minimal() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install kde-plasma-desktop plasma-nm
    sudo sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
    sudo systemctl restart NetworkManager
}

reboot_now() {
    sudo shutdown -r now
}

install_firewall() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install ufw gufw
    sudo ufw enable
}

add_contrib_source() {
    echo "# Here are the debian mirrors. Other mirrors should be added in /etc/apt/sources.list.d/

deb http://deb.debian.org/debian bookworm main non-free-firmware contrib
deb-src http://deb.debian.org/debian bookworm main non-free-firmware contrib

deb http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware contrib
deb-src http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware contrib

deb http://deb.debian.org/debian bookworm-updates main non-free-firmware contrib
deb-src http://deb.debian.org/debian bookworm-updates main non-free-firmware contrib
" | sudo tee /etc/apt/sources.list
}

add_i386_arch() {
    sudo dpkg --add-architecture i386
}

install_steam() {
    add_contrib_source
    add_i386_arch
    sudo apt-get -qq update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install steam
}

install_gimp() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install gimp
}

install_krita() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install krita
}

install_blender() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install blender
}

install_go() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install golang
}

install_vscode() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install apt-transport-https
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install code
}

install_qemu_kvm() {
  if [[ $(egrep -c '(vmx|svm)' /proc/cpuinfo) > 0 ]];then
    echo "${green}kvm supported and enabled in bios$normal"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
    sudo gpasswd -a $USER kvm
  else
    echo "${red}kvm not supported or not enabled in bios$normal"
  fi
}

install_firefox() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install firefox-esr webext-ublock-origin-firefox
    # run firefox so it creates config files that we to change
    firefox-esr&
    sleep 5
    pkill -f firefox
    # modify config file
    prefix="/home/$USER/.mozilla/firefox"
    suffix=".default-esr/"
    path=""
    for f in "${prefix}"/*"${suffix}"; do
        path="$f""user.js"
    done
    echo $path
    echo "user_pref(\"browser.contentblocking.category\",custom);
    user_pref(\"browser.privatebrowsing.autostart\", true);
    user_pref(\"browser.shell.checkDefaultBrowser\", true);
    user_pref(\"network.cookie.cookieBehavior\",1);
    user_pref(\"network.cookie.lifetimePolicy\",2);
    user_pref(\"privacy.donottrackheader.enabled\", true);
    user_pref(\"privacy.trackingprotection.enabled\", true);
    user_pref(\"privacy.trackingprotection.socialtracking.enabled\", true);
    user_pref(\"signon.rememberSignons\", false);
    " | sudo tee $path
}

install_keepass() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install keepass2
}

install_thunderbird() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install thunderbird
}

install_obs-studio() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install obs-studio
}

install_baobab() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install baobab
}

install_nethogs() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install nethogs
}

install_ark() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install ark
}

install_kcalc() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install kcalc
}

install_kde-spectacle() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install kde-spectacle
}

install_okular() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install okular
}

install_gwenview() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install gwenview
}

install_neofetch() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install neofetch
}

install_htop() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install htop
}

install_plasma-sdk() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install plasma-sdk
}

install_cava() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install cava
}

install_docker-ce() {
    # install dependencies
    sudo apt-get -yqq install apt-transport-https ca-certificates curl gnupg lsb-release
    # install key
    #curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor > /usr/share/keyrings/docker-archive-keyring.gpg
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
    # install repo
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # update package list
    sudo apt-get -qq update
    # install docker
    sudo apt-get -yqq install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    # add $USER to sudo group
    sudo usermod -aG docker $USER
    newgrp docker #to initialise new group to session without logout/login
    # fix permissiom
    sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
    sudo chmod g+rwx "$HOME/.docker" -R
    # enable docker service
    sudo systemctl start docker.service
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    #docker --version
    #docker compose version
    echo "You may need to logout and login again to use docker command!"
}

remove_software() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq remove kwalletmanager termit xterm zutty && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq autoremove
}

disable_wifi() {
    nmcli radio all off
}

disable_bluetooth() {
    sudo systemctl stop bluetooth.service
    sudo systemctl disable bluetooth.service
}

enable_airplane_mode() {
    kwriteconfig5 --file ~/.config/plasma-nm --group General --key AirplaneModeEnabled true
}

disable_history() {
    kwriteconfig5 --file ~/.config/kactivitymanagerd-pluginsrc --group Plugin-org.kde.ActivityManager.Resources.Scoring --key what-to-remember 1
}

disable_mouse_acceleration() {
    kwriteconfig5 --file ~/.config/kcminputrc --group Mouse --key XLbInptAccelProfileFlat true
    kwriteconfig5 --file ~/.config/kcminputrc --group Mouse --key XLbInptPointerAcceleration 1
}

configure_dolphin() {
    kwriteconfig5 --file ~/.local/share/dolphin/view_properties/global/.directory --group Settings --key HiddenFilesShown true
    kwriteconfig5 --file ~/.config/dolphinrc --group General --key ShowFullPath true
    kwriteconfig5 --file ~/.config/dolphinrc --group General --key ShowFullPathInTitlebar true
    kwriteconfig5 --file ~/.config/dolphinrc --group Search --key Location Everywhere
    kwriteconfig5 --file ~/.config/kdeglobals --group KDE --key SingleClick false
}

create_file_templates() {
    tdir=$HOME/Templates
    echo "#!/usr/bin/env python3" > $tdir/python_script.py
    echo "#!/bin/bash" > $tdir/bash_script.sh

    echo -e "[Desktop Entry]
Name=python_script
Comment=python_script
Type=Link
URL=python_script.py
Icon=text-x-python3" | tee $tdir/python_script.desktop

    echo -e "[Desktop Entry]
Name=bash_script
Comment=bash_script
Type=Link
URL=bash_script.sh
Icon=application-x-shellscript" | tee $tdir/bash_script.desktop
}

create_ll_alias() {
    # Define the filename
    filename="/home/$USER/.bashrc"

    # Uncomment and modify the aliases
    sed -i '/alias ls=/s/^    #/    /g' $filename
    sed -i '/alias dir=/s/^    #/    /g' $filename
    sed -i '/alias vdir=/s/^    #/    /g' $filename
    sed -i '/alias grep=/s/^    #/    /g' $filename
    sed -i '/alias fgrep=/s/^    #/    /g' $filename
    sed -i '/alias egrep=/s/^    #/    /g' $filename
    sed -i '/export GCC_COLORS=/s/^#//g' $filename
    sed -i '/alias ll=/s/^#//g' $filename
    sed -i '/alias la=/s/^#//g' $filename
    sed -i '/alias l=/s/^#//g' $filename
    sed -i 's/ls -l/ls -lha/g' $filename
    source $filename
}


create_ssh_key() {
    # Create ssh key with pw if not exists
    FILE=~/.ssh/id_ed25519.pub
    if [ -f $FILE ]; then
        echo "$FILE already exists. Abort"
    else
        echo "Create new ssh key"
        ssh-keygen -t ed25519 -C "${USER}@${HOSTNAME}" -f ~/.ssh/id_ed25519 -N ''
    fi
}

disable_swap() {
    # This may need some more testing and imppovement ;)
    swap_path=$(sudo tail -n 1 /etc/fstab | grep swap | cut -d " " -f1)
    sudo swapoff $swap_path
    sudo sed -i '/^[^#]/ s/\(^.*swap.*$\)/#\ \1/' /etc/fstab
    #if lvm
    sudo lvremove $swap_path
    #if normal
    sudo rm $swap_path
}

copy_custom_themes() {
    cp -r -a .local/share $HOME/.local/share
}

install_simple_menu() {
    echo "TODO simple menu"
}

install_sddm_theme() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install sddm-theme-breeze
    sudo rm -rf /usr/share/sddm/themes/debian-theme
    sudo ln -s /usr/share/sddm/themes/breeze /usr/share/sddm/themes/debian-theme
    #sudo sddm-greeter --theme /usr/share/sddm/themes/breeze
    #sudo sddmthemeinstaller -i /home/$USER/Downloads/theme.tar.gz
}

configure_lockscreen() {
    kwriteconfig5 --file ~/.config/kscreenlockerrc --group Daemon --key Timeout 10
}

look_and_feel() {
    lookandfeeltool -a "$1"
}

plasma_theme() {
    kwriteconfig5 --file ~/.config/plasmarc --group Theme --key name "$1"
}

application_style_edit() {
    kwriteconfig5 --file ~/.config/kdeglobals --group KDE --key widgetStyle "$1"
}

window_decoration() {
    kwriteconfig5 --file ~/.config/kwinrc --group org.kde.kdecoration2 --key library "$1"
    kwriteconfig5 --file ~/.config/kwinrc --group org.kde.kdecoration2 --key theme "$2"
}

gtk_theme() {
    kwriteconfig5 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-theme-name "$1"
}

color_scheme() {
    kwriteconfig5 --file ~/.config/kdeglobals --group General --key ColorScheme "$1"
}

icons() {
    kwriteconfig5 --file ~/.config/kdeglobals --group Icons --key Theme "$1"
}

cursor() {
    kwriteconfig5 --file ~/.config/kcminputrc --group Mouse --key cursorTheme "$1"
}

gtk_cursor() {
    kwriteconfig5 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-cursor-theme-name "$1"
}

splash_screen() {
    kwriteconfig5 --file ~/.config/ksplashrc --group KSplash --key Theme "$1"
}

change_global_theme_dark() {
    install_sddm_theme
    look_and_feel "org.kde.breezedark.desktop"
    plasma_theme "breeze-dark"
    application_style_edit "Breeze"
    window_decoration "org.kde.breeze" "Breeze"
    gtk_theme "Breeze"
    color_scheme "BreezeDark"
    icons "breeze-dark"
    cursor "breeze_cursors"
    gtk_cursor "breeze_cursors"
    splash_screen "org.kde.breeze.desktop"
}

change_global_theme_light() {
    install_sddm_theme
    look_and_feel "org.kde.breeze.desktop"
    plasma_theme "breeze"
    application_style_edit "Breeze"
    window_decoration "org.kde.breeze" "Breeze"
    gtk_theme "Breeze"
    color_scheme "Breeze"
    icons "breeze"
    cursor "breeze_cursors"
    gtk_cursor "breeze_cursors"
    splash_screen "org.kde.breeze.desktop"
}

change_global_theme_to_mystix() {
    install_sddm_theme
    look_and_feel "MystixGlobalTheme"
    plasma_theme "MystixPlasmaTheme"
    application_style_edit "Breeze"
    window_decoration "org.kde.breeze" "Breeze"
    gtk_theme "Breeze"
    color_scheme "MystixColorScheme"
    icons "breeze-dark"
    cursor "breeze_cursors"
    gtk_cursor "breeze_cursors"
    splash_screen "org.kde.breeze.desktop"
}

change_wallpaper() {
    echo "${orange}Choose standard wallpaper$normal"
    wallpaper=$(zenity --file-selection --title="Choose standard wallpaper")
    echo "standard wallpaper:   $wallpaper"
    echo "${orange}Choose login wallpaper$normal"
    wallpaper_sddm=$(zenity --file-selection --title="Choose login wallpaper")
    echo "login wallpaper:      $wallpaper_sddm"
    echo "${orange}Choose lockscreen wallpaper$normal"
    wallpaper_lock=$(zenity --file-selection --title="Choose lockscreen wallpaper")
    echo "lockscreen wallpaper: $wallpaper_lock"
    #sddm wallpaper
    sudo kwriteconfig5 --file /usr/share/sddm/themes/breeze/theme.conf --group General --key background $wallpaper_sddm
    #lockscreen wallpaper
    kwriteconfig5 --file ~/.config/kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image $wallpaper_lock
    #wallpaper
	dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:
		var Desktops = desktops();
			for (i=0;i<Desktops.length;i++){
				d = Desktops[i]; d.wallpaperPlugin = "org.kde.image";
				d.currentConfigGroup = Array("Wallpaper","org.kde.image","General");
				d.writeConfig("Image","file://'$wallpaper'");
			}'
}

restart_ui() {
    qdbus org.kde.KWin /KWin reconfigure
    killall plasmashell
    nohup kstart5 plasmashell & >/dev/null 2>&1
}

functions_array=(
    update_system install_kde_plasma_minimal reboot_now install_firewall install_steam
    install_gimp install_krita install_blender install_go install_qemu_kvm install_firefox
    install_keepass install_thunderbird install_obs-studio install_baobab install_nethogs
    install_ark install_kcalc install_kde-spectacle install_okular install_gwenview
    install_neofetch install_htop install_plasma-sdk install_cava install_docker-ce
    remove_software disable_wifi disable_bluetooth enable_airplane_mode disable_history
    disable_mouse_acceleration configure_dolphin create_file_templates create_ll_alias
    create_ssh_key disable_swap install_simple_menu configure_lockscreen
    change_global_theme_dark change_global_theme_light change_global_theme_to_mystix
    change_wallpaper restart_ui
)

helpmenu(){
    echo "${lightblue}###############################$normal"
    echo "${lightblue}## debian_bookworm_config.sh ##$normal"
    echo "${lightblue}###############################$normal"
    echo "${purple}Usage:$normal bash debian_bookworm_config.sh <option> <option> <option>"
    echo "Starts in interactive mode without arguments"
    echo ""
    echo "-h        --help                    Display Help"
    echo ""
    echo "${purple}Options:$normal"

    for func in "${functions_array[@]}"; do
        echo -e "$func"
    done

    exit
}

sudo_check
if [[ " $# " -ne 0 ]]; then
    #echo "${orange}Total Arguments: $# $normal"
    for i in $@
    do
        if [[ ${i} = "-h" || ${i} = "--help" || ${i} = "help" ]]; then
            helpmenu
        fi
        if [[ " ${functions_array[@]} " =~ " ${i} " ]]; then
            # whatever you want to do when array contains value
            echo "${green}Option ${i} valid$normal"
            ${i} #exec function
        else
            echo "${red}Unknown option ${i}$normal"
        fi
    done
else
    for i in "${functions_array[@]}"; do
        formatted1=${i//_/ }
        formatted2=${formatted1^}
        echo -n "${purple}${formatted2^} (y/n)? $normal"
        read answer
        if [ "$answer" != "${answer#[Yy]}" ] ;then
            ${i}
        fi
    done
fi

## Script stuff
#TODO monitor to max hertz and enable sync
#TODO pin fav software to panel
#TODO allow ublock in private windows
#TODO enable num
#TODO konsole>general>show window title on titlebar
#TODO konsole hide main and session toolbar
#TODO Window Decorations > Titlebar Buttons -->burger menu
#TODO sysctl network interface to 1GB 2.5GB 10GB

## Theme stuff
#TODO my custom themes/colorschemes -> activate them via this script
#TODO login screen wallpaper
#TODO blender theme



#Primary Dark
#320a5a

#Primary
#481c74

#primary light
#5d308a


#background dark
#151124

#background
#191628

#background light
#221f3a


#Text white
#d2bff4

#Text intense
#734596

#Text intense 2
#7102ad

#links
#3c72c3
