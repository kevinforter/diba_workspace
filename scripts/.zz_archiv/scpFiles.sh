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
db=studierende_db
tbl=tbl_files
dir="/usr/transfer"
transer="/C:/Transfer/"

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
cd $dir

arr=(*)

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

# Copy files from Linux server to Windows
if scp "$dir"/* "$user@$con:$transer"; then
	echo "Daten wurden erfolgreich Kopiert. Lokale Daten werden gelöscht"
	rm -r "$dir"/*
else
	if [ ! "$(ls -A $dir)" ]; then
    		echo "Der Ordner $dir war leer"
	else
    		echo "Es gab ein Problem. Daten konnten nicht kopiert werden"
	fi
fi
