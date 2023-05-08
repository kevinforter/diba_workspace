# FileCopy

This script copies all files in a predefined folder to the Windows server. Also the file will be saved to the MariaDB and a TimeStamp will be set at which date and time the file was copied and created.

## Installation

No installation of the script is required. The following packages are required for the script to work:

```bash
sudo apt install mariadb-client
sudo apt install ssh-client
sudo apt install git
```

## Usage

```bash
git clone https://github.com/kevinforter/diba_workspace.git
cd diba_workspace/scripts/
```
First, the variables still need to be configured correctly. These can be found in 'fileCopy.config'.

### Variables
```
# Set variables
con=@Remote_Server
user=@Login_Name
dbUser=@Database_User
login=@password
db=@Databse_Name
tbl=@Table_Name
dir="@Local_Directory"
transer="@Remote_Directory"
GREEN='\033[0;32m'
RED='\033[0;31m'
NO='\033[0;0m'
```
```
./fileCopy.sh
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Feedback

If you have any feedback, please reach out to me at private.513wm@slmail.me

## License

[![MIT License](https://img.shields.io/badge/License-NONE-green.svg)](https://choosealicense.com/licenses/unlicense/)