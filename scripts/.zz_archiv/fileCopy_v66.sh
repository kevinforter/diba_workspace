#!/bin/bash

source fileCopy.config

function progressBar () {
        sleep 2
        echo -ne '                         [0%]\r'
        sleep 1
        echo -ne '>>                       [8%]\r'
        sleep 1
        echo -ne '>>>>                     [16%]\r'
        sleep 1
        echo -ne '>>>>>>                   [24%]\r'
        sleep 1
        echo -ne '>>>>>>>>                 [32%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>               [40%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>             [48%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>>>           [56%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>>>>>         [64%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>>>>>>>       [72%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>>>>>>>>>     [80%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>>>>>>>>>>>   [88%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>>>>>>>>>>>>> [96%]\r'
        sleep 1
        echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>[100%]\r'
        sleep 1
}

# Check SSH connection
if ssh -q "$user@$con" exit; then
	echo "Checking SSH connection"
	progressBar
	echo $'\n'"Verbindung"$'\t'"OK"
else
	while ! ssh -q "$user@$con" exit; do
		echo $'\n'"Verbindung"$'\t'"ERROR"
	done
fi

# Check MariaDB connection
if mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; then
	echo "Checking MariaDB connection"
    	progressBar
	echo $'\n'"Datenbank"$'\t'"OK"
else
	while ! mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; do
		echo $'\n'"Datenbank"$'\t'"ERROR"
	done
fi

# Check if directory exists
if [ -d "$dir" ]; then
	echo "Checking DIR connection"
    	progressBar
	echo $'\n'"Ordner"$'\t\t'"OK"
else
	while [ ! -d "$dir" ]; do
		mkdir "$dir"
		echo $'\n'"Ornder"$'\t\t'"WURDE ERSTELLT"$'\n'
	done
fi

# Change DIR and create Array
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

	# Copy files to MariaDB
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
	progressBar

    	echo $'\n'"Daten wurden erfolgreich auf Datenbank geschrieben."
    	echo "Lokale Daten werden gelöscht"
    	rm -r "$dir"/*
    	progressBar
	echo $'\n'"Daten wurden erfolgreich gelöscht"$'\n'
else
	if [ ! "$(ls -A $dir)" ]; then
    		echo "Der Ordner $dir war leer"$'\n'
	else
    		echo "Es gab ein Problem. Daten konnten nicht kopiert werden"$'\n'
	fi
fi
