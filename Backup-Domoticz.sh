#!/bin/bash

# Setup
DOMOTICZ_SERVER="x.x.x.x:yy"   # IP-adres:Poort van je Domoticz server
FTP_SERVER="x.x.x.x:yy"        # IP-adres:Poort van je FTP server
FTP_USERNAME="username"        # Gebruikersnaam voor FTP
FTP_PASSWORD="password"        # Wachtwoord voor FTP
FTP_DIRECTORY="/map/map"       # Locatie op je FTP voor de Backup

# No need to edit below here.
echo "Start running backup script."

TIMESTAMP=`/bin/date +%Y%m%d%H%M%S`

# Create temp-directory if it does not already exists.
TEMP_DIR="/home/pi/temp"

if [ -d $TEMP_DIR ] ; then
    echo "- Temp-directory already exists, no need to create it."
else
    echo "- Temp-directory does not exists, creating it now."
    /bin/mkdir $TEMP_DIR
fi

# Create backup file for database.
echo "- Creating backup file for database."
BACKUP_DB=$TIMESTAMP"_db.db"
BACKUP_DB_GZ=$BACKUP_DB".gz"
/usr/bin/curl -s http://$DOMOTICZ_SERVER/backupdatabase.php > $TEMP_DIR/$BACKUP_DB
gzip -9 $TEMP_DIR/$BACKUP_DB

# Create backup file for scripts directory.
echo "- Creating backup file for scripts-directory."
BACKUP_SCRIPTS=$TIMESTAMP"_scripts.tar.gz"
tar -zcf $TEMP_DIR/$BACKUP_SCRIPTS /home/pi/domoticz/scripts/

# Create backup file for crontab.
echo "- Creating backup file for crontab."
BACKUP_CRONTAB=$TIMESTAMP"_crontab.txt"
crontab -l > $TEMP_DIR/$BACKUP_CRONTAB

# Send backup files to FTP location.
echo "- Sending backup files to FTP location."
#BACKUP_FTP_FILES=$TEMP_DIR"/"$BACKUP_DB_GZ","$TEMP_DIR"/"$BACKUP_SCRIPTS","$TEMP_DIR"/"$BACKUP_CRONTAB
curl -s --disable-epsv -T "{$TEMP_DIR/$BACKUP_DB_GZ,$TEMP_DIR/$BACKUP_SCRIPTS,$TEMP_DIR/$BACKUP_CRONTAB}" -u "$FTP_USERNAME:$FTP_PASSWORD" "ftp://"$FTP_SERVER$FTP_DIRECTORY"/"

# Remove temp backup file
echo "- Removing temp files."
/bin/rm $TEMP_DIR/$BACKUP_DB_GZ
/bin/rm $TEMP_DIR/$BACKUP_SCRIPTS
/bin/rm $TEMP_DIR/$BACKUP_CRONTAB

# Domoticz logging
echo "- Writing log to Domoticz."
wget -q --delete-after "http://$DOMOTICZ_SERVER/json.htm?type=command&param=addlogmessage&message=Backup to FTP script finished with timestamp ID $TIMESTAMP."

# Done!
echo "Done running backup script."
Over Blog
