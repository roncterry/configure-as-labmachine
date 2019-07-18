#!/bin/bash
# version: 1.0.1
# date: 2019-07-18

CONFIG_DIR="./config"
INCLUDE_DIR="./include"

FILES_SRC_DIR="files"
RPM_SRC_DIR="rpm"

source ${CONFIG_DIR}/configure-as-labmachine.cfg
source ${CONFIG_DIR}/*.sh

#############################################################################

set_colors() {
  ### Colors ###
  export RED='\e[0;31m'
  export LTRED='\e[1;31m'
  export BLUE='\e[0;34m'
  export LTBLUE='\e[1;34m'
  export GREEN='\e[0;32m'
  export LTGREEN='\e[1;32m'
  export ORANGE='\e[0;33m'
  export YELLOW='\e[1;33m'
  export CYAN='\e[0;36m'
  export LTCYAN='\e[1;36m'
  export PURPLE='\e[0;35m'
  export LTPURPLE='\e[1;35m'
  export GRAY='\e[1;30m'
  export LTGRAY='\e[0;37m'
  export WHITE='\e[1;37m'
  export NC='\e[0m'
  ##############
  #echo -e "${LTBLUE}${NC}"
  #echo -e "${LTCYAN}${NC}"
  #echo -e "${LTPURPLE}${NC}"
  #echo -e "${LTRED}${NC}"
  #echo -e "${ORANGE}${NC}"
  #echo -e "${LTGREEN}COMMAND:${GRAY}  ${NC}"
}

add_zypper_repos() {
  echo -e "${LTBLUE}Adding zypper repositories${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  if ! grep -q "dl.google.com" /etc/zypp/repos.d/*.repo
  then
    echo -e "${LTCYAN}google-chrome${NC}"
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} zypper addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome${NC}"
    ${SUDO_CMD} zypper addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
    if ! [ -e ${FILES_SRC_DIR}/linux_signing_key.pub ]
    then
      echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cd ${FILES_SRC_DIR}${NC}"
      ${SUDO_CMD} cd ${FILES_SRC_DIR}
      echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} wget https://dl.google.com/linux/linux_signing_key.pub${NC}"
      ${SUDO_CMD} wget https://dl.google.com/linux/linux_signing_key.pub
      echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} rpm --import linux_signing_key.pub${NC}"
      ${SUDO_CMD} rpm --import linux_signing_key.pub
      echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cd -${NC}"
      ${SUDO_CMD} cd - > /dev/null
    fi
  fi

  echo
}

refresh_zypper_repos() {
  echo -e "${LTBLUE}Refreshing zypper repos${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} zypper --no-gpg-checks --gpg-auto-import-keys ref${NC}"
  ${SUDO_CMD} zypper --no-gpg-checks --gpg-auto-import-keys ref
  echo
}

install_zypper_patterns() {
  echo -e "${LTBLUE}Installing zypper patterns${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for PATTERN in ${ZYPPER_PATTERN_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} zypper -n --no-refresh install ${PATTERN}${NC}"
    ${SUDO_CMD} zypper -n --no-refresh install -t pattern ${PATTERN}
  done
  echo
}

install_zypper_packages() {
  echo -e "${LTBLUE}Installing zypper packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for PACKAGE in ${ZYPPER_PACKAGE_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} zypper -n --no-refresh install ${PACKAGE}${NC}"
    ${SUDO_CMD} zypper -n --no-refresh install -l ${PACKAGE}
  done
  echo
}

install_extra_rpms() {
  if ls ${RPM_SRC_DIR} | grep -q ".rpm"
  then
    echo -e "${LTBLUE}Installing custom RPM packages${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} rpm -U ${RPM_SRC_DIR}/*.rpm${NC}"
    ${SUDO_CMD} rpm -U ${RPM_SRC_DIR}/*.rpm
    echo
  fi
}

configure_sudo() {
  echo -e "${LTBLUE}Configuring sudo${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if ! which sudo > /dev/null
  then
    echo -e "${LTCYAN}sudo Not Installed.  Installing ...${NC}"
    refresh_zypper_repos
    echo -e "${LTGREEN}COMMAND:${GRAY}  zypper -n --no-refresh install sudo${NC}"
    zypper -n --no-refresh install sudo
    echo
  fi

  if grep -q "^Defaults targetpw .*" /etc/sudoers
  then
    echo -e "${LTCYAN}#Defaults targetpw${NC}"
    ${SUDO_CMD} sed  -i 's/\(^Defaults targetpw .*\)/\#\1/' /etc/sudoers
  fi

  if grep -q "^ALL .*" /etc/sudoers
  then
    echo -e "${LTCYAN}#ALL  ALL=(ALL) ALL${NC}"
    ${SUDO_CMD} sed -i 's/\(^ALL .*\)/\#\1/' /etc/sudoers
  fi

  if ! grep -q "^%users ALL=(ALL) NOPASSWD: ALL" /etc/sudoers
  then
    echo -e "${LTCYAN}%users  ALL=(ALL) NOPASSWD: ALL${NC}"
    ${SUDO_CMD} echo "%users ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi
  echo
}

install_modprobe_config() {
  if ! [ -e /etc/modprobe.d/50-kvm.conf ]
  then
    echo -e "${LTBLUE}Installing modprobe configuration${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/50-kvm.conf /etc/modprobe.d${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/50-kvm.conf /etc/modprobe.d
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown root.root /etc/modprobe.d/*${NC}"
    ${SUDO_CMD} chown root.root /etc/modprobe.d/*
    echo
  fi
}

configure_libvirt() {
  echo -e "${LTBLUE}Configuring Libvirt${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  # Change to UNIX socket based access and authorization
  echo -e "${LTCYAN}/etc/libvirt/libvirtd.conf:${NC}"
  echo -e "${LTCYAN}unix_socket_group = \"libvirt\"${NC}"
  ${SUDO_CMD} sed -i 's/^#unix_socket_group.*/unix_socket_group = "libvirt"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^unix_socket_group.*/unix_socket_group = "libvirt"/' /etc/libvirt/libvirtd.conf

  echo -e "${LTCYAN}unix_sock_ro_perms = \"0777\"${NC}"
  ${SUDO_CMD} sed -i 's/^#unix_sock_ro_perms.*/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^unix_sock_ro_perms.*/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf

  echo -e "${LTCYAN}unix_sock_rw_perms = \"0770\"${NC}"
  ${SUDO_CMD} sed -i 's/^#unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

  echo -e "${LTCYAN}unix_sock_admin_perms = \"0700\"${NC}"
  ${SUDO_CMD} sed -i 's/^#unix_sock_admin_perms.*/unix_sock_admin_perms = "0700"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^unix_sock_admin_perms.*/unix_sock_admin_perms = "0700"/' /etc/libvirt/libvirtd.conf

  echo -e "${LTCYAN}unix_sock_dir = \"/var/run/libvirt\"/${NC}"
  ${SUDO_CMD} sed -i 's+^#unix_sock_dir.*+unix_sock_dir = "/var/run/libvirt"+' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's+^unix_sock_dir.*+unix_sock_dir = "/var/run/libvirt"+' /etc/libvirt/libvirtd.conf

  echo -e "${LTCYAN}auth_unix_ro = \"none\"${NC}"
  ${SUDO_CMD} sed -i 's/^#auth_unix_ro.*/auth_unix_ro = "none"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^auth_unix_ro.*/auth_unix_ro = "none"/' /etc/libvirt/libvirtd.conf

  echo -e "${LTCYAN}auth_unix_rw = \"none\"${NC}"
  ${SUDO_CMD} sed -i 's/^#auth_unix_rw.*/auth_unix_rw = "none"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^auth_unix_rw.*/auth_unix_rw = "none"/' /etc/libvirt/libvirtd.conf

  # Enable TCP listening
  echo -e "${LTCYAN}listen_tcp = 1${NC}"
  ${SUDO_CMD} sed -i 's/^#listen_tcp.*/listen_tcp = 1/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^listen_tcp.*/listen_tcp = 1/' /etc/libvirt/libvirtd.conf

  echo -e "${LTCYAN}auth_tcp = \"none\"${NC}"
  ${SUDO_CMD} sed -i 's/^#auth_tcp.*/auth_tcp = "none"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^auth_tcp.*/auth_tcp = "none"/' /etc/libvirt/libvirtd.conf

  echo
  # Enable open listening in for VNC and Spice
  echo -e "${LTCYAN}/etc/libvirt/qemu.conf:${NC}"
  echo -e "${LTCYAN}vnc_listen = \"0.0.0.0\"${NC}"
  ${SUDO_CMD} sed -i 's/^#vnc_listen.*/vnc_listen = "0.0.0.0"/' /etc/libvirt/qemu.conf
  ${SUDO_CMD} sed -i 's/^vnc_listen.*/vnc_listen = "0.0.0.0"/' /etc/libvirt/qemu.conf

  echo -e "${LTCYAN}spice_listen = \"0.0.0.0\"${NC}"
  ${SUDO_CMD} sed -i 's/^#spice_listen.*/spice_listen = "0.0.0.0"/' /etc/libvirt/qemu.conf
  ${SUDO_CMD} sed -i 's/^spice_listen.*/spice_listen = "0.0.0.0"/' /etc/libvirt/qemu.conf

  echo

  if [ -e ${FILES_SRC_DIR}/libvirt.sh ]
  then
    # Libvirt shell profile
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt.sh /etc/profile.d/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt.sh /etc/profile.d/
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown root.root /etc/profile.d/libvirt.sh${NC}"
    ${SUDO_CMD} chown root.root /etc/profile.d/libvirt.sh
 
    echo
  fi
}

install_labmachine_scripts() {
  if [ -e ${FILES_SRC_DIR}/labmachine_scripts.tgz ]
  then
    echo -e "${LTBLUE}Installing Labmachine Scripts${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C / -xzf ${FILES_SRC_DIR}/labmachine_scripts.tgz ${NC}"
    ${SUDO_CMD} tar -C / -xzf ${FILES_SRC_DIR}/labmachine_scripts.tgz 
 
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown root.root /usr/local/bin/*.sh${NC}"
    ${SUDO_CMD} chown root.root /usr/local/bin/*.sh
 
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chmod +x /usr/local/bin/*.sh${NC}"
    ${SUDO_CMD} chmod +x /usr/local/bin/*.sh
 
    echo
  fi
}

install_wallpapers() {
  if [ -e ${FILES_SRC_DIR}/wallpapers.tgz ]
  then
    echo -e "${LTBLUE}Installing Wallpapers${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /usr/share -xzf ${FILES_SRC_DIR}/wallpapers.tgz ${NC}"
    ${SUDO_CMD} tar -C /usr/share -xzf ${FILES_SRC_DIR}/wallpapers.tgz 
 
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.png${NC}"
    ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.png
 
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.jpg${NC}"
    ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.jpg
 
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown root.root /usr/share/gnome-background-properties/*.xml${NC}"
    ${SUDO_CMD} chown root.root /usr/share/gnome-background-properties/*.xml
 
    echo
  fi
}

install_user_environment() {
  echo -e "${LTBLUE}Installing User Environments${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  USER_LIST=tux
  USERS_GROUP=users

  echo -e "${LTCYAN}/etc/skel/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  # GNOME
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} mkdir -p /etc/skel/.local/share/gnome-shell/extensions${NC}"
    mkdir -p /etc/skel/.local/share/gnome-shell/extensions
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /etc/skel/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.tgz${NC}"
  ${SUDO_CMD} tar -C /etc/skel/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.tgz
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} mkdir -p /etc/skel/.config/dconf${NC}"
  mkdir -p /etc/skel/.config/dconf
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user /etc/skel/.config/dconf/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user /etc/skel/.config/dconf/

  # XFCE4
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

  # mime
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /etc/skel/.config/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /etc/skel/.config/

  echo

  echo -e "${LTCYAN}/root/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  # GNOME
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} mkdir -p /root/.local/share/gnome-shell/extensions${NC}"
    mkdir -p /root/.local/share/gnome-shell/extensions
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /root/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.tgz${NC}"
  ${SUDO_CMD} tar -C /root/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.tgz
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} mkdir -p /root/.config/dconf${NC}"
  mkdir -p /root/.config/dconf
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user /root/.config/dconf/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user /root/.config/dconf/

  # XFCE4
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

  # mime
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /root/.config/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /root/.config/

  echo

  for USER in ${USER_LIST}
  do
    echo -e "${LTCYAN}/home/${USER}/:${NC}"
    echo -e "${LTCYAN}----------------------${NC}"
    # GNOME
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} mkdir -p /home/${USER}/.local/share/gnome-shell/extensions${NC}"
    mkdir -p /home/${USER}/.local/share/gnome-shell/extensions
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /home/${USER}/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.tgz${NC}"
    ${SUDO_CMD} tar -C /home/${USER}/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.tgz
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} mkdir -p /home/${USER}/.config/dconf${NC}"
    mkdir -p /home/${USER}/.config/dconf
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user /home/${USER}/.config/dconf/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/user /home/${USER}/.config/dconf/
    # XFCE4
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
    ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
    ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz
    # mime
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /home/${USER}/.config/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /home/${USER}/.config/

    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.local${NC}"
    ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.local
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.config${NC}"
    ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.config

    echo
  done
}

configure_displaymanager() {
  echo -e "${LTBLUE}Configure the Display Manager${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  echo -e "${LTCYAN}DISPLAYMANAGER_XSERVER="Xorg"${NC}"
  ${SUDO_CMD} sed -i 's/^DISPLAYMANAGER_XSERVER=.*/DISPLAYMANAGER_XSERVER="Xorg"/' /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DISPLAYMANAGER="gdm"${NC}"
  ${SUDO_CMD} sed -i 's/^DISPLAYMANAGER=.*/DISPLAYMANAGER="gdm"/' /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DISPLAYMANAGER_STARTS_XSERVER="yes"${NC}"
  ${SUDO_CMD} sed -i 's/^DISPLAYMANAGER_STARTS_XSERVER=.*/DISPLAYMANAGER_STARTS_XSERVER="yes"/' /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DEFAULT_WM="gnome"${NC}"
  ${SUDO_CMD} sed -i 's/^DEFAULT_WM=.*/DEFAULT_WM="gnome"/' /etc/sysconfig/displaymanager

  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDU_CMD} update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/gdm ${NC}"
  ${SUDU_CMD} update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/gdm 
  echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDU_CMD} update-alternatives --set default-xsession.desktop /usr/share/xsessions/gnome.desktop${NC}"
  ${SUDU_CMD} update-alternatives --set default-xsession.desktop /usr/share/xsessions/gnome.desktop
 
  echo
}

enable_services() {
  echo -e "${LTBLUE}Enabling/Starting Services${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for SERVICE in ${ENABLED_SERVICES_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
    ${SUDO_CMD} systemctl enable ${SERVICE}

    echo -e "${LTGREEN}COMMAND:${GRAY}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
    ${SUDO_CMD} systemctl restart ${SERVICE}

   echo
  done
}

#############################################################################

main() {
  if ! echo ${*} | grep -q nocolor
  then
    set_colors
  fi

  if which sudo > /dev/null
  then
    if [ "$(whoami)" = root ]
    then
      SUDO_CMD=
    else
      SUDO_CMD="sudo"
    fi
  else
    if [ "$(whoami)" = root ]
    then
      SUDO_CMD=
    else
      echo
      echo -e "${LTRED}ERROR: You must be root (or have sudo installed) to run this command. Exiting ${NC}"
      echo
      exit 1
    fi

    
  fi

  echo -e "${LTBLUE}########################################################################${NC}"
  echo -e "${LTBLUE}                Configuring Machine As a Lab Machine${NC}"
  echo -e "${LTBLUE}########################################################################${NC}"
  echo

  configure_sudo
  add_zypper_repos
  refresh_zypper_repos
  install_zypper_patterns
  install_zypper_packages
  install_extra_rpms
  install_modprobe_config
  configure_libvirt
  install_labmachine_scripts
  install_wallpapers
  install_user_environment
  configure_displaymanager
  enable_services
}

#############################################################################

time main ${*}

