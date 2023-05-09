#!/bin/bash

# Source files:
# https://stackoverflow.com/questions/1405324/how-to-create-a-bash-script-to-check-the-ssh-connection
# https://kapeli.com/cheat_sheets/Bash_Test_Operators.docset/Contents/Resources/Documents/index
# https://www.cyberciti.biz/faq/linux-unix-shell-check-if-directory-empty/
# https://www.baeldung.com/linux/install-custom-bash-scripts
# https://www.thoughtco.com/storing-data-and-files-in-mysql-2694013
# https://www.geeksforgeeks.org/stat-command-in-linux-with-examples/

# Set variables
con=diba-007.el.eee.intern
user=student
dbUser=DBstudent
login=geheim
db=studierende_db
tbl=tbl_files
dir="/usr/transfer"
transer="/C:/Transfer/"

if ssh -q "$user@$con" exit; then
	# Check SSH connection
	echo "Checking SSH connection"
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
	echo $'\n'"Verbindung"$'\t'"OK"
	#echo $'\n'
else
	while ! ssh -q "$user@$con" exit; do
		echo $'\n'"Verbindung"$'\t'"ERROR"
		echo $'\n'
	done
fi

if mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; then
	# Check MariaDB connection
	echo "Checking MariaDB connection"
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
	echo $'\n'"Datenbank"$'\t'"OK"
	echo $'\n'
else
	while ! mysql -h "$con" -u "$dbUser" -p$login "$db" -e exit; do
		echo $'\n'"Datenbank"$'\t'"ERROR"
		echo $'\n'
	done
fi

# Check if directory exists
if [ -d "$dir" ]; then
	echo "Checking DIR connection"
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
	echo $'\n'"Ordner"$'\t\t'"OK"
	echo $'\n'
else
	while [ ! -d "$dir" ]; do
		mkdir "$dir"
		echo $'\n'"Ornder"$'\t\t'"WURDE ERSTELLT"
		echo $'\n'
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
        echo $'\n'"Daten wurden erfolgreich auf Datenbank geschrieben."
	echo $'\n'

        echo "Lokale Daten werden gelöscht"
        rm -r "$dir"/*
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
	echo $'\n'

else
	if [ ! "$(ls -A $dir)" ]; then
    		echo "Der Ordner $dir war leer"
		echo $'\n'
	else
    		echo "Es gab ein Problem. Daten konnten nicht kopiert werden"
		echo $'\n'
	fi
fi
