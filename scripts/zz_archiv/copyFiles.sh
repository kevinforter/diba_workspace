#!/bin/bash

# Set variables
con=diba-007.el.eee.intern
user=student
dbUser=DBstudent
dir="/usr/transfer/"
tranfser="/C:/Transfer/"
db=studierende_db
tbl=tbl_files

# Check SSH connection
if ssh -q "$user@$con" exit; then
        echo "Verbindung" $'\t' "OK"
else
        while ! ssh -q "$user@$con" exit; do
                echo "Verbindung" $'\t' "ERROR"
        done
fi

# Check MariaDB connection
if mysql -h "$con" -u "$dbUser" -pgeheim "$db" -e exit; then
        echo "Datenbank" $'\t' "OK"
else
        echo "Datenbank" $'\t' "ERROR"
fi

# Check if directory exists
if [ -d "$dir" ]; then
        echo "Ordner" $'\t\t' "OK"
else
        while [ ! -d "$dir" ]; do
                mkdir "$dir"
                echo "Ornder" $'\t\t' "WURDE ERSTELLT"
        done
fi

# Copy files to MariaDB
cd "$dir"
arr=(*)

if scp "$dir"/* "$user@$con:$transer"; then
        echo "Daten wurden erfolgreich Kopiert. Lokale Daten werden gelöscht"

	for ((i=0; i<${#arr[@]}; i++)); do
        	fileName=${arr[$i]}
        	fileData=$(cat $fileName | base64)
        	fileName=$(stat -c %n $fileName)
        	fileType=$(stat -c %F $fileName)
        	creatorName=$(stat -c %U $fileName)
        	createTime=$(stat -c %W $fileName)
        	formatTime=$(date -d @${createTime} +"%F %T")
        	copyTime=$(date +"%F %T")

        	mysql -h $con -u $dbUser -pgeheim $db -e "INSERT INTO $tbl (
                	fileName,
                	fileType,
                	creatorName,
                	copyTime,
                	createTime,
               		data) VALUES (
                	'$fileName',
                	'$fileType',
                	'$creatorName',
                	'$copyTime',
                	'$formatTime',
                	'$fileData'
        	);"
	done

        rm -r "$dir"/*
else
        if [ ! "$(ls -A $dir)" ]; then
                echo "Der Ordner $dir war leer"
        else
                echo "Es gab ein Problem. Daten konnten nicht kopiert werden"
        fi
fi

echo "Die Daten wurden erfolgreich übertragen"
