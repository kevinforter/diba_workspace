#!/bin/bash

# Set variables
con=diba-007.el.eee.intern
user=student
dbUser=DBstudent
login=geheim
db=studierende_db
tbl=tbl_files
dir="/usr/transfer"
transer="/C:/Transfer/"

# Check SSH connection
if ssh -q "$user@$con" exit; then
	
	echo "Checking SSH connection"
	sleep 2
    for i in {0..100..8}; do
        arrows=$(seq -s '>' $((i/4)) | tr -d '[:digit:]')
        spaces=$(seq -s ' ' $(((100-i)/4)) | tr -d '[:digit:]')
        echo -ne "$arrows$spaces[$i%]\r"
        sleep 1
    done
    echo -ne "\n"
	echo $'\n'"Verbindung"$'\t'"OK"
else
	while ! ssh -q "$user@$con" exit; do
		echo $'\n'"Verbindung"$'\t'"ERROR"
	done
fi

# Check MariaDB connection
if mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; then
	
	echo "Checking MariaDB connection"
    sleep 2
    for i in {0..100..8}; do
        arrows=$(seq -s '>' $((i/4)) | tr -d '[:digit:]')
        spaces=$(seq -s ' ' $(((100-i)/4)) | tr -d '[:digit:]')
        echo -ne "$arrows$spaces[$i%]\r"
        sleep 1
    done
    echo -ne "\n"
	echo $'\n'"Datenbank"$'\t'"OK"
else
	while ! mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; do
		echo $'\n'"Datenbank"$'\t'"ERROR"
	done
fi

# Check if directory exists
if [ -d "$dir" ]; then
	echo "Checking DIR connection"
	sleep 2
	for i in {0..100..8}; do
        arrows=$(seq -s '>' $((i/4)) | tr -d '[:digit:]')
        spaces=$(seq -s ' ' $(((100-i)/4)) | tr -d '[:digit:]')
        echo -ne "$arrows$spaces[$i%]\r"
        sleep 1
    done
    echo -ne "\n"
	echo $'\n'"Ordner"$'\t\t'"OK"
else
	while [ ! -d "$dir" ]; do
		mkdir "$dir"
		echo $'\n'"Ornder"$'\t\t'"WURDE ERSTELLT"
	done
fi

# Copy files to MariaDB

cd $dir
arr=(*)

# Copy files from Linux server to Windows
if scp "$dir"/* "$user@$con:$transer"; then
	echo "Daten wurden erfolgreich kopiert"
        echo "Daten werden auf Datenbank geschrieben"
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

    sleep 2
    
    for i in {0..100..8}; do
        arrows=$(seq -s '>' $((i/4)) | tr -d '[:digit:]')
        spaces=$(seq -s ' ' $(((100-i)/4)) | tr -d '[:digit:]')
        echo -ne "$arrows$spaces[$i%]\r"
        sleep 1
    done
    echo -ne "\n"
    
    echo $'\n'"Daten wurden erfolgreich auf Datenbank geschrieben."

    echo "Lokale Daten werden gelöscht"
    rm -r "$dir"/*
    sleep 2
    
    for i in {0..100..8}; do
        arrows=$(seq -s '>' $((i/4)) | tr -d '[:digit:]')
        spaces=$(seq -s ' ' $(((100-i)/4)) | tr -d '[:digit:]')
        echo -ne "$arrows$spaces[$i%]\r"
        sleep 1
    done
    echo -ne "\n"
	echo $'\n'

else
	if [ ! "$(ls -A $dir)" ]; then
    		echo "Der Ordner $dir war leer"
	else
    		echo "Es gab ein Problem. Daten konnten nicht kopiert werden"
	fi
fi
