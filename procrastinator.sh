#!/bin/bash
# Block domain for a specified duration to prevend procrastination 
# License WTFPL


blocklist="twitter.com youtube.com reddit.com facebook.com"

# this file overwrite the previous list, (remember that $HOME is the home of the root user)
blocklist_file="$HOME/.procrastinator_blocklist"

hostfile="/etc/hosts"
temphostfile="/tmp/procrastinator_hosts"


help () {
echo "$0
Usage:
  start      Start blocking domains
  Xm         Block domains for the next X minutes
  Xh         Block domains for the next X hours
  list       List the blocked domains
  stop       Stop the blockage
  force-stop Force the stop (usefull if the computer have been rebooted since the start) 
  -h | help  Print this help message
"
}


start () {
  if [ -e "$temphostfile" ]
  then
    echo "Procrastinator seems to be already running"
    exit 1
  fi
  root
  echo "Starting procrastinator"
  cp "$hostfile" "$temphostfile"

  for website in $blocklist
  do
    echo 127.0.0.1 "$website" >> "$hostfile"
    echo 127.0.0.1 www."$website" >> "$hostfile"
  done
}


stop () {
  if [ -e "$temphostfile" ]
  then
    echo "Stopping procrastinator"
    mv "$temphostfile" "$hostfile" 
  else
    echo "Procrastinator not running"
    echo "Use \"$0 force-stop\" if needed"
  fi
}


force-stop () {
  root
  echo "Force stopping procrastinator"
  for website in $blocklist
  do
    sed -i /^127.0.0.1\ .*$website$/d "$hostfile"
  done
  rm "$temphostfile" 
}


list () {
  echo "Domain blocked:"
  echo "$blocklist" | sed 's/\ /\n/g'
}


runduration () {
  root
  arg=$(echo $* | sed 's/h/\ hours/' | sed 's/m/\ minutes/')
  echo mv "$temphostfile" "$hostfile" |  at now + $arg 
  if [ "$?" != 0 ]
  then
    help
  fi
}


root () {
  if [[ $EUID -ne 0 ]]; then
    help
    echo "This script must be run as root" 
    exit 1
  fi
}



if [ -e "$blocklist_file" ]
then
  blocklist=$(cat "$blocklist_file")
fi


case "$1" in
  start)
    start;;

  stop)
    stop;;

  force-stop)
    force-stop;;

  list)
    list;;

  *h | *m)
    start
    runduration $* 
    ;;

  *)
    help;;

esac

