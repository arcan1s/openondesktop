#!/bin/bash

func_help() {
  echo -e "Script to install *.desktop for 'Open on desktop...' Dolphin dropbox menu\n"
  echo -e "Usage: intasll_desktop.sh [-h | --help] [ -i PATHTOKWINRC] [ -o PATHTODESKTOP]\n"
#  echo -e "Usage: intasll_desktop.sh [-h | --help] [ --open-with ] [ -i PATHTOKWINRC] [ -o PATHTODESKTOP]\n"
  echo -e "Additional parametrs:"
  echo -e "  -h  --help       - show this help and exit"
#  echo -e "      --open-with  - install as 'Open to desktop with...'"
  echo -e "  -i               - path to configuration file (kwinrc). Default is '\$HOME/.kde4/share/config/kwinrc'"
  echo -e "  -o               - path to output file (*.desktop). Default is '\$HOME/.kde4/share/kde4/services/ServiceMenus/12-open_on.desktop'"
  exit 1
}

PATHTOKWINRC="$HOME/.kde4/share/config/kwinrc"
PATHTODESKTOP="$HOME/.kde4/share/kde4/services/ServiceMenus/12-open_on.desktop"
OPENWITH="0"

until [ -z $1 ]; do
  if [ "$1" = "-h" ]; then
    func_help; fi
  if [ "$1" = "--help" ]; then
    func_help; fi
  if [ "$1" = "-i" ]; then
    PATHTOKWINRC="$2"
    shift; fi
  if [ "$1" = "-o" ]; then
    PATHTODESKTOP="$2"
    shift; fi
  if [ "$1" = "--open-with" ]; then
    OPENWITH="1"; fi
  shift
done


NUMSTARTSTR=$((`cat $PATHTOKWINRC | wc -l` - `cat $PATHTOKWINRC | grep -m 1 -n Desktops | sed 's/:.*//'`))
NUMDESKTOPS=`tail -n $NUMSTARTSTR $PATHTOKWINRC | grep Number\= | cut -c8-`
NAMEDESKTOPS=`tail -n $NUMSTARTSTR $PATHTOKWINRC | grep -m $NUMDESKTOPS Name_ | sed 's/Name_.=*//'`
echo -en "[Desktop Entry]\nType=Service\nServiceTypes=KonqPopupMenu/Plugin\nMimeType=all/all;\n" > $PATHTODESKTOP
echo -en "Actions=" >> $PATHTODESKTOP
echo -en $NAMEDESKTOPS | sed -e 's/ /;/g' >> $PATHTODESKTOP
if [[ $OPENWITH == "0" ]]; then
  echo -en "\nTryExec=kstart\nX-KDE-Priority=TopLevel\nX-KDE-Submenu=Open on desktop...\nX-KDE-Submenu[ru]=Открыть на рабочем столе...\n" >> $PATHTODESKTOP
  echo -en "X-KDE-Submenu[fr]=Ouvrir sur desktop...\nX-KDE-Submenu[de]=Öffnen auf dem desktop...\n\n" >> $PATHTODESKTOP
else
  echo "Doesn't work yet =)\nTry again"
  rm $PATHTODESKTOP
  exit 1
fi

NUMDESK=1
for NAMEDESK in $NAMEDESKTOPS; do
  echo -en "[Desktop Action $NAMEDESK]\nName=$NAMEDESK\nExec=kstart --desktop $NUMDESK kioclient exec %F\n\n" >> $PATHTODESKTOP
  NUMDESK=$(($NUMDESK+1))
done

echo "File '$PATHTODESKTOP' had been installed"
