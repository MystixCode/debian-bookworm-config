#!/bin/bash
bold=`echo -en "\e[1m"`
purple=`echo -en "\e[35m"`
orange=`echo -en "\e[33m"`
red=`echo -en "\e[31m"`
green=`echo -en "\e[32m"`
lightblue=`echo -en "\e[94m"`
underline=`echo -en "\e[4m"`
normal=`echo -en "\e[0m"`

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

# add $USER to sudo group
su - -c "usermod -aG sudo $USER"
# TODO eventuell isch do a logout/restart/source command nötig oder ma könnt eifach im visudo das ALL ALL zügs innemache -> see my debian 11 script!!!!!!!!!!!!!!!!!

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
    echo "# add contrib to be able to install stuff like steam

    deb http://mirror.init7.net/debian/ bookworm contrib
    deb-src http://mirror.init7.net/debian/ bookworm contrib

    deb http://security.debian.org/debian-security bookworm-security contrib
    deb-src http://security.debian.org/debian-security bookworm-security contrib

    " | sudo tee /etc/apt/sources.list.d/contrib.list
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
    # run firefox so it creates config files that we may want to change later
    firefox-esr&
    sleep 5
    pkill -f firefox
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
    #TODO errorhandling if file doesnt exist
    # grep -qxF "alias ll='ls -lSh'" /etc/profile.d/00-aliases.sh || echo "alias ll='ls -lSh'" >> /etc/profile.d/00-aliases.sh

    sudo echo "alias ll=\"ls -lha --color=always -F --group-directories-first |awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\\\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\\\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\\\"%0o%0o \\\",s,k);};print;}'\"" | sudo tee -a /etc/profile.d/00-aliases.sh

    source /etc/profile.d/00-aliases.sh
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

configure_firefox() {
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

install_simple_menu() {
    echo "TODO simple menu"
#    echo "${orange}Manually download to /home/$USER/Downloads/ from here:$normal"
#    echo "${lightblue}${underline}https://store.kde.org/s/KDE%20Store/p/1275285$normal"
#    read -p "${red}Then Press enter to continue$normal"
#    #TODO automate this with permanent working link
#    #wget -O ~/Downloads/minimalmenu-0.3.0.plasmoid https://dllb2.pling.com/api/files/download/j/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjE1NDMwNDk1NDQiLCJ1IjpudWxsLCJsdCI6ImRvd25sb2FkIiwicyI6IjQ5Yjk5Nzg5N2U5NGExYWUxYWM3MmNiZWU1ZWI0MWJlMWFiYzE4OTIxOTBlZGQyMDU0MjhmN2QzNjEzODg1MGVlYzZkNDA1ZGQzOWZmMTlkZjg3Mjk0NTE2MTY5ZDY0YjYyODJkZTMyMzhkNDVlMjI1MDFjYWM5MzI4M2M2ZWVjIiwidCI6MTYyNTM1MzczNywic3RmcCI6IjQ2NGQ2YTAxZGQ1Mjk5NzY3OWE3ZDE1Nzk1OTBlYTM0Iiwic3RpcCI6IjJhMDI6MTIwNTozNGMxOmUwYzA6NzJjMDphNWZkOjkxNzU6NmQ2In0.WCdUSToV3lxljvpDuaCH_jrC89NfNvc6n0YGXsWlZq8/minimalmenu-0.3.0.plasmoid
#    sudo kpackagetool5 -i ~/Downloads/minimalmenu-0.3.0.plasmoid
#    kwriteconfig5 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 3 --group Applets --group 24 --group Configuration --group General --key customButtonImage /usr/share/pixmaps/debian-logo.png
#    kwriteconfig5 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 3 --group Applets --group 24 --group Configuration --group General --key favoritesPortedToKAstats true
#    kwriteconfig5 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 3 --group Applets --group 24 --group Configuration --group General --key switchCategoriesOnHover false
#    kwriteconfig5 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 3 --group Applets --group 24 --group Configuration --group General --key useCustomButtonImage true
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
    kquitapp5 plasmashell && kstart5 plasmashell
}

helpmenu(){
    echo "${lightblue}###############################$normal"
    echo "${lightblue}## debian_bookworm_config.sh ##$normal"
    echo "${lightblue}###############################$normal"
    echo "${purple}Usage:$normal bash debian_bookworm_config.sh <option>"
    echo "Starts in interactive mode without arguments"
    echo ""
    echo "-h        --help                    Display Help"
    echo ""
    echo "${purple}Options:$normal"
    echo -e "update_system\ninstall_kde_plasma_minimal\nreboot_now\ninstall_firewall\ninstall_steam\ninstall_gimp\ninstall_krita\ninstall_blender\ninstall_go\ninstall_qemu_kvm\ninstall_firefox\ninstall_keepass\ninstall_thunderbird\ninstall_obs-studio\ninstall_baobab\ninstall_nethogs\ninstall_ark\n install_kcalc\ninstall_kde-spectacle\ninstall_okular\ninstall_gwenview\ninstall_neofetch\ninstall_htop\ninstall_plasma-sdk\ninstall_cava\ninstall_docker-ce\nremove_software\ndisable_wifi\ndisable_bluetooth\nenable_airplane_mode\ndisable_history\ndisable_mouse_acceleration\nconfigure_dolphin\ncreate_file_templates\ncreate_ll_alias\ncreate_ssh_key\ndisable_swap\nconfigure_firefox\ninstall_simple_menu\nconfigure_lockscreen\nchange_global_theme_dark\nchange_global_theme_light\nchange_wallpaper\nrestart_ui"
    exit
}

functions_array=(update_system install_kde_plasma_minimal reboot_now install_firewall install_steam install_gimp install_krita install_blender install_go install_qemu_kvm install_firefox install_keepass install_thunderbird install_obs-studio install_baobab install_nethogs install_ark install_kcalc install_kde-spectacle install_okular install_gwenview install_neofetch install_htop install_plasma-sdk install_cava install_docker-ce remove_software disable_wifi disable_bluetooth enable_airplane_mode disable_history disable_mouse_acceleration configure_dolphin create_file_templates create_ll_alias create_ssh_key disable_swap configure_firefox install_simple_menu configure_lockscreen change_global_theme_dark change_global_theme_light change_wallpaper restart_ui)
if [[ " $# " -ne 0 ]]; then
    #echo "${orange}Total Arguments: $# $normal"
    for i in $@
    do
        if [[ ${i} = "-h" || ${i} = "--help" ]]; then
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
#TODO copy my custom themes/colorschemes and activate them via this script
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

