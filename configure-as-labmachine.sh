#!/bin/bash
# version: 2.3.0
# date: 2022-05-19

CONFIG_DIR="./config"
INCLUDE_DIR="./include"

normalize_distro_names() {
  case ${ID} in
    sles)
      DISTRO_TYPE=SLE_
      DISTRO_NAME=SLE_$(echo ${VERSION} | sed 's/-/_/g')
      DISTRO_VERSION=$(echo ${VERSION} | sed 's/-/_/g')
    ;;
    *)
      if echo ${PRETTY_NAME} | grep -iq beta
      then
        DISTRO_NAME=$(echo ${PRETTY_NAME} | sed 's/ /_/g' | sed 's/_Beta//g' | sed 's/_beta//g')
        DISTRO_VERSION=${VERSION}
      else
        DISTRO_NAME=$(echo ${PRETTY_NAME} | sed 's/ /_/g')
        DISTRO_VERSION=${VERSION}
      fi
    ;;
  esac
}

source /etc/os-release
normalize_distro_names

source ${CONFIG_DIR}/configure-as-labmachine.cfg
source ${INCLUDE_DIR}/*.sh

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
  #echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${NC}"
}

usage() {
  echo
  echo "USAGE: ${1} [base_env-only] [user_env-only] [packages-only] [tools-only] [libvirt-only] [vbox-only] [install-insync] [install-teams] [no_restart_gui] [nocolor] [stepthrough]"
  echo
  exit
}

pause_for_stepthrough() {
  echo -e "${ORANGE}Press [Enter] to continue${NC}"
  read
  echo
}

add_zypper_repos() {
  echo -e "${LTBLUE}Adding zypper repositories${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  if ! grep -q "dl.google.com" /etc/zypp/repos.d/*.repo
  then
    echo -e "${LTCYAN}google-chrome${NC}"
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome${NC}"
    ${SUDO_CMD} zypper addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
    if ! [ -e ${FILES_SRC_DIR}/linux_signing_key.pub ]
    then
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cd ${FILES_SRC_DIR}${NC}"
      ${SUDO_CMD} cd ${FILES_SRC_DIR}
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} wget https://dl.google.com/linux/linux_signing_key.pub${NC}"
      ${SUDO_CMD} wget https://dl.google.com/linux/linux_signing_key.pub
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} rpm --import linux_signing_key.pub${NC}"
      ${SUDO_CMD} rpm --import linux_signing_key.pub
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cd -${NC}"
      ${SUDO_CMD} cd - > /dev/null
    fi
  fi

  for REPO in ${ZYPPER_REPO_LIST}
  do
    REPO_URL="$(echo ${REPO} | cut -d , -f 1)"
    REPO_NAME="$(echo ${REPO} | cut -d , -f 2)"

    echo -e "${LTCYAN}${REPO_NAME}${NC}"
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper removerepo ${REPO_URL} ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper removerepo ${REPO_URL} ${REPO_NAME}
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper addrepo ${REPO_URL} ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper addrepo ${REPO_URL} ${REPO_NAME}
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper modifyrepo -e -F ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper modifyrepo -e -F ${REPO_NAME}
  done

  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

refresh_zypper_repos() {
  echo -e "${LTBLUE}Refreshing zypper repos${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper --no-gpg-checks --gpg-auto-import-keys ref${NC}"
  ${SUDO_CMD} zypper --gpg-auto-import-keys ref
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_patterns() {
  echo -e "${LTBLUE}Installing zypper patterns${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for PATTERN in ${ZYPPER_PATTERN_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper -n --no-refresh install -t ${PATTERN}${NC}"
    ${SUDO_CMD} zypper -n --no-refresh install -t pattern ${PATTERN}
  done
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_packages() {
  echo -e "${LTBLUE}Installing zypper packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for PACKAGE in ${ZYPPER_PACKAGE_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper -n --no-refresh install -l ${PACKAGE}${NC}"
    ${SUDO_CMD} zypper -n --no-refresh install -l ${PACKAGE}
  done
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_custom_remote_zypper_packages() {
  echo -e "${LTBLUE}Installing custom remote zypper packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if ! [ -z ${CUSTOM_REMOTE_ZYPPER_PACKAGES} ]
  then
    echo -e "${LTBLUE}Installing custom remote zypper packages${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
    for PACKAGE in ${CUSTOM_REMOTE_PACKAGE_LIST}
    do
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper -n --no-refresh install -l ${PACKAGE}${NC}"
      ${SUDO_CMD} zypper -n --no-refresh install -l ${PACKAGE}
    done
    echo
  else
    echo -e "${LTCYAN}(No custom zypper remote packages found)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_extra_rpms() {
  echo -e "${LTBLUE}Installing custom RPM packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if ls ${RPM_SRC_DIR} | grep -q ".rpm"
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} rpm -U ${RPM_SRC_DIR}/*.rpm${NC}"
    ${SUDO_CMD} rpm -U ${RPM_SRC_DIR}/*.rpm
    echo
  else
    echo -e "${LTCYAN}(No custom RPM packages found)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

remove_zypper_packages() {
  echo -e "${LTBLUE}Removing zypper packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for PACKAGE in ${ZYPPER_REMOVE_PACKAGE_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper -n --no-refresh remove -l ${PACKAGE}${NC}"
    ${SUDO_CMD} zypper -n --no-refresh remove -l ${PACKAGE}
  done
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

configure_sudo() {
  echo -e "${LTBLUE}Configuring sudo${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if ! which sudo > /dev/null
  then
    echo -e "${LTCYAN}sudo Not Installed.  Installing ...${NC}"
    refresh_zypper_repos
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  zypper -n --no-refresh install sudo${NC}"
    zypper -n --no-refresh install sudo
    echo
  fi

  if ! ${SUDO_CMD} sh -c 'grep -q "^%users ALL=(ALL) NOPASSWD: ALL" /etc/sudoers'
  then
    echo -e "${LTCYAN}Adding: ${LTGRAY}%users  ALL=(ALL) NOPASSWD: ALL${NC}"
    ${SUDO_CMD} sh -c 'echo "%users ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
  fi

  if ${SUDO_CMD} sh -c 'grep -q "^Defaults targetpw .*" /etc/sudoers'
  then
    echo -e "${LTCYAN}Updating: ${LTGRAY}#Defaults targetpw${NC}"
    ${SUDO_CMD} sh -c 'sed  -i "s/\(^Defaults targetpw .*\)/\#\1/" /etc/sudoers'
  fi

  if ${SUDO_CMD} sh -c 'grep -q "^ALL .*" /etc/sudoers'
  then
    echo -e "${LTCYAN}Updating: ${LTGRAY}#ALL  ALL=(ALL) ALL${NC}"
    ${SUDO_CMD} sh -c 'sed -i "s/\(^ALL .*\)/\#\1/" /etc/sudoers'
  fi
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_modprobe_config() {
  echo -e "${LTBLUE}Installing modprobe configuration${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if ! [ -e /etc/modprobe.d/50-kvm.conf ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/50-kvm.conf /etc/modprobe.d${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/50-kvm.conf /etc/modprobe.d
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /etc/modprobe.d/*${NC}"
    ${SUDO_CMD} chown root.root /etc/modprobe.d/*
    echo
  else
    echo -e "${LTCYAN}(Modprobe configuration found)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

configure_libvirt() {
  echo -e "${LTBLUE}Configuring Libvirt${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  # Change to UNIX socket based access and authorization
  echo -e "${LTCYAN}/etc/libvirt/libvirtd.conf:${NC}"
  echo -e "${LTCYAN}unix_sock_group = \"libvirt\"${NC}"
  ${SUDO_CMD} sed -i 's/^#unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
  ${SUDO_CMD} sed -i 's/^unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf

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
  # Enable VM susepend on shutdown and resume on power on
  echo -e "${LTCYAN}/etc/sysconfig/libvirt-guests:${NC}"
  echo -e "${LTCYAN}ON_BOOT=start${NC}"
  ${SUDO_CMD} sed -i 's/^#ON_BOOT.*/ON_BOOT=start/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^ON_BOOT.*/ON_BOOT=start/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}/etc/sysconfig/libvirt-guests:${NC}"
  echo -e "${LTCYAN}START_DELAY=0${NC}"
  ${SUDO_CMD} sed -i 's/^#START_DELAY.*/START_DELAY=0/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^START_DELAY.*/START_DELAY=0/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}/etc/sysconfig/libvirt-guests:${NC}"
  echo -e "${LTCYAN}ON_SHUTDOWN=suspend${NC}"
  ${SUDO_CMD} sed -i 's/^#ON_SHUTDOWN.*/ON_SHUTDOWN=suspend/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^ON_SHUTDOWN.*/ON_SHUTDOWN=suspend/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}/etc/sysconfig/libvirt-guests:${NC}"
  echo -e "${LTCYAN}PARALLEL_SHUTDOWN=20${NC}"
  ${SUDO_CMD} sed -i 's/^#PARALLEL_SHUTDOWN.*/PARALLEL_SHUTDOWN=20/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^PARALLEL_SHUTDOWN.*/PARALLEL_SHUTDOWN=20/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}/etc/sysconfig/libvirt-guests:${NC}"
  echo -e "${LTCYAN}BYPASS_CACHE=0${NC}"
  ${SUDO_CMD} sed -i 's/^#BYPASS_CACHE.*/BYPASS_CACHE=0/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^BYPASS_CACHE.*/BYPASS_CACHE=0/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}/etc/sysconfig/libvirt-guests:${NC}"
  echo -e "${LTCYAN}SYNC_TIME=1${NC}"
  ${SUDO_CMD} sed -i 's/^#SYNC_TIME.*/SYNC_TIME=1/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^SYNC_TIME.*/SYNC_TIME=1/' /etc/sysconfig/libvirt-guests

  echo

  if [ -e ${FILES_SRC_DIR}/libvirt.sh ]
  then
    # Libvirt shell profile
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt.sh /etc/profile.d/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt.sh /etc/profile.d/
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /etc/profile.d/libvirt.sh${NC}"
    ${SUDO_CMD} chown root.root /etc/profile.d/libvirt.sh
 
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_labmachine_scripts() {
  echo -e "${LTBLUE}Installing Labmachine Scripts${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if [ -e ${FILES_SRC_DIR}/labmachine_scripts.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C / -xzf ${FILES_SRC_DIR}/labmachine_scripts.tgz ${NC}"
    ${SUDO_CMD} tar -C / -xzf ${FILES_SRC_DIR}/labmachine_scripts.tgz 
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /usr/local/bin/*.sh${NC}"
    ${SUDO_CMD} chown root.root /usr/local/bin/*.sh
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chmod +rx /usr/local/bin/*.sh${NC}"
    ${SUDO_CMD} chmod +rx /usr/local/bin/*.sh
 
    echo
  else
    echo -e "${LTCYAN}(No Labmachine Scripts found)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_image_building_tools() {
  echo -e "${LTBLUE}Installing Image Building Tools${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if [ -e ${FILES_SRC_DIR}/image_building.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /opt -xzf ${FILES_SRC_DIR}/image_building.tgz ${NC}"
    ${SUDO_CMD} tar -C /opt -xzf ${FILES_SRC_DIR}/image_building.tgz 
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /opt/image_building${NC}"
    ${SUDO_CMD} chown root.root /opt/image_building
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chmod +rx /opt/image_building/*.sh${NC}"
    ${SUDO_CMD} chmod +rx /opt/image_building/*.sh
 
    echo
  else
    echo -e "${LTCYAN}(No Image Building Tools found)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

create_default_dirs() {
  echo -e "${LTBLUE}Creating Default Directories${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /install/courses${NC}"
  ${SUDO_CMD} mkdir -p /install/courses
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R .users /install/courses${NC}"
  ${SUDO_CMD} chown -R .users /install/courses
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chmod -R 2777 /install/courses${NC}"
  ${SUDO_CMD} chmod -R 2777 /install/courses

  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /install/courses_shared${NC}"
  ${SUDO_CMD} mkdir -p /install/courses_shared
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R .users /install/courses_shared${NC}"
  ${SUDO_CMD} chown -R .users /install/courses_shared
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chmod -R 2777 /install/courses_shared${NC}"
  ${SUDO_CMD} chmod -R 2777 /install/courses_shared

  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /home/VMs${NC}"
  ${SUDO_CMD} mkdir -p /home/VMs
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R .users /home/VMs${NC}"
  ${SUDO_CMD} chown -R .users /home/VMs
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chmod -R 2777 /home/VMs${NC}"
  ${SUDO_CMD} chmod -R 2777 /home/VMs

  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /home/iso${NC}"
  ${SUDO_CMD} mkdir -p /home/iso
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R .users /home/iso${NC}"
  ${SUDO_CMD} chown -R .users /home/iso
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chmod -R 2777 /home/iso${NC}"
  ${SUDO_CMD} chmod -R 2777 /home/iso
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_wallpapers() {
  echo -e "${LTBLUE}Installing Wallpapers${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if [ -e ${FILES_SRC_DIR}/wallpapers.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /usr/share -xzf ${FILES_SRC_DIR}/wallpapers.tgz ${NC}"
    ${SUDO_CMD} tar -C /usr/share -xzf ${FILES_SRC_DIR}/wallpapers.tgz 
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.png${NC}"
    ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.png
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.jpg${NC}"
    ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.jpg
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /usr/share/gnome-background-properties/*.xml${NC}"
    ${SUDO_CMD} chown root.root /usr/share/gnome-background-properties/*.xml
 
    echo
  else
    echo -e "${LTCYAN}(No Wallpapers found)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_libreoffice_color_palettes() {
  echo -e "${LTBLUE}Installing LibreOffice Color palettes${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  if ls ${FILES_SRC_DIR}/ | grep -q ".soc"
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/*.soc /usr/lib64/libreoffice/share/palette/ ${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/*.soc /usr/lib64/libreoffice/share/palette/
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown root.root /usr/lib64/libreoffice/share/palette/*${NC}"
    ${SUDO_CMD} chown root.root /usr/lib64/libreoffice/share/palette/*
 
    echo
  else
    echo -e "${LTCYAN}(No LibreOffice color palettes found)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_user_environment() {
  echo -e "${LTBLUE}Installing User Environments${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  echo -e "${LTCYAN}/etc/dconf/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /etc/ -xzf ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz${NC}"
    ${SUDO_CMD} tar -C /etc/ -xzf ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} dconf update${NC}"
    ${SUDO_CMD} dconf update
  fi

  echo

  echo -e "${LTCYAN}/etc/polkit-default-privs.local${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  #echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sed -i 's/org.freedesktop.packagekit.system-sources-refresh.*/org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes/' /etc/polkit-default-privs.standard${NC}"
  #${SUDO_CMD} sed -i 's/org.freedesktop.packagekit.system-sources-refresh.*/org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes/' /etc/polkit-default-privs.standard
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} echo org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes >> /etc/polkit-default-privs.local${NC}"
  ${SUDO_CMD} echo org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes >> /etc/polkit-default-privs.local
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} set_polkit_default_privs${NC}"
  ${SUDO_CMD} set_polkit_default_privs

  echo

  echo -e "${LTCYAN}/etc/skel/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  # Xsession
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /etc/skel/.xsession >> /etc/skel/.xsession'${NC}"
  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /etc/skel/.xsession >> /etc/skel/.xsession'
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sh -c \'echo \"gnome-session\" >> /etc/skel/.xsession\'${NC}"
  ${SUDO_CMD} sh -c 'echo "gnome-session" >> /etc/skel/.xsession'

  # GNOME
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /etc/skel/.local/share/gnome-shell/extensions${NC}"
  ${SUDO_CMD} mkdir -p /etc/skel/.local/share/gnome-shell/extensions
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /etc/skel/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz${NC}"
  ${SUDO_CMD} tar -C /etc/skel/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz
  if ! [ -e /etc/skel/.config ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /etc/skel/.config${NC}"
    ${SUDO_CMD} mkdir -p /etc/skel/.config
  fi
  if [ -e ${FILES_SRC_DIR}/user.${DISTRO_NAME} ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /etc/skel/.config/dconf${NC}"
    ${SUDO_CMD} mkdir -p /etc/skel/.config/dconf
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /etc/skel/.config/dconf/user${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /etc/skel/.config/dconf/user
  fi
  if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} rm -f /etc/skel/.config/dconf/user${NC}"
    ${SUDO_CMD} rm -f /etc/skel/.config/dconf/user
  fi

  # XFCE4
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

  # mime
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /etc/skel/.config/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /etc/skel/.config/

  # Vim
  if ! grep -q "set noautoindent" /etc/skel/.vimrc
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sh -c 'echo \"set noautoindent\" >> /etc/skel/.vimrc'${NC}"
    ${SUDO_CMD} sh -c 'echo "set noautoindent" >> /etc/skel/.vimrc'
  fi

  echo

  echo -e "${LTCYAN}/root/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  # Xsession
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /root/.xsession >> /root/.xsession'${NC}"
  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /root/.xsession >> /root/.xsession'
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sh -c \'echo \"gnome-session\" >> /root/.xsession\'${NC}"
  ${SUDO_CMD} sh -c 'echo "gnome-session" >> /root/.xsession'

  # GNOME
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /root/.local/share/gnome-shell/extensions${NC}"
  ${SUDO_CMD} mkdir -p /root/.local/share/gnome-shell/extensions
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /root/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz${NC}"
  ${SUDO_CMD} tar -C /root/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz
  if ! [ -e /root/.config ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /root/.config${NC}"
    ${SUDO_CMD} mkdir -p /root/.config
  fi
  if [ -e ${FILES_SRC_DIR}/user.${DISTRO_NAME} ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /root/.config/dconf${NC}"
    ${SUDO_CMD} mkdir -p /root/.config/dconf
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /root/.config/dconf/user${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /root/.config/dconf/user
  fi
  if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} rm -f /root/.config/dconf/user${NC}"
    ${SUDO_CMD} rm -f /root/.config/dconf/user
  fi

  # XFCE4
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

  # mime
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /root/.config/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /root/.config/

  # Vim
  if ! grep -q "set noautoindent" /root/.vimrc
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sh -c 'echo \"set noautoindent\" >> /root/.vimrc'${NC}"
    ${SUDO_CMD} sh -c 'echo "set noautoindent" >> /root/.vimrc'
  fi

  echo

  for USER in ${USER_LIST}
  do
    echo -e "${LTCYAN}/home/${USER}/:${NC}"
    echo -e "${LTCYAN}----------------------${NC}"
    # Xsession
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sed -i /gnome-session/d /home/${USER}/.xsession >> /home/${USER}/.xsession${NC}"
    ${SUDO_CMD} sed -i /gnome-session/d /home/${USER}/.xsession >> /home/${USER}/.xsession
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} echo \"gnome-session\" >> /home/${USER}/.xsession${NC}"
    ${SUDO_CMD} echo "gnome-session" >> /home/${USER}/.xsession

    # GNOME
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /home/${USER}/.local/share/gnome-shell/extensions${NC}"
    ${SUDO_CMD} mkdir -p /home/${USER}/.local/share/gnome-shell/extensions
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /home/${USER}/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz${NC}"
    ${SUDO_CMD} tar -C /home/${USER}/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz
    if ! [ -e /home/${USER}/.config ]
    then
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /home/${USER}/.config${NC}"
      ${SUDO_CMD} mkdir -p /home/${USER}/.config
    fi
    if [ -e ${FILES_SRC_DIR}/user.${DISTRO_NAME} ]
    then
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /home/${USER}/.config/dconf${NC}"
      ${SUDO_CMD} mkdir -p /home/${USER}/.config/dconf
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /home/${USER}/.config/dconf/user${NC}"
      ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /home/${USER}/.config/dconf/user
    fi
    if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
    then
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} rm -f /home/${USER}/.config/dconf/user${NC}"
      ${SUDO_CMD} rm -f /home/${USER}/.config/dconf/user
    fi

    # XFCE4
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
    ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
    ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

    # mime
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /home/${USER}/.config/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /home/${USER}/.config/

    # Vim
    if ! grep -q "set noautoindent" /home/${USER}/.vimrc
    then
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} sh -c \"echo set noautoindent >> /home/${USER}/.vimrc\"${NC}"
      ${SUDO_CMD} sh -c "echo set noautoindent >> /home/${USER}/.vimrc"
    fi

    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}${NC}"
    ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}
    #echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.local${NC}"
    #${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.local
    #echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.config${NC}"
    #${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.config

    echo

    for SECONDARY_GROUP in ${USERS_SECONDARY_GROUPS}
    do
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} usermod -aG ${SECONDARY_GROUP} ${USER}${NC}"
      ${SUDO_CMD} usermod -aG ${SECONDARY_GROUP} ${USER}
    done
    echo
  done

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

configure_displaymanager() {
  echo -e "${LTBLUE}Configure the Display Manager${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  echo -e "${LTCYAN}DISPLAYMANAGER_XSERVER="Xorg"${NC}"
  ${SUDO_CMD} sed -i 's/^DISPLAYMANAGER_XSERVER=.*/DISPLAYMANAGER_XSERVER="Xorg"/' /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DISPLAYMANAGER=\"${DEFAULT_DISPLAYMANAGER}\"${NC}"
  ${SUDO_CMD} sed -i "s/^DISPLAYMANAGER=.*/DISPLAYMANAGER=\"${DEFAULT_DISPLAYMANAGER}\"/" /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DISPLAYMANAGER_STARTS_XSERVER="yes"${NC}"
  ${SUDO_CMD} sed -i 's/^DISPLAYMANAGER_STARTS_XSERVER=.*/DISPLAYMANAGER_STARTS_XSERVER="yes"/' /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DEFAULT_WM="${DEFAULT_XSESSION}"${NC}"
  ${SUDO_CMD} sed -i "s/^DEFAULT_WM=.*/DEFAULT_WM=\"${DEFAULT_XSESSION}\"/" /etc/sysconfig/displaymanager

  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/${DEFAULT_DISPLAYMANAGER} ${NC}"
  ${SUDO_CMD} update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/${DEFAULT_DISPLAYMANAGER} 
  echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} update-alternatives --set default-xsession.desktop /usr/share/xsessions/${DEFAULT_XSESSION}.desktop${NC}"
  ${SUDO_CMD} update-alternatives --set default-xsession.desktop /usr/share/xsessions/${DEFAULT_XSESSION}.desktop
 
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

update_virtualbox_extensions() {
  echo -e "${LTBLUE}Installing Virtualbox Extension Pack${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  if ! rpm -qa | grep -q virtualbox
  then
    if echo ${*} | grep -q install-vbox
    then
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper -n --no-refresh install -l --allow-unsigned-rpm virtualbox-qt${NC}"
      ${SUDO_CMD} zypper -n --no-refresh install -l --allow-unsigned-rpm virtualbox-qt
      echo
    fi
  fi

  if rpm -qa | grep -q virtualbox
  then
    VBOX_VER="$(rpm -q virtualbox | cut -d \- -f 2)"
 
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} wget https://download.virtualbox.org/virtualbox/${VBOX_VER}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VER}.vbox-extpack${NC}"
    ${SUDO_CMD} wget https://download.virtualbox.org/virtualbox/${VBOX_VER}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VER}.vbox-extpack
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  echo y | ${SUDO_CMD} /usr/bin/VBoxManage extpack install --replace *.vbox-extpack${NC}"
    echo y | ${SUDO_CMD} /usr/bin/VBoxManage extpack install --replace *.vbox-extpack
    echo
  else
    echo -e "${LTCYAN}(Virtualbox not installed)${NC}"
    echo
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_atom_editor() {
  echo -e "${LTBLUE}Installing the Atom Editor${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  if ! grep -q "packagecloud.io/AtomEditor" /etc/zypp/repos.d/*.repo
  then
    ${SUDO_CMD} sh -c 'echo -e "[Atom]\nname=Atom Editor\nbaseurl=https://packagecloud.io/AtomEditor/atom/el/7/\$basearch\nenabled=1\ntype=rpm-md\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey" > /etc/zypp/repos.d/atom.repo'
    echo -e "${LTGREEN}COMMAND:${LTGRAY} zypper --gpg-auto-import-keys refresh${NC}"
    ${SUDO_CMD} zypper --gpg-auto-import-keys refresh
  fi

  if zypper se atom | grep -q "A hackable text editor"
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper -n --no-refresh install -l --allow-unsigned-rpm atom${NC}"
    ${SUDO_CMD} zypper -n --no-refresh install -l --allow-unsigned-rpm atom
  else
    echo -e "${LTGREEN}COMMAND:${LTGRAY} cd ${RPM_SRC_DIR}/${NC}"
    cd ${RPM_SRC_DIR}/
    echo -e "${LTGREEN}COMMAND:${LTGRAY} wget https://atom.io/rpm${NC}"
    wget https://atom.io/rpm
    echo -e "${LTGREEN}COMMAND:${LTGRAY} mv ./rpm ./atom.rpm${NC}"
    mv ./rpm ./atom.rpm
    cd -
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper -n --no-refresh install -l --allow-unsigned-rpm ${RPM_SRC_DIR}/atom.rpm${NC}"
    ${SUDO_CMD} zypper -n --no-refresh install -l --allow-unsigned-rpm ${RPM_SRC_DIR}/atom.rpm
    echo -e "${LTGREEN}COMMAND:${LTGRAY} ${SUDO_CMD} rm -f  ${RPM_SRC_DIR}/atom.rpm${NC}"
    ${SUDO_CMD} rm -f  ${RPM_SRC_DIR}/atom.rpm
  fi

  echo

  if [ -e ${FILES_SRC_DIR}/atom-packages.tgz ]
  then
    echo -e "${LTBLUE}Installing the Atom Editor add-on packages${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
 
    echo -e "${LTCYAN}/etc/skel/:${NC}"
    echo -e "${LTCYAN}----------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /etc/skel/.atom/packages/${NC}"
    ${SUDO_CMD} mkdir -p /etc/skel/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages/
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /etc/skel/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz${NC}"
    ${SUDO_CMD} tar -C /etc/skel/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz
 
    echo -e "${LTCYAN}/root/:${NC}"
    echo -e "${LTCYAN}----------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /root/.atom/packages/${NC}"
    ${SUDO_CMD} mkdir -p /root/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages/
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /root/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz${NC}"
    ${SUDO_CMD} tar -C /root/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz
 
    for USER in ${USER_LIST}
    do
      echo -e "${LTCYAN}/home/${USER}/:${NC}"
      echo -e "${LTCYAN}----------------------${NC}"
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} mkdir -p /home/${USER}/.atom/packages/${NC}"
      ${SUDO_CMD} mkdir -p /home/${USER}/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages/
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} tar -C /home/${USER}/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz${NC}"
      ${SUDO_CMD} tar -C /home/${USER}/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz

      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}${NC}"
      ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}thoughs
      done
  fi
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_teams() {
  echo -e "${LTBLUE}Installing Microsoft Teams${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  if ! grep -q "packages.microsoft.com/yumrepos/ms-teams" /etc/zypp/repos.d/*.repo
  then
    ${SUDO_CMD} sh -c 'echo -e "[teams]\nname=teams\nenabled=1\nautorefresh=0\nbaseurl=https://packages.microsoft.com/yumrepos/ms-teams\ntype=rpm-md\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\nkeeppackages=0" > /etc/zypp/repos.d/teams.repo'
    echo -e "${LTGREEN}COMMAND:${LTGRAY} zypper --gpg-auto-import-keys refresh${NC}"
    ${SUDO_CMD} zypper --gpg-auto-import-keys refresh
  fi

  if zypper se teams | grep -q "Microsoft Teams for Linux is your chat-centered workspace in Office 365"
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper --non-interactive --no-refresh install -l --allow-unsigned-rpm teams${NC}"
    ${SUDO_CMD} zypper --non-interactive --no-refresh install -l --allow-unsigned-rpm teams
  fi
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zoom() {
  echo -e "${LTBLUE}Installing Zoom${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  echo -e "${LTGREEN}COMMAND:${LTGRAY} ${SUDO_CMD} rpm --import https://zoom.us/linux/download/pubkey${NC}"
  ${SUDO_CMD} rpm --import https://zoom.us/linux/download/pubkey
  echo -e "${LTGREEN}COMMAND:${LTGRAY} ${SUDO_CMD} zypper --non-interactive --no-refresh install -l --allow-unsigned-rpm https://zoom.us/client/latest/zoom_openSUSE_x86_64.rpm ${NC}"
  ${SUDO_CMD} zypper --non-interactive --no-refresh install -l --allow-unsigned-rpm https://zoom.us/client/latest/zoom_openSUSE_x86_64.rpm 

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_insync() {
  echo -e "${LTBLUE}Installing Insync${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  if ! grep -q "yum.insync.io/fedora/27" /etc/zypp/repos.d/*.repo
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY} zypper ar http://yum.insync.io/fedora/27/ insync${NC}"
    ${SUDO_CMD} zypper ar http://yum.insync.io/fedora/27/ insync
    echo -e "${LTGREEN}COMMAND:${LTGRAY} zypper --gpg-auto-import-keys refresh${NC}"
    ${SUDO_CMD} zypper --gpg-auto-import-keys refresh
  fi

  if zypper se insync | grep -q "| insync "
  then
    echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} zypper --non-interactive --no-refresh install -l --allow-unsigned-rpm insync${NC}"
    ${SUDO_CMD} zypper --non-interactive --no-refresh install -l --allow-unsigned-rpm insync
  fi 
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

enable_services() {
  echo -e "${LTBLUE}Enabling/Starting Services${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for SERVICE in ${ENABLED_SERVICES_LIST}
  do
    if echo ${*} | grep -q no_restart_gui
    then
      if ! echo ${SERVICE} | grep -q display-manager
      then
        echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl enable ${SERVICE}
  
        echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl restart ${SERVICE}
      fi
    else
      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl enable ${SERVICE}

      echo -e "${LTGREEN}COMMAND:${LTGRAY}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl restart ${SERVICE}
    fi
   echo
  done
}

#############################################################################

main() {
  if ! echo ${*} | grep -q nocolor
  then
    set_colors
  fi

  if echo ${*} | grep -q "help"
  then
    usage
  fi

  if echo ${*} | grep -q stepthrough
  then
    STEPTHROUGH="Y"
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
  echo -e "${LTBLUE}                ${NC}"
  echo -e "${LTBLUE}                Distribution: ${DISTRO_NAME}${NC}"
  echo -e "${LTBLUE}########################################################################${NC}"
  echo
  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac

  if echo ${*} | grep -q base_env-only
  then
    configure_sudo
    create_default_dirs
    install_wallpapers
    install_libreoffice_color_palettes
  elif echo ${*} | grep -q packages-only
  then
    add_zypper_repos
    refresh_zypper_repos
    install_zypper_patterns
    install_zypper_packages
    install_custom_remote_zypper_packages
    remove_zypper_packages
    install_extra_rpms
    install_atom_editor
  elif echo ${*} | grep -q tools-only
  then
    install_labmachine_scripts
    install_image_building_tools
  elif echo ${*} | grep -q libvirt-only
  then
    install_modprobe_config
    configure_libvirt
  elif echo ${*} | grep -q vbox-only
  then
    update_virtualbox_extensions ${*}
  elif echo ${*} | grep -q user_env-only
  then
    install_user_environment
    configure_displaymanager
  else
    configure_sudo
    # zypper
    add_zypper_repos
    refresh_zypper_repos
    install_zypper_patterns
    install_zypper_packages
    install_custom_remote_zypper_packages
    remove_zypper_packages
    install_extra_rpms
    install_atom_editor
    # libvirt
    install_modprobe_config
    configure_libvirt
    # tools
    install_labmachine_scripts
    install_image_building_tools
    # vbox
    update_virtualbox_extensions ${*}
    if echo ${*} | grep -q install-teams
    then
      install_teams
    fi
    if echo ${*} | grep -q install-insync
    then
      install_insync
    fi
    # base env
    create_default_dirs
    install_wallpapers
    install_libreoffice_color_palettes
    # user env
    install_user_environment
    configure_displaymanager
    # services
    enable_services
  fi
}

#############################################################################

time main ${*}

