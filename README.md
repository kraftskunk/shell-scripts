# Shell scripts
A collection of shell scripts I use.

### **Menu script for wget**
I archive a lot. Hence the incredible amount of scripts and cron entries I use to make it happen. The scripts run from cron on a Debian server.

But sometimes I want or need to download specific files only. Outside of the set frequencies of the cron scripts.

This script is a front-end to a simple *txt file that contains the links to the data I want wget to download.
The script contains a set of variables that can be adjusted for specific needs: source, logfile location, download location, etc.
The menu allows to view, add, delete and rotate the *.txt file containing the links.
