#!/bin/bash
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

##############################################################################

echo -e "${LTCYAN}Creating gnome-shell-extensions.tgz ...${NC}"

if [ -e ../files ]
then
  echo -e "${LTGREEN}COMMAND:  ${GRAY}mkdir -p ../files${NC}"
  mkdir -p ../files
fi

echo -e "${LTGREEN}COMMAND:${GRAY}  cd ~/.local/share/gnome-shell/extensions${NC}"
cd ~/.local/share/gnome-shell/extensions
echo -e "${LTGREEN}COMMAND:${GRAY}  tar czf gnome-shell-extensions.tgz \*${NC}"
tar czf gnome-shell-extensions.tgz *

echo -e "${LTGREEN}COMMAND:${GRAY}  cd -${NC}"
cd - > /dev/null 2>&1

echo -e "${LTGREEN}COMMAND:${GRAY}  mv ~/.local/share/gnome-shell/extensions/gnome-shell-extensions.tgz ../files/${NC}"
mv ~/.local/share/gnome-shell/extensions/gnome-shell-extensions.tgz ../files/

echo
