#!/bin/bash

source fileCopy.config

function main () {
        # Ausfüjrung der Funktionen
        checkConnection
        copyFiles
}

function checkConnection () {

	if ssh -q "$user@$con" exit; then
		# Check SSH connection
        	echo "Verbindungen wird überprüft"
        	echo "SSH"$'\t\t'"[Connecting....]"
        	echo "MariaDB"$'\t\t'"[              ]"
        	echo "Ordner"$'\t\t'"[              ]"
        	progressBar
		tput cuu 3
		echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
		echo "MariaDB"$'\t\t'"[              ]"
		echo "Ordner"$'\t\t'"[              ]"
		tput cuu 3
	else
		while ! ssh -q "$user@$con" exit; do
			echo -e "SSH"$'\t\t'"[${RED}ERROR${NO}         ]"
			echo "MariaDB"$'\t\t'"[              ]"
			echo "Ordner"$'\t\t'"[              ]"
			tput cuu 3
		done
		echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
		echo "MariaDB"$'\t\t'"[              ]"
		echo "Ordner"$'\t\t'"[              ]"
		tput cuu 3
	fi

	# Check MariaDB connection
	echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
	echo "MariaDB"$'\t\t'"[Connecting....]"
	echo "Ordner"$'\t\t'"[              ]"
	progressBar
	tput cuu 3

	if mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; then
	        echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo -e "MariaDB"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo "Ordner"$'\t\t'"[              ]"
		tput cuu 3
	else
		while ! mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; do
			echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
			echo "MariaDB"$'\t\t'"[${RED}ERROR${NO}         ]"
			echo "Ordner"$'\t\t'"[              ]"
			tput cuu 3
		done
		echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo -e "MariaDB"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo "Ordner"$'\t\t'"[              ]"
		tput cuu 3
	fi

	# Check if directory exists
	echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
	echo -e "MariaDB"$'\t\t'"[${GREEN}OK${NO}            ]"
	echo "Ordner"$'\t\t'"[Connecting....]"
	progressBar
	tput cuu 3

	if [ -d "$dir" ]; then
	        echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo -e "MariaDB"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo -e "Ordner"$'\t\t'"[${GREEN}OK${NO}            ]"$'\n\n'
	else
		while [ ! -d "$dir" ]; do
			mkdir "$dir"
			echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
			echo -e "MariaDB"$'\t\t'"[${GREEN}OK${NO}            ]"
			echo "Ordner"$'\t\t'"[${RED}WURDE ERSTELLT${NO}]"
			sleep 2
			tput cuu 3
		done
		echo -e "SSH"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo -e "MariaDB"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo -e "Ordner"$'\t\t'"[${GREEN}OK${NO}            ]"$'\n\n'
	fi
}

function copyFiles () {

	# Change DIR and create Array
	cd $dir
	arr=(*)

	if scp -q "$dir"/* "$user@$con:$transer"; then
		 # Copy files from Linux server to Windows
        	echo "Daten werden kopiert"
        	echo "Ordner"$'\t\t'"[Copying.......]"
        	echo "MariaDB"$'\t\t'"[              ]"
        	progressBar
        	tput cuu 2
	        echo -e "Ordner"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo "MariaDB"$'\t\t'"[              ]"
		tput cuu 2

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

	        echo -e "Ordner"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo "MariaDB"$'\t\t'"[Copying.......]"
		progressBar
		tput cuu 2
	        echo -e "Ordner"$'\t\t'"[${GREEN}OK${NO}            ]"
	        echo -e "MariaDB"$'\t\t'"[${GREEN}OK${NO}            ]"$'\n'
		echo "Daten wurden erfolgreich Kopiert."$'\n'

		rm -r "$dir"/*
		echo "Lokale Daten werden gelöscht"
		echo "Ordner"$'\t\t'"[Deleting......]"
		progressBar
		tput cuu 1
		echo -e "Ordner"$'\t\t'"[${GREEN}OK${NO}            ]"$'\n'
		echo "Daten wurden erfolgreich gelöscht"$'\n'

	else
		if [ ! "$(ls -A $dir)" ]; then
			echo -e "Ordner"$'\t\t'"[${RED}ERROR${NO}         ]"
	        	echo "MariaDB"$'\t\t'"[              ]"$'\n'
	    		echo "Der Ordner $dir war leer"$'\n'
		else
			echo -e "Ordner"$'\t\t'"[${RED}ERROR${NO}         ]"
	        	echo "MariaDB"$'\t\t'"[              ]"$'\n'
	    		echo "Es gab ein Problem. Daten konnten nicht kopiert werden"$'\n'
		fi
	fi
}

function progressBar () {
	sleep 2
	echo -ne '[                         [  0%]\r'
        sleep 0.5
        echo -ne '[>>                       [  8%]\r'
        sleep 0.5
        echo -ne '[>>>>                     [ 16%]\r'
        sleep 0.5
        echo -ne '[>>>>>>                   [ 24%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>                 [ 32%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>               [ 40%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>>>             [ 48%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>>>>>           [ 56%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>>>>>>>         [ 64%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>>>>>>>>>       [ 72%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>>>>>>>>>>>     [ 80%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>>>>>>>>>>>>>   [ 88%]\r'
        sleep 0.5
        echo -ne '[>>>>>>>>>>>>>>>>>>>>>>>> [ 96%]\r'
        sleep 0.5
        echo -n -e "[>>>>>>>>>>>>>>>>>>>>>>>>>[${GREEN}100%${NO}]\r"
        sleep 2
}

# Call Main
main
