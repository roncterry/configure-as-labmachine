#!/bin/bash
# version: 3.4.0
# date: 2025-03-26

CONFIG_DIR="./config"
INCLUDE_DIR="./include"

normalize_distro_names() {
  case ${ID} in
    sles)
      DISTRO_TYPE=SLE_
      DISTRO_NAME=SLE_$(echo ${VERSION} | sed 's/-/_/g')
      DISTRO_VERSION=$(echo ${VERSION} | sed 's/-/_/g')
    ;;
    opensuse-tumbleweed)
      DISTRO_NAME=$(echo ${PRETTY_NAME} | sed 's/ /_/g')
      DISTRO_VERSION=${DISTRO_NAME}
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
#source ${INCLUDE_DIR}/*.sh

STEPTHROUGH_INITIAL_PAUSE=2

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
  #echo -e "${LTGREEN}COMMAND:${NC}  ${NC}"
}

usage() {
  echo
  echo "USAGE: ${1} [base_env_only] [base_user_env_only] [base_virt_env_only] [base_container_env_only] [base_dev_env_only] [user_env_only] [packages_only] [tools_only] [libvirt_only] [optional_only] custom_only] [install-virtualbox] [install-atom_editor] [install-insync] [install-teams] [install-zoom] [install-edge] [no_restart_gui] [nocolor] [stepthrough]"
  echo
  exit
}

pause_for_stepthrough() {
  echo -e "${ORANGE}Press [Enter] to continue${NC}"
  read
  echo
}

add_zypper_base_repos() {
  echo -e "${LTBLUE}Adding base zypper repositories${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  for REPO in ${ZYPPER_BASE_REPO_LIST}
  do
    REPO_URL="$(echo ${REPO} | cut -d , -f 1)"
    REPO_NAME="$(echo ${REPO} | cut -d , -f 2)"

    echo -e "${LTCYAN}${REPO_NAME}${NC}"
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper removerepo ${REPO_URL} ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper removerepo ${REPO_URL} ${REPO_NAME}
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper addrepo ${REPO_URL} ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper addrepo ${REPO_URL} ${REPO_NAME}
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper modifyrepo -e -F ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper modifyrepo -e -F ${REPO_NAME}
  done

  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

add_zypper_extra_repos() {
  echo -e "${LTBLUE}Adding extra zypper repositories${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  for REPO in ${ZYPPER_EXTRA_REPO_LIST}
  do
    REPO_URL="$(echo ${REPO} | cut -d , -f 1)"
    REPO_NAME="$(echo ${REPO} | cut -d , -f 2)"

    echo -e "${LTCYAN}${REPO_NAME}${NC}"
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper removerepo ${REPO_URL} ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper removerepo ${REPO_URL} ${REPO_NAME}
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper addrepo ${REPO_URL} ${REPO_NAME}${NC}"
    ${SUDO_CMD} zypper addrepo ${REPO_URL} ${REPO_NAME}
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper modifyrepo -e -F ${REPO_NAME}${NC}"
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
  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"

  echo -e "${LTBLUE}Refreshing zypper repos${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_REF_GLOBAL_OPTS} ref${NC}"
  ${SUDO_CMD} zypper ${ZYPPER_REF_GLOBAL_OPTS} ref
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_base_patterns() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-t pattern"

  echo -e "${LTBLUE}Installing base zypper patterns${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PATTERN in ${ZYPPER_BASE_PATTERN_LIST}
  do
    ZYPPER_BASE_PATTERN_INSTALL_LIST="${ZYPPER_BASE_PATTERN_INSTALL_LIST} ${PATTERN}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PATTERN}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PATTERN}
  done
  echo

  if ! [ -z "${ZYPPER_BASE_PATTERN_INSTALL_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_BASE_PATTERN_INSTALL_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_BASE_PATTERN_INSTALL_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_virt_patterns() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-t pattern"

  echo -e "${LTBLUE}Installing virtualization zypper patterns${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PATTERN in ${ZYPPER_VIRT_PATTERN_LIST}
  do
    ZYPPER_VIRT_PATTERN_INSTALL_LIST="${ZYPPER_VIRT_PATTERN_INSTALL_LIST} ${PATTERN}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PATTERN}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PATTERN}
  done
  echo

  if ! [ -z "${ZYPPER_VIRT_PATTERN_INSTALL_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_VIRT_PATTERN_INSTALL_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_VIRT_PATTERN_INSTALL_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_base_packages() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing zypper base system packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PACKAGE in ${ZYPPER_BASE_PACKAGE_LIST}
  do
    ZYPPER_BASE_PACKAGE_INSTALL_LIST="${ZYPPER_BASE_PACKAGE_INSTALL_LIST} ${PACKAGE}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}
  done
  echo

  if ! [ -z "${ZYPPER_BASE_PACKAGE_INSTALL_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_BASE_PACKAGE_INSTALL_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_BASE_PACKAGE_INSTALL_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_virt_packages() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing zypper virtualization packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PACKAGE in ${ZYPPER_VIRT_PACKAGE_LIST}
  do
    ZYPPER_VIRT_PACKAGE_INSTALL_LIST="${ZYPPER_VIRT_PACKAGE_INSTALL_LIST} ${PACKAGE}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}
  done
  echo

  if ! [ -z "${ZYPPER_VIRT_PACKAGE_INSTALL_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_VIRT_PACKAGE_INSTALL_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_VIRT_PACKAGE_INSTALL_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_container_packages() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing zypper container packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PACKAGE in ${ZYPPER_CONTAINER_PACKAGE_LIST}
  do
    ZYPPER_CONTAINER_PACKAGE_INSTALL_LIST="${ZYPPER_CONTAINER_PACKAGE_INSTALL_LIST} ${PACKAGE}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}
  done
  echo

  if ! [ -z "${ZYPPER_CONTAINER_PACKAGE_INSTALL_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_CONTAINER_PACKAGE_INSTALL_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_CONTAINER_PACKAGE_INSTALL_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_remote_access_packages() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing zypper remote access packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PACKAGE in ${ZYPPER_REMOTE_ACCESS_PACKAGE_LIST}
  do
    ZYPPER_REMOTE_ACCESS_PACKAGE_INSTALL_LIST="${ZYPPER_REMOTE_ACCESS_PACKAGE_INSTALL_LIST} ${PACKAGE}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}
  done
  echo

  if ! [ -z "${ZYPPER_REMOTE_ACCESS_PACKAGE_INSTALL_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_REMOTE_ACCESS_PACKAGE_INSTALL_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_REMOTE_ACCESS_PACKAGE_INSTALL_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zypper_dev_packages() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing zypper developoment packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PACKAGE in ${ZYPPER_DEV_PACKAGE_LIST}
  do
    ZYPPER_DEV_PACKAGE_INSTALL_LIST="${ZYPPER_DEV_PACKAGE_INSTALL_LIST} ${PACKAGE}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}
  done

  if zypper lr | grep -iq packman
  then
  echo -e "${LTCYAN}Switching packages to Packman repo${NC}"  
    local PACKMAN_REPO_NAME="$(zypper lr | grep -i packman | cut -d \| -f 2 | awk '{ print $1 }')"
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper dup -l --allow-vendor-change --from ${PACKMAN_REPO_NAME}${NC}"
    ${SUDO_CMD} zypper -n dup -l --allow-vendor-change --from ${PACKMAN_REPO_NAME}
    echo
  fi

  if ! [ -z "${ZYPPER_DEV_PACKAGE_INSTALL_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_DEV_PACKAGE_INSTALL_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${ZYPPER_DEV_PACKAGE_INSTALL_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_custom_remote_zypper_packages() {
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing custom remote zypper packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  echo -e "${RED}WARNING: Manual action may be required to accept packages${NC}"
  echo -e "${RED}         and accept/ignore signing key warnings.${NC}"
  echo -e "${RED}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if ! [ -z "${CUSTOM_REMOTE_ZYPPER_PACKAGES}" ]
  then
    echo -e "${LTBLUE}Installing custom remote zypper packages${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
    for PACKAGE in ${CUSTOM_REMOTE_PACKAGE_LIST}
    do
      CUSTOM_REMOTE_PACKAGE_INSTALL_LIST="${CUSTOM_REMOTE_PACKAGE_INSTALL_LIST} ${PACKAGE}"
      #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}${NC}"
      #${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${PACKAGE}
    done
    echo

    if ! [ -z "${CUSTOM_REMOTE_PACKAGE_INSTALL_LIST}" ]
    then
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${CUSTOM_REMOTE_PACKAGE_INSTALL_LIST}${NC}"
      ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${CUSTOM_REMOTE_PACKAGE_INSTALL_LIST}
    fi
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
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing custom RPM packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  echo -e "${RED}WARNING: Manual action may be required to accept packages${NC}"
  echo -e "${RED}         and accept/ignore signing key warnings.${NC}"
  echo -e "${RED}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if ls ${RPM_SRC_DIR} | grep -q ".rpm"
  then
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} rpm -U ${RPM_SRC_DIR}/*.rpm${NC}"
    #${SUDO_CMD} rpm -U ${RPM_SRC_DIR}/*.rpm
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${RPM_SRC_DIR}/*.rpm${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${RPM_SRC_DIR}/*.rpm
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
  local ZYPPER_REMOVE_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_REMOVE_OPTS="-u"

  echo -e "${LTBLUE}Removing zypper packages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PACKAGE in ${ZYPPER_REMOVE_PACKAGE_LIST}
  do
    ZYPPER_PACKAGE_REMOVE_LIST="${ZYPPER_PACKAGE_REMOVE_LIST} ${PACKAGE}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${PACKAGE}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${PACKAGE}
  done
  echo

  if ! [ -z "${ZYPPER_PACKAGE_REMOVE_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${ZYPPER_PACKAGE_REMOVE_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${ZYPPER_PACKAGE_REMOVE_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

remove_zypper_patterns() {
  local ZYPPER_REMOVE_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_REMOVE_OPTS="-u -t pattern"

  echo -e "${LTBLUE}Removing zypper patterns${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for PATTERN in ${ZYPPER_REMOVE_PATTERN_LIST}
  do
    ZYPPER_PATTERN_REMOVE_LIST="${ZYPPER_PATTERN_REMOVE_LIST} ${PATTERN}"
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${PATTERN}${NC}"
    #${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${PATTERN}
  done
  echo

  if ! [ -z "${ZYPPER_PATTERN_REMOVE_LIST}" ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${ZYPPER_PATTERN_REMOVE_LIST}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_REMOVE_GLOBAL_OPTS} remove ${ZYPPER_REMOVE_OPTS} ${ZYPPER_PATTERN_REMOVE_LIST}
  fi

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_flatpaks() {
  echo -e "${LTBLUE}Installing Flatpaks${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if which flatpak > /dev/null 2>&1
  then

    if ! [ -z ${FLATPAK_REMOTE_LIST} ]
    then
      echo -e "${LTCYAN}Adding Flatpak remotes ...${NC}"
      for FLATPAK_REMOTE in ${FLATPAK_REMOTE_LIST}
      do
        local FLATPAK_REMOTE_NAME="$(echo ${FLATPAK_REMOTE} | cut -d + -f 1)"
        local FLATPAK_REMOTE_URL="$(echo ${FLATPAK_REMOTE} | cut -d + -f 2)"
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} flatpak remote-add --if-not-exists ${FLATPAK_REMOTE_NAME} ${FLATPAK_REMOTE_URL}${NC}"
        ${SUDO_CMD} flatpak remote-add --if-not-exists ${FLATPAK_REMOTE_NAME} ${FLATPAK_REMOTE_URL}
      done
    else
      echo -e "${LTCYAN}(no Flatpak remotes specified)${NC}"
    fi

    if ! [ -z "${FLATPAK_INSTALL_LIST}" ]
    then
      echo -e "${LTCYAN}Installing Flatpaks ...${NC}"
      for FLATPAK in ${FLATPAK_INSTALL_LIST}
      do
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} flatpak install --noninteractive --assumeyes ${FLATPAK}${NC}"
        ${SUDO_CMD} flatpak install --noninteractive --assumeyes ${FLATPAK}
      done
    else
      echo -e "${LTCYAN}(no Flatpaks specified)${NC}"
    fi
  fi
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_appimages() {
  echo -e "${LTBLUE}Configuring AppImages${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  case ${ENABLE_APPIMAGED} in
    Y|y|yes|Yes|YES)
      if ! [ -d ${APPIMAGE_INSTALL_DIR} ]
      then
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p ${APPIMAGE_INSTALL_DIR}${NC}"
        ${SUDO_CMD} mkdir -p ${APPIMAGE_INSTALL_DIR}
        echo -e "${PURPLE}  The AppImage system directory is: ${APPIMAGE_INSTALL_DIR}${NC}"
      fi 

      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${APPIMAGE_SRC_DIR}/*.AppImage ${APPIMAGE_INSTALL_DIR}${NC}"
      ${SUDO_CMD} cp ${APPIMAGE_SRC_DIR}/*.AppImage ${APPIMAGE_INSTALL_DIR}

      for USER in ${USER_LIST}
      do
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD}  systemctl enable --machine=${USER}@.host --user appimaged.service${NC}"
        ${SUDO_CMD} systemctl enable --machine=${USER}@.host --user appimaged.service
      done
    ;;
    *)
      echo -e "${LTCYAN}(appimaged not enabled)${NC}"
      
      if ls ${APPIMAGE_INSTALL_DIR}/*.AppImage > /dev/null 2>&1
      then
        echo -e "${PURPLE}The AppImage daemon is not enabled but there are AppImages available to install/run.${NC}"
        echo
        if ! which AppImageLauncher > /dev/null 2>&1
        then
          echo -e "${PURPLE}You can manually install these AppImages by first installing the AppImageLauncher RPM${NC}"
          echo -e "${PURPLE}from here: https://github.com/TheAssassin/AppImageLauncher/releases${NC}"
          echo -e "${PURPLE}and then double-clicking on each of the *.AppImage files in the ${APPIMAGE_INSTALL_DIR}.${NC}"
          echo -e "${PURPLE}They will then be installed and available for your user.${NC}"
          echo -e "${PURPLE}or${NC}"
          echo -e "${PURPLE}You can manually run these AppImages by double-clicking on the *.AppImage files in${NC}"
          echo -e "${PURPLE}the ${APPIMAGE_INSTALL_DIR} directory.${NC}"
        else
          echo -e "${PURPLE}You can manually install these AppImages by double-clicking on each of the *.AppImage${NC}"
          echo -e "${PURPLE}files in the ${APPIMAGE_INSTALL_DIR} directory.${NC}"
          echo -e "${PURPLE}They will then be installed and available for your user.${NC}"
        fi
      fi
    ;;
  esac
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if ! which sudo > /dev/null
  then
    echo -e "${LTCYAN}sudo Not Installed.  Installing ...${NC}"
    refresh_zypper_repos
    echo -e "${LTGREEN}COMMAND:${NC}  zypper -n --no-refresh install sudo${NC}"
    zypper -n --no-refresh install sudo
    echo
  fi

  if ! ${SUDO_CMD} sh -c 'grep -q "^%users ALL=(ALL) NOPASSWD: ALL" /etc/sudoers'
  then
    echo -e "${LTCYAN}Adding: ${NC}%users  ALL=(ALL) NOPASSWD: ALL${NC}"
    ${SUDO_CMD} sh -c 'echo "%users ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
  fi

  if ! ${SUDO_CMD} sh -c 'grep -q "^%users ALL=(ALL) NOPASSWD: ALL" /etc/sudoers.d/users'
  then
    echo -e "${LTCYAN}Adding to sudoers.d: ${NC}%users  ALL=(ALL) NOPASSWD: ALL${NC}"
    ${SUDO_CMD} sh -c 'echo "%users ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/users'
  fi

  if ${SUDO_CMD} sh -c 'grep -q "^Defaults targetpw .*" /etc/sudoers'
  then
    echo -e "${LTCYAN}Updating: ${NC}#Defaults targetpw${NC}"
    ${SUDO_CMD} sh -c 'sed  -i "s/\(^Defaults targetpw .*\)/\#\1/" /etc/sudoers'
  fi

  if ${SUDO_CMD} sh -c 'grep -q "^ALL .*" /etc/sudoers'
  then
    echo -e "${LTCYAN}Updating: ${NC}#ALL  ALL=(ALL) ALL${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if ! [ -e /etc/modprobe.d/50-kvm.conf ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/50-kvm.conf /etc/modprobe.d${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/50-kvm.conf /etc/modprobe.d
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /etc/modprobe.d/*${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  for ENABLED_VIRT_SERVICE in ${ENABLED_VIRT_SERVICES_LIST}
  do
    ##### Check for and update the Libvirt Daemon config files #####
    if [ -e /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf ]
    then
      # Change to UNIX socket based access and authorization
      echo -e "${LTCYAN}/etc/libvirt/${ENABLED_VIRT_SERVICE}.conf:${NC}"
      echo -e "${LTCYAN}unix_sock_group = \"libvirt\"${NC}"
      ${SUDO_CMD} sed -i 's/^#unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      echo -e "${LTCYAN}unix_sock_ro_perms = \"0777\"${NC}"
      ${SUDO_CMD} sed -i 's/^#unix_sock_ro_perms.*/unix_sock_ro_perms = "0777"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^unix_sock_ro_perms.*/unix_sock_ro_perms = "0777"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      echo -e "${LTCYAN}unix_sock_rw_perms = \"0770\"${NC}"
      ${SUDO_CMD} sed -i 's/^#unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      echo -e "${LTCYAN}unix_sock_admin_perms = \"0700\"${NC}"
      ${SUDO_CMD} sed -i 's/^#unix_sock_admin_perms.*/unix_sock_admin_perms = "0700"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^unix_sock_admin_perms.*/unix_sock_admin_perms = "0700"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      echo -e "${LTCYAN}unix_sock_dir = \"/var/run/libvirt\"/${NC}"
      ${SUDO_CMD} sed -i 's+^#unix_sock_dir.*+unix_sock_dir = "/var/run/libvirt"+' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's+^unix_sock_dir.*+unix_sock_dir = "/var/run/libvirt"+' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      echo -e "${LTCYAN}auth_unix_ro = \"none\"${NC}"
      ${SUDO_CMD} sed -i 's/^#auth_unix_ro.*/auth_unix_ro = "none"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^auth_unix_ro.*/auth_unix_ro = "none"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      echo -e "${LTCYAN}auth_unix_rw = \"none\"${NC}"
      ${SUDO_CMD} sed -i 's/^#auth_unix_rw.*/auth_unix_rw = "none"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^auth_unix_rw.*/auth_unix_rw = "none"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      # Enable TCP listening
      echo -e "${LTCYAN}listen_tcp = 1${NC}"
      ${SUDO_CMD} sed -i 's/^#listen_tcp.*/listen_tcp = 1/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^listen_tcp.*/listen_tcp = 1/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
  
      echo -e "${LTCYAN}auth_tcp = \"none\"${NC}"
      ${SUDO_CMD} sed -i 's/^#auth_tcp.*/auth_tcp = "none"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
      ${SUDO_CMD} sed -i 's/^auth_tcp.*/auth_tcp = "none"/' /etc/libvirt/${ENABLED_VIRT_SERVICE}.conf
    fi
  done

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
  if ! [ -e /etc/sysconfig/libvirt-guests ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt-guests /etc/sysconfig/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt-guests /etc/sysconfig/
  fi

  echo -e "${LTCYAN}/etc/sysconfig/libvirt-guests:${NC}"
  echo -e "${LTCYAN}ON_BOOT=start${NC}"
  ${SUDO_CMD} sed -i 's/^#ON_BOOT.*/ON_BOOT=start/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^ON_BOOT.*/ON_BOOT=start/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}START_DELAY=0${NC}"
  ${SUDO_CMD} sed -i 's/^#START_DELAY.*/START_DELAY=0/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^START_DELAY.*/START_DELAY=0/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}ON_SHUTDOWN=suspend${NC}"
  ${SUDO_CMD} sed -i 's/^#ON_SHUTDOWN.*/ON_SHUTDOWN=suspend/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^ON_SHUTDOWN.*/ON_SHUTDOWN=suspend/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}PARALLEL_SHUTDOWN=20${NC}"
  ${SUDO_CMD} sed -i 's/^#PARALLEL_SHUTDOWN.*/PARALLEL_SHUTDOWN=20/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^PARALLEL_SHUTDOWN.*/PARALLEL_SHUTDOWN=20/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}BYPASS_CACHE=0${NC}"
  ${SUDO_CMD} sed -i 's/^#BYPASS_CACHE.*/BYPASS_CACHE=0/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^BYPASS_CACHE.*/BYPASS_CACHE=0/' /etc/sysconfig/libvirt-guests

  echo -e "${LTCYAN}SYNC_TIME=1${NC}"
  ${SUDO_CMD} sed -i 's/^#SYNC_TIME.*/SYNC_TIME=1/' /etc/sysconfig/libvirt-guests
  ${SUDO_CMD} sed -i 's/^SYNC_TIME.*/SYNC_TIME=1/' /etc/sysconfig/libvirt-guests

  echo

  if [ -e ${FILES_SRC_DIR}/libvirt.sh ]
  then
    # Libvirt shell profile
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt.sh /etc/profile.d/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/libvirt.sh /etc/profile.d/
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /etc/profile.d/libvirt.sh${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if [ -e ${FILES_SRC_DIR}/labmachine_scripts.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C / -xzf ${FILES_SRC_DIR}/labmachine_scripts.tgz ${NC}"
    ${SUDO_CMD} tar -C / -xzf ${FILES_SRC_DIR}/labmachine_scripts.tgz 
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /usr/local/bin/*.sh${NC}"
    ${SUDO_CMD} chown root.root /usr/local/bin/*.sh
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chmod +rx /usr/local/bin/*.sh${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if [ -e ${FILES_SRC_DIR}/image_building.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /opt -xzf ${FILES_SRC_DIR}/image_building.tgz ${NC}"
    ${SUDO_CMD} tar -C /opt -xzf ${FILES_SRC_DIR}/image_building.tgz 
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /opt/image_building${NC}"
    ${SUDO_CMD} chown root.root /opt/image_building
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chmod +rx /opt/image_building/*.sh${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /Applications${NC}"
  ${SUDO_CMD} mkdir -p /Applications
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /etc/skel/Applications${NC}"
  ${SUDO_CMD} mkdir -p /etc/skel/Applications

  for USER in ${USER_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${NC}  sudo -u ${USER} mkdir -p /home/${USER}/Applications${NC}"
    sudo -u ${USER} mkdir -p /home/${USER}/Applications
  done

  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /install/courses${NC}"
  ${SUDO_CMD} mkdir -p /install/courses
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R .users /install/courses${NC}"
  ${SUDO_CMD} chown -R .users /install/courses
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chmod -R 2777 /install/courses${NC}"
  ${SUDO_CMD} chmod -R 2777 /install/courses

  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /install/courses_shared${NC}"
  ${SUDO_CMD} mkdir -p /install/courses_shared
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R .users /install/courses_shared${NC}"
  ${SUDO_CMD} chown -R .users /install/courses_shared
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chmod -R 2777 /install/courses_shared${NC}"
  ${SUDO_CMD} chmod -R 2777 /install/courses_shared

  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /home/VMs${NC}"
  ${SUDO_CMD} mkdir -p /home/VMs
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R .users /home/VMs${NC}"
  ${SUDO_CMD} chown -R .users /home/VMs
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chmod -R 2777 /home/VMs${NC}"
  ${SUDO_CMD} chmod -R 2777 /home/VMs

  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /home/iso${NC}"
  ${SUDO_CMD} mkdir -p /home/iso
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R .users /home/iso${NC}"
  ${SUDO_CMD} chown -R .users /home/iso
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chmod -R 2777 /home/iso${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if [ -e ${FILES_SRC_DIR}/wallpapers.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /usr/share -xzf ${FILES_SRC_DIR}/wallpapers.tgz ${NC}"
    ${SUDO_CMD} tar -C /usr/share -xzf ${FILES_SRC_DIR}/wallpapers.tgz 
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.png${NC}"
    ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.png
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.jpg${NC}"
    ${SUDO_CMD} chown root.root /usr/share/wallpapers/*.jpg
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /usr/share/gnome-background-properties/*.xml${NC}"
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

install_libreoffice_config() {
  echo -e "${LTBLUE}Installing LibreOffice Config (Color Palettes, etc)  ${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  if ls ${FILES_SRC_DIR}/ | grep -q ".soc"
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/*.soc /usr/lib64/libreoffice/share/palette/ ${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/*.soc /usr/lib64/libreoffice/share/palette/
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown root.root /usr/lib64/libreoffice/share/palette/*${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  echo -e "${LTCYAN}/etc/dconf/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /etc/ -xzf ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz${NC}"
    ${SUDO_CMD} tar -C /etc/ -xzf ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} dconf update${NC}"
    ${SUDO_CMD} dconf update
  fi

  echo

  echo -e "${LTCYAN}/etc/polkit-default-privs.local${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} ish -c sed -i 's/org.freedesktop.packagekit.system-sources-refresh.*/org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes/' /etc/polkit-default-privs.standard${NC}"
  #${SUDO_CMD} sh -c 'sed -i \'s/org.freedesktop.packagekit.system-sources-refresh.*/org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes/\' /etc/polkit-default-privs.standard'
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} \'sh -c echo org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes >> /etc/polkit-default-privs.local\'${NC}"
  ${SUDO_CMD} sh -c 'echo org.freedesktop.packagekit.system-sources-refresh               yes:yes:yes >> /etc/polkit-default-privs.local'
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} set_polkit_default_privs${NC}"
  ${SUDO_CMD} set_polkit_default_privs

  echo

  echo -e "${LTCYAN}/etc/skel/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  # Xsession
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /etc/skel/.xsession >> /etc/skel/.xsession'${NC}"
  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /etc/skel/.xsession >> /etc/skel/.xsession'
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c \'echo \"gnome-session\" >> /etc/skel/.xsession\'${NC}"
  ${SUDO_CMD} sh -c 'echo "gnome-session" >> /etc/skel/.xsession'

  # GNOME
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /etc/skel/.local/share/gnome-shell/extensions${NC}"
  ${SUDO_CMD} mkdir -p /etc/skel/.local/share/gnome-shell/extensions
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /etc/skel/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz${NC}"
  ${SUDO_CMD} tar -C /etc/skel/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz
  if ! [ -e /etc/skel/.config ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /etc/skel/.config${NC}"
    ${SUDO_CMD} mkdir -p /etc/skel/.config
  fi
  if [ -e ${FILES_SRC_DIR}/user.${DISTRO_NAME} ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /etc/skel/.config/dconf${NC}"
    ${SUDO_CMD} mkdir -p /etc/skel/.config/dconf
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /etc/skel/.config/dconf/user${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /etc/skel/.config/dconf/user
  fi
  if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} rm -f /etc/skel/.config/dconf/user${NC}"
    ${SUDO_CMD} rm -f /etc/skel/.config/dconf/user
  fi

  # XFCE4
  #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
  #${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
  #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
  #${SUDO_CMD} tar -C /etc/skel/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

  # mime
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /etc/skel/.config/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /etc/skel/.config/

  # Vim
  if ! grep -q "set noautoindent" /etc/skel/.vimrc
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c 'echo \"set noautoindent\" >> /etc/skel/.vimrc'${NC}"
    ${SUDO_CMD} sh -c 'echo "set noautoindent" >> /etc/skel/.vimrc'
  fi

  ## Bash Aliases
  #if ! grep -q "alias clear" /etc/skel/.alias
  #then
  #  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c 'echo \"alias clear='clear;echo;echo;echo'\" >> /etc/skel/.alias'${NC}"
  #  ${SUDO_CMD} sh -c 'echo "alias clear='clear;echo;echo;echo" >> /etc/skel/.alias'
  #fi

  echo

  echo -e "${LTCYAN}/root/:${NC}"
  echo -e "${LTCYAN}----------------------${NC}"
  # Xsession
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /root/.xsession >> /root/.xsession'${NC}"
  ${SUDO_CMD} sh -c 'sed -i /gnome-session/d /root/.xsession >> /root/.xsession'
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c \'echo \"gnome-session\" >> /root/.xsession\'${NC}"
  ${SUDO_CMD} sh -c 'echo "gnome-session" >> /root/.xsession'

  # GNOME
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /root/.local/share/gnome-shell/extensions${NC}"
  ${SUDO_CMD} mkdir -p /root/.local/share/gnome-shell/extensions
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /root/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz${NC}"
  ${SUDO_CMD} tar -C /root/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz
  if ! [ -e /root/.config ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /root/.config${NC}"
    ${SUDO_CMD} mkdir -p /root/.config
  fi
  if [ -e ${FILES_SRC_DIR}/user.${DISTRO_NAME} ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /root/.config/dconf${NC}"
    ${SUDO_CMD} mkdir -p /root/.config/dconf
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /root/.config/dconf/user${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /root/.config/dconf/user
  fi
  if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} rm -f /root/.config/dconf/user${NC}"
    ${SUDO_CMD} rm -f /root/.config/dconf/user
  fi

  # XFCE4
  #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
  #${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
  #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
  #${SUDO_CMD} tar -C /root/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

  # mime
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /root/.config/${NC}"
  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /root/.config/

  # Vim
  if ! ${SUDO_CMD} sh -c 'grep -q "set noautoindent" /root/.vimrc'
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c \'echo \"set noautoindent\" >> /root/.vimrc\'${NC}"
    ${SUDO_CMD} sh -c 'echo "set noautoindent" >> /root/.vimrc'
  fi

  ## Bash Aliases
  #if ! grep -q "alias clear" /root/.alias
  #then
  #  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c 'echo \"alias clear='clear;echo;echo;echo'\" >> /root/.alias'${NC}"
  #  ${SUDO_CMD} sh -c 'echo "alias clear='clear;echo;echo;echo" >> /root/.alias'
  #fi

  ## Add subuids|subgids for running containers with podman and docker
  ${SUDO_CMD} usermod --add-subuids 100000-165535 --add-subgids 100000-165535 root

  echo

  for USER in ${USER_LIST}
  do
    if ! groups ${USER} | grep -q ${USERS_GROUP}
    then
      echo -e "${LTGREEN}COMMAND:${NC} ${SUDO_CMD} usermod -aG ${USERS_GROUP} ${USER}${NC}"
      ${SUDO_CMD} usermod -aG ${USERS_GROUP} ${USER}
    fi

    echo -e "${LTCYAN}/home/${USER}/:${NC}"
    echo -e "${LTCYAN}----------------------${NC}"
    # Xsession
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sed -i /gnome-session/d /home/${USER}/.xsession >> /home/${USER}/.xsession${NC}"
    ${SUDO_CMD} sed -i /gnome-session/d /home/${USER}/.xsession >> /home/${USER}/.xsession
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} echo \"gnome-session\" >> /home/${USER}/.xsession${NC}"
    ${SUDO_CMD} echo "gnome-session" >> /home/${USER}/.xsession

    # GNOME
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /home/${USER}/.local/share/gnome-shell/extensions${NC}"
    ${SUDO_CMD} mkdir -p /home/${USER}/.local/share/gnome-shell/extensions
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /home/${USER}/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz${NC}"
    ${SUDO_CMD} tar -C /home/${USER}/.local/share/gnome-shell/extensions/ -xzf ${FILES_SRC_DIR}/gnome-shell-extensions.${DISTRO_NAME}.tgz
    if ! [ -e /home/${USER}/.config ]
    then
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /home/${USER}/.config${NC}"
      ${SUDO_CMD} mkdir -p /home/${USER}/.config
    fi
    if [ -e ${FILES_SRC_DIR}/user.${DISTRO_NAME} ]
    then
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /home/${USER}/.config/dconf${NC}"
      ${SUDO_CMD} mkdir -p /home/${USER}/.config/dconf
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /home/${USER}/.config/dconf/user${NC}"
      ${SUDO_CMD} cp ${FILES_SRC_DIR}/user.${DISTRO_NAME} /home/${USER}/.config/dconf/user
    fi
    if [ -e ${FILES_SRC_DIR}/dconf_defaults.${DISTRO_NAME}.tgz ]
    then
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} rm -f /home/${USER}/.config/dconf/user${NC}"
      ${SUDO_CMD} rm -f /home/${USER}/.config/dconf/user
    fi

    # XFCE4
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz${NC}"
    #${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/xfce4.tgz
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz${NC}"
    #${SUDO_CMD} tar -C /home/${USER}/.config/ -xzf ${FILES_SRC_DIR}/Thunar.tgz

    # mime
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /home/${USER}/.config/${NC}"
    ${SUDO_CMD} cp ${FILES_SRC_DIR}/mimeapps.list /home/${USER}/.config/

    # Vim
    if ! grep -q "set noautoindent" /home/${USER}/.vimrc
    then
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c \"echo set noautoindent >> /home/${USER}/.vimrc\"${NC}"
      ${SUDO_CMD} sh -c "echo set noautoindent >> /home/${USER}/.vimrc"
    fi

    ## Bash Aliases
    #if ! grep -q "alias clear" /home/${USER}/.alias
    #then
    #  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} sh -c 'echo \"alias clear='clear;echo;echo;echo'\" >> /home/${USER}/.alias'${NC}"
    #  ${SUDO_CMD} sh -c 'echo "alias clear='clear;echo;echo;echo" >> /home/${USER}/.alias'
    #fi

    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}${NC}"
    ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.local${NC}"
    #${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.local
    #echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.config${NC}"
    #${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}/.config

    ## Add subuids|subgids for running containers with podman and docker
    ${SUDO_CMD} usermod --add-subuids 100000-165535 --add-subgids 100000-165535 ${USER}

    echo

    for SECONDARY_GROUP in ${USERS_SECONDARY_GROUPS}
    do
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} usermod -aG ${SECONDARY_GROUP} ${USER}${NC}"
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

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  echo -e "${LTCYAN}DISPLAYMANAGER_XSERVER="Xorg"${NC}"
  ${SUDO_CMD} sed -i 's/^DISPLAYMANAGER_XSERVER=.*/DISPLAYMANAGER_XSERVER="Xorg"/' /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DISPLAYMANAGER=\"${DEFAULT_DISPLAYMANAGER}\"${NC}"
  ${SUDO_CMD} sed -i "s/^DISPLAYMANAGER=.*/DISPLAYMANAGER=\"${DEFAULT_DISPLAYMANAGER}\"/" /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DISPLAYMANAGER_STARTS_XSERVER="yes"${NC}"
  ${SUDO_CMD} sed -i 's/^DISPLAYMANAGER_STARTS_XSERVER=.*/DISPLAYMANAGER_STARTS_XSERVER="yes"/' /etc/sysconfig/displaymanager

  echo -e "${LTCYAN}DEFAULT_WM="${DEFAULT_XSESSION}"${NC}"
  ${SUDO_CMD} sed -i "s/^DEFAULT_WM=.*/DEFAULT_WM=\"${DEFAULT_XSESSION}\"/" /etc/sysconfig/displaymanager

  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/${DEFAULT_DISPLAYMANAGER} ${NC}"
  ${SUDO_CMD} update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/${DEFAULT_DISPLAYMANAGER} 
  echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} update-alternatives --set default-xsession.desktop /usr/share/xsessions/${DEFAULT_XSESSION}.desktop${NC}"
  ${SUDO_CMD} update-alternatives --set default-xsession.desktop /usr/share/xsessions/${DEFAULT_XSESSION}.desktop
 
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_google_chrome() {
  local CHROME_REPO_NAME="google-chrome"
  local CHROME_PKG_NAME="google-chrome-stable"

  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing Google Chrome${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  if ! grep -q "dl.google.com" /etc/zypp/repos.d/*.repo
  then
    echo -e "${LTCYAN}${CHROME_REPO_NAME}${NC}"
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 ${CHROME_REPO_NAME}${NC}"
    ${SUDO_CMD} zypper addrepo http://dl.google.com/linux/chrome/rpm/stable/x86_64 ${CHROME_REPO_NAME}
    if ! [ -e ${FILES_SRC_DIR}/linux_signing_key.pub ]
    then
      echo -e "${LTGREEN}COMMAND:${NC}  cd ${FILES_SRC_DIR}${NC}"
      cd ${FILES_SRC_DIR}
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} wget https://dl.google.com/linux/linux_signing_key.pub${NC}"
      ${SUDO_CMD} wget https://dl.google.com/linux/linux_signing_key.pub
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} rpm --import linux_signing_key.pub${NC}"
      ${SUDO_CMD} rpm --import linux_signing_key.pub
      echo -e "${LTGREEN}COMMAND:${NC}  cd -${NC}"
      cd - > /dev/null
    fi
  fi

  echo -e "${LTGREEN}COMMAND:${NC} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh ${CHROME_REPO_NAME}${NC}"
  ${SUDO_CMD} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh ${CHROME_REPO_NAME}
  echo -e "${LTGREEN}COMMAND:${NC} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${CHROME_PKG_NAME}${NC}"
  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${CHROME_PKG_NAME}
 
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_virtualbox() {
  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing Virtualbox${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  if ! rpm -qa | grep -q virtualbox
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} virtualbox-qt${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} virtualbox-qt
    echo
  fi

  if rpm -qa | grep -q virtualbox
  then
    VBOX_VER="$(rpm -q virtualbox | cut -d \- -f 2)"
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} wget https://download.virtualbox.org/virtualbox/${VBOX_VER}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VER}.vbox-extpack${NC}"
    ${SUDO_CMD} wget https://download.virtualbox.org/virtualbox/${VBOX_VER}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VER}.vbox-extpack
    echo -e "${LTGREEN}COMMAND:${NC}  echo y | ${SUDO_CMD} /usr/bin/VBoxManage extpack install --replace *.vbox-extpack${NC}"
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
  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing the Atom Editor${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  if ! grep -q "packagecloud.io/AtomEditor" /etc/zypp/repos.d/*.repo
  then
    ${SUDO_CMD} sh -c 'echo -e "[Atom]\nname=Atom Editor\nbaseurl=https://packagecloud.io/AtomEditor/atom/el/7/\$basearch\nenabled=1\ntype=rpm-md\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey" > /etc/zypp/repos.d/atom.repo'
    echo -e "${LTGREEN}COMMAND:${NC} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh "Atom Editor"${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh "Atom Editor"
  fi

  if zypper se atom | grep -q "A hackable text editor"
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} atom${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} atom
  else
    echo -e "${LTGREEN}COMMAND:${NC} cd ${RPM_SRC_DIR}/${NC}"
    cd ${RPM_SRC_DIR}/
    echo -e "${LTGREEN}COMMAND:${NC} wget https://atom.io/rpm${NC}"
    wget https://atom.io/rpm
    echo -e "${LTGREEN}COMMAND:${NC} mv ./rpm ./atom.rpm${NC}"
    mv ./rpm ./atom.rpm
    cd -
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${RPM_SRC_DIR}/atom.rpm${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${RPM_SRC_DIR}/atom.rpm
    echo -e "${LTGREEN}COMMAND:${NC} ${SUDO_CMD} rm -f  ${RPM_SRC_DIR}/atom.rpm${NC}"
    ${SUDO_CMD} rm -f  ${RPM_SRC_DIR}/atom.rpm
  fi

  echo

  if [ -e ${FILES_SRC_DIR}/atom-packages.tgz ]
  then
    echo -e "${LTBLUE}Installing the Atom Editor add-on packages${NC}"
    echo -e "${LTBLUE}----------------------------------------------------${NC}"
 
    echo -e "${LTCYAN}/etc/skel/:${NC}"
    echo -e "${LTCYAN}----------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /etc/skel/.atom/packages/${NC}"
    ${SUDO_CMD} mkdir -p /etc/skel/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages/
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /etc/skel/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz${NC}"
    ${SUDO_CMD} tar -C /etc/skel/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz
 
    echo -e "${LTCYAN}/root/:${NC}"
    echo -e "${LTCYAN}----------------------${NC}"
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /root/.atom/packages/${NC}"
    ${SUDO_CMD} mkdir -p /root/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages/
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /root/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz${NC}"
    ${SUDO_CMD} tar -C /root/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz
 
    for USER in ${USER_LIST}
    do
      echo -e "${LTCYAN}/home/${USER}/:${NC}"
      echo -e "${LTCYAN}----------------------${NC}"
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} mkdir -p /home/${USER}/.atom/packages/${NC}"
      ${SUDO_CMD} mkdir -p /home/${USER}/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages/
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} tar -C /home/${USER}/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz${NC}"
      ${SUDO_CMD} tar -C /home/${USER}/.atom/packages/ -xzf ${FILES_SRC_DIR}/atom-packages.tgz

      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} chown -R ${USER}.${USERS_GROUP} /home/${USER}${NC}"
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
  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing Microsoft Teams${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  if ! grep -q "packages.microsoft.com/yumrepos/ms-teams" /etc/zypp/repos.d/*.repo
  then
    ${SUDO_CMD} sh -c 'echo -e "[teams]\nname=teams\nenabled=1\nautorefresh=0\nbaseurl=https://packages.microsoft.com/yumrepos/ms-teams\ntype=rpm-md\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\nkeeppackages=0" > /etc/zypp/repos.d/teams.repo'
    echo -e "${LTGREEN}COMMAND:${NC} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh teams${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh teams
  fi

  if zypper se teams | grep -q "Microsoft Teams for Linux is your chat-centered workspace in Office 365"
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} teams${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} teams
  fi
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_zoom() {
  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing Zoom${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  echo -e "${LTGREEN}COMMAND:${NC} ${SUDO_CMD} rpm --import https://zoom.us/linux/download/pubkey${NC}"
  ${SUDO_CMD} rpm --import https://zoom.us/linux/download/pubkey
  echo -e "${LTGREEN}COMMAND:${NC} ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} https://zoom.us/client/latest/zoom_openSUSE_x86_64.rpm ${NC}"
  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} https://zoom.us/client/latest/zoom_openSUSE_x86_64.rpm 

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_insync() {
  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing Insync${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  if ! grep -q "yum.insync.io/fedora/27" /etc/zypp/repos.d/*.repo
  then
    echo -e "${LTCYAN}insync${NC}"
    echo -e "${LTGREEN}COMMAND:${NC} zypper ar http://yum.insync.io/fedora/27/ insync${NC}"
    ${SUDO_CMD} zypper ar http://yum.insync.io/fedora/27/ insync
    echo -e "${LTGREEN}COMMAND:${NC} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh
  fi

  if zypper se insync | grep -q "| insync "
  then
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} insync${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} insync
  fi 
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

install_edge() {
  local EDGE_REPO_NAME="microsoft-edge-beta"
  local EDGE_PKG_NAME="microsoft-edge-stable"

  local ZYPPER_REF_GLOBAL_OPTS="--no-gpg-checks --gpg-auto-import-keys"
  local ZYPPER_INSTALL_GLOBAL_OPTS="--non-interactive --no-gpg-checks --no-refresh"
  local ZYPPER_INSTALL_OPTS="-l --allow-unsigned-rpm"

  echo -e "${LTBLUE}Installing Microsoft Edge${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac


  if ! grep -q "${EDGE_REPO_NAME}" /etc/zypp/repos.d/*.repo
  then
    echo -e "${LTCYAN}${EDGE_REPO_NAME}${NC}"
    echo -e "${LTGREEN}COMMAND:${NC} rpm --import https://packages.microsoft.com/keys/microsoft.asc${NC}"
    ${SUDO_CMD} rpm --import https://packages.microsoft.com/keys/microsoft.asc${NC}
    echo -e "${LTGREEN}COMMAND:${NC} zypper ar https://packages.microsoft.com/yumrepos/edge ${EDGE_REPO_NAME}${NC}"
    ${SUDO_CMD} zypper ar https://packages.microsoft.com/yumrepos/edge ${EDGE_REPO_NAME}
    echo -e "${LTGREEN}COMMAND:${NC} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh ${EDGE_REPO_NAME}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_REF_GLOBAL_OPTS} refresh ${EDGE_REPO_NAME}
  fi

  if zypper se ${EDGE_PKG_NAME} | grep -q "| ${EDGE_PKG_NAME} "
  then
    echo -e "${LTGREEN}COMMAND:${NC} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${EDGE_PKG_NAME}${NC}"
    ${SUDO_CMD} zypper ${ZYPPER_INSTALL_GLOBAL_OPTS} install ${ZYPPER_INSTALL_OPTS} ${EDGE_PKG_NAME}
  fi
  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

enable_base_services() {
  echo -e "${LTBLUE}Enabling/Starting Base Services${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for SERVICE in ${ENABLED_BASE_SERVICES_LIST}
  do
    if echo ${*} | grep -q no_restart_gui
    then
      if ! echo ${SERVICE} | grep -q display-manager
      then
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl enable ${SERVICE}
  
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl restart ${SERVICE}
      fi
    else
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl enable ${SERVICE}

      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl restart ${SERVICE}
    fi
   echo
  done
}

disable_not_required_virt_services() {
  echo -e "${LTBLUE}Disabling/Stopping Non-required Virtualization Services${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for SERVICE in ${DISABLED_VIRT_SERVICES_LIST}
  do
    if echo ${*} | grep -q no_restart_gui
    then
      if ! echo ${SERVICE} | grep -q display-manager
      then
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-ro.socket${NC}"
        ${SUDO_CMD} systemctl stop ${SERVICE}-ro.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-admin.socket${NC}"
        ${SUDO_CMD} systemctl stop ${SERVICE}-admin.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-tcp.socket${NC}"
        ${SUDO_CMD} systemctl stop ${SERVICE}-tcp.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-tls.socket${NC}"
        ${SUDO_CMD} systemctl stop ${SERVICE}-tls.socket

        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl disable ${SERVICE}
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-ro.socket${NC}"
        ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-ro.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-admin.socket${NC}"
        ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-admin.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-tcp.socket${NC}"
        ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-tcp.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-tls.socket${NC}"
        ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-tls.socket
      fi
    else
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-ro.socket${NC}"
      ${SUDO_CMD} systemctl stop ${SERVICE}-ro.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-admin.socket${NC}"
      ${SUDO_CMD} systemctl stop ${SERVICE}-admin.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-tcp.socket${NC}"
      ${SUDO_CMD} systemctl stop ${SERVICE}-tcp.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl stop ${SERVICE}-tls.socket${NC}"
      ${SUDO_CMD} systemctl stop ${SERVICE}-tls.socket

      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl disable ${SERVICE}
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-ro.socket${NC}"
      ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-ro.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-admin.socket${NC}"
      ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-admin.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-tcp.socket${NC}"
      ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-tcp.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl disable ${SERVICE}-tls.socket${NC}"
      ${SUDO_CMD} systemctl disable ${SERVICE-ro.socket}-tls.socket
    fi
   echo
  done
}

enable_required_virt_services() {
  echo -e "${LTBLUE}Enabling/Starting Required Virtualization Services${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for SERVICE in ${ENABLED_VIRT_SERVICES_LIST}
  do
    if echo ${*} | grep -q no_restart_gui
    then
      if ! echo ${SERVICE} | grep -q display-manager
      then
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl enable ${SERVICE}
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}-ro.socket${NC}"
        ${SUDO_CMD} systemctl enable ${SERVICE-ro.socket}-ro.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}-admin.socket${NC}"
        ${SUDO_CMD} systemctl enable ${SERVICE-ro.socket}-admin.socket
  
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}-ro.socket${NC}"
        ${SUDO_CMD} systemctl restart ${SERVICE}-ro.socket
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}-admin.socket${NC}"
        ${SUDO_CMD} systemctl restart ${SERVICE}-admin.socket
      fi
    else
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl enable ${SERVICE}
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}-ro.socket${NC}"
      ${SUDO_CMD} systemctl enable ${SERVICE-ro.socket}-ro.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}-admin.socket${NC}"
      ${SUDO_CMD} systemctl enable ${SERVICE-ro.socket}-admin.socket

      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}-ro.socket${NC}"
      ${SUDO_CMD} systemctl restart ${SERVICE}-ro.socket
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}-admin.socket${NC}"
      ${SUDO_CMD} systemctl restart ${SERVICE}-admin.socket
    fi
   echo
  done
}

enable_required_container_services() {
  echo -e "${LTBLUE}Enabling/Starting Container Services${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for SERVICE in ${ENABLED_CONTAINER_SERVICES_LIST}
  do
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
    ${SUDO_CMD} systemctl enable ${SERVICE}
 
    echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
    ${SUDO_CMD} systemctl restart ${SERVICE}
    echo
  done
}

enable_remote_access_services() {
  echo -e "${LTBLUE}Enabling/Starting Remote Access Services${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"
  for SERVICE in ${ENABLED_REMOTE_ACCESS_SERVICES_LIST}
  do
    if echo ${*} | grep -q no_restart_gui
    then
      if ! echo ${SERVICE} | grep -q display-manager
      then
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl enable ${SERVICE}
  
        echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
        ${SUDO_CMD} systemctl restart ${SERVICE}
      fi
    else
      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl enable ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl enable ${SERVICE}

      echo -e "${LTGREEN}COMMAND:${NC}  ${SUDO_CMD} systemctl restart ${SERVICE}${NC}"
      ${SUDO_CMD} systemctl restart ${SERVICE}
    fi
   echo
  done
}

run_custom_scripts() {
  echo -e "${LTBLUE}Running Custom Scripts${NC}"
  echo -e "${LTBLUE}----------------------------------------------------${NC}"

  case ${STEPTHROUGH} in
    Y)
      sleep ${STEPTHROUGH_INITIAL_PAUSE}
    ;;
  esac

  source ${INCLUDE_DIR}/*.sh

  echo

  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac
}

run_optional_operations() {
  #if echo ${*} | grep -q install-chrome
  #then
  #  install_google_chrome ${*}
  #fi
  if echo ${*} | grep -q install-virtualbox
  then
    install_virtualbox ${*}
  fi
  if echo ${*} | grep -q install-atom_editor
  then
    install_atom_editor
  fi
  if echo ${*} | grep -q install-teams
  then
    install_teams
  fi
  if echo ${*} | grep -q install-insync
  then
    install_insync
  fi
  if echo ${*} | grep -q install-zoom
  then
    install_zoom
  fi
  if echo ${*} | grep -q install-edge
  then
    install_edge
  fi
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

  echo -e "${LTBLUE}###########################################################################################${NC}"
  echo -e "${LTBLUE}                Configuring Machine As a Lab Machine${NC}"
  echo -e "${LTBLUE}                ${NC}"
  echo -e "${LTBLUE}                Distribution: ${PURPLE} ${DISTRO_NAME}${NC}"
  echo -e "${LTBLUE}                ${NC}"
  echo -e "${LTBLUE}                CLI Args: ${PURPLE} ${*}${NC}"
  echo -e "${LTBLUE}###########################################################################################${NC}"
  echo
  case ${STEPTHROUGH} in
    Y)
      pause_for_stepthrough
    ;;
  esac

  if echo ${*} | grep -q base_env_only
  then
  #####################################################
  #   Base Env Only
  #####################################################
    # base env
    configure_sudo
    create_default_dirs
    # zypper
    add_zypper_base_repos
    refresh_zypper_repos
    install_zypper_base_patterns
    remove_zypper_patterns
    install_zypper_base_packages
    install_google_chrome
    remove_zypper_packages
    # services
    enable_base_services
  elif echo ${*} | grep -q base_user_env_only
  then
  #####################################################
  #   Base User Env Only
  #####################################################
    # base env
    configure_sudo
    create_default_dirs
    # zypper
    add_zypper_base_repos
    refresh_zypper_repos
    install_zypper_base_patterns
    remove_zypper_patterns
    install_zypper_base_packages
    install_google_chrome
    remove_zypper_packages
    # user env
    install_wallpapers
    install_user_environment
    configure_displaymanager
    # services
    enable_base_services
  elif echo ${*} | grep -q base_virt_env_only
  then
  #####################################################
  #   Base Virt Env Only
  #####################################################
    # base env
    configure_sudo
    create_default_dirs
    # zypper
    add_zypper_base_repos
    add_zypper_extra_repos
    refresh_zypper_repos
    install_zypper_base_patterns
    install_zypper_virt_patterns
    remove_zypper_patterns
    install_zypper_base_packages
    install_zypper_remote_access_packages
    install_zypper_virt_packages
    install_google_chrome
    remove_zypper_packages
    # libvirt
    install_modprobe_config
    configure_libvirt
    # tools
    install_labmachine_scripts
    # user env
    install_wallpapers
    install_user_environment
    configure_displaymanager
    # custom scripts
    run_custom_scripts
    # services
    disable_not_required_virt_services
    enable_required_virt_services
    enable_remote_access_services
    enable_base_services
  elif echo ${*} | grep -q base_container_env_only
  then
  #####################################################
  #   Base Container Env Only
  #####################################################
    # base env
    configure_sudo
    create_default_dirs
    # zypper
    add_zypper_base_repos
    add_zypper_extra_repos
    refresh_zypper_repos
    install_zypper_base_patterns
    remove_zypper_patterns
    install_zypper_base_packages
    install_zypper_remote_access_packages
    install_zypper_container_packages
    install_google_chrome
    remove_zypper_packages
    # libvirt
    install_modprobe_config
    configure_libvirt
    # tools
    install_labmachine_scripts
    # user env
    install_wallpapers
    install_user_environment
    configure_displaymanager
    # custom scripts
    run_custom_scripts
    # services
    enable_required_container_services
    enable_remote_access_services
    enable_base_services
  elif echo ${*} | grep -q base_dev_env_only
  then
  #####################################################
  #   Base Dev Env Only
  #####################################################
    # base env
    configure_sudo
    create_default_dirs
    # zypper
    add_zypper_base_repos
    add_zypper_extra_repos
    refresh_zypper_repos
    install_zypper_base_patterns
    remove_zypper_patterns
    install_zypper_base_packages
    install_zypper_remote_access_packages
    install_zypper_dev_packages
    install_google_chrome
    install_custom_remote_zypper_packages
    install_extra_rpms
    remove_zypper_packages
    # other packages/apps
    install_flatpaks
    install_appimages
    # tools
    install_labmachine_scripts
    install_image_building_tools
    # optional operations
    run_optional_operations ${*}
    # user env
    install_wallpapers
    install_libreoffice_config
    install_user_environment
    configure_displaymanager
    # custom scripts
    run_custom_scripts
    # services
    enable_remote_access_services
    enable_base_services
  elif echo ${*} | grep -q packages_only
  then
  #####################################################
  #   Packages Only
  #####################################################
    # zypper
    add_zypper_base_repos
    add_zypper_extra_repos
    refresh_zypper_repos
    install_zypper_base_patterns
    install_zypper_virt_patterns
    remove_zypper_patterns
    install_zypper_base_packages
    install_zypper_remote_access_packages
    install_zypper_virt_packages
    install_zypper_container_packages
    install_zypper_dev_packages
    install_google_chrome
    install_custom_remote_zypper_packages
    install_extra_rpms
    remove_zypper_packages
    # other packages/apps
    install_flatpaks
    install_appimages
    # optional operations
    run_optional_operations ${*}
  elif echo ${*} | grep -q tools_only
  then
  #####################################################
  #   Tools Only
  #####################################################
    install_labmachine_scripts
    install_image_building_tools
  elif echo ${*} | grep -q libvirt_only
  then
  #####################################################
  #   Libvirt Only
  #####################################################
    install_modprobe_config
    configure_libvirt
  elif echo ${*} | grep -q user_env_only
  then
  #####################################################
  #   User Env Only
  #####################################################
    install_wallpapers
    install_libreoffice_config
    install_user_environment
    configure_displaymanager
  elif echo ${*} | grep -q custom_only
  then
  #####################################################
  #   Custom Only
  #####################################################
    # custom scripts
    run_custom_scripts
  elif echo ${*} | grep -q optional_only
  then
  #####################################################
  #   Optional Only
  #####################################################
    # optional operations
    run_optional_operations ${*}
  else
  #####################################################
  #   Everything
  #####################################################
    # base env
    configure_sudo
    create_default_dirs
    # zypper
    add_zypper_base_repos
    add_zypper_extra_repos
    refresh_zypper_repos
    install_zypper_base_patterns
    install_zypper_virt_patterns
    remove_zypper_patterns
    install_zypper_base_packages
    install_zypper_remote_access_packages
    install_zypper_virt_packages
    install_zypper_container_packages
    install_zypper_dev_packages
    install_google_chrome
    install_custom_remote_zypper_packages
    install_extra_rpms
    remove_zypper_packages
    # other packages/apps
    install_flatpaks
    install_appimages
    # libvirt
    install_modprobe_config
    configure_libvirt
    # tools
    install_labmachine_scripts
    install_image_building_tools
    # optional operations
    run_optional_operations ${*}
    # user env
    install_wallpapers
    install_libreoffice_config
    install_user_environment
    configure_displaymanager
    # custom scripts
    run_custom_scripts
    # services
    disable_not_required_virt_services
    enable_required_virt_services
    enable_required_container_services
    enable_remote_access_services
    enable_base_services
  fi

  echo
  echo -e "${LTBLUE}========================================================================${NC}"
  echo -e "${LTBLUE}                               Finished${NC}"
  echo -e "${LTBLUE}========================================================================${NC}"
  echo
}

#############################################################################

time main ${*}

