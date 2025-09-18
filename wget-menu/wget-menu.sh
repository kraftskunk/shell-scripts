#!/bin/bash
#
# (c) 2022 Zoran Grbic
# Grbic Consulting
# contact@grbic.be
#
# A web crawl script for manual downloads.
# Script is part of the menu_wget_manual_download.sh,
# a simple menu for managing the file with links to download.
#
# This script should run at a high interval (10min minimum) from cron.
# There is a simple locking mechanism to avoid running several
# instances in parallel.
#
# The script will exit if a PID is found. It will also exit if the files are present in
# the download location.
#
# Next update:
# Trap for Ctrl+C and deletion of the PID file.
#
# 2022-12-30 - ver 01
#    Base script
#
# 2025-09-16
#    Intergating with a shell menu to update and manage manual downloads.
#	   Adding automatic log folder creation
#
# Based on a script from:
#    (c) 2015 https://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/
#    The page is gives now a 404 error.
#
# --------------------------------------------------------------------------------------------

# Variables we need.
#
# The order is important.
# Do not add a trailing slash if none present.
# --

# Datestamp + timestamp for logfiles
# Timestap uses seconds to allow for several logfiles on the same day.
# --
WGET_MANUAL_DATE=$(date +%Y-%m-%d_%T)

# Used by the next variable
# --
USER_NAME=$(whoami)

# Root folder for logs, PID files, etc.
# --
WGET_MANUAL_HOME=[LOCATION_HERE]/$USER_NAME

# Root folder of the destination
# --
WGET_MANUAL_PARTITION=[LOCATION_HERE]

# PID file location
# --
WGET_MANUAL_PIDFILE=$WGET_MANUAL_HOME/[LOCATION_HERE]/[FILE_NAME_HERE]

# The destination folder for the downloads
# --
WGET_MANUAL_DEST=$WGET_MANUAL_PARTITION/[LOCATION_HERE]

# The location of the file with links to download.
# This is also used by the menu script.
# --
WGET_MANUAL_CONFIG=$WGET_MANUAL_HOME/[LOCATION_HERE]/[FILE_NAME_HERE]

# The root folder for the logs
# --
WGET_MANUAL_LOGDIR=$WGET_MANUAL_HOME/[LOCATION_HERE]

# Datestamp for log folders in format: YYYY-MM-DD
# No timestamp!
--
WGET_MANUAL_LOG_DATE="`date +"%Y-%m-%d"`"

# Trailing entry is the name for your logfile.
# --
WGET_MANUAL_LOG_NAME="[FILE_NAME_HERE]"

# Run error traps here
# --
if [ -f ${WGET_MANUAL_PIDFILE} ]
then
  PID=$(cat ${WGET_MANUAL_PIDFILE})
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "Process already running"
    exit 1
  else
    ## Process not found, assume not running
    # --
    echo $$ > ${WGET_MANUAL_PIDFILE}
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > ${WGET_MANUAL_PIDFILE}
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 1
  fi
fi

# Set individual error traps.
# Can be used to trap intermediate errors.
# Optional.
# Use: [SHEL_COMMAND] || [fatal or warn] "Error text here."
# --
fatal() {
  echo "$1"
  exit 1
}

warn() {
  echo "$1"
}

# Create today's log folder if it doesn't exist.
# Don't if it does.
# --
[ ! -d ${WGET_MANUAL_LOGDIR}/${WGET_MANUAL_LOG_DATE} ] && mkdir ${WGET_MANUAL_LOGDIR}/${WGET_MANUAL_LOG_DATE}

# Run download here
# --
wget -P $WGET_MANUAL_DEST \
--execute robots=off --recursive --no-parent --continue --span-hosts --no-clobber --backup-converted \
--waitretry=10 --wait=10 --random-wait --cookies=on --save-cookies=cookies.txt \
-R ".DS_Store,Thumbs.db,thumbcache.db,desktop.ini,_macosx" \
--html-extension --adjust-extension --continue --timeout=180 --tries=10 \
-U "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A356 Safari/604.1" \
--referer="http://botzilla.tld/bot.html" \
-a ${WGET_MANUAL_LOGDIR}/${WGET_MANUAL_LOG_DATE}/${WGET_MANUAL_DATE}-${WGET_MANUAL_LOG_NAME}.log -i ${WGET_MANUAL_CONFIG}

# Clean up before turning the lights off
# --
rm -f ${WGET_MAN_PIDFILE}
exit
