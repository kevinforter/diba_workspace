#!/bin/bash

# Set variables
con=diba-007.el.eee.intern
user=student
dbUser=DBstudent
dir="/user/transfer/"
tranfser="/C:/Transfer/"
db=studierende_db
tbl=tbl_files

# Copy files to MariaDB
cd /usr/transfer/

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
