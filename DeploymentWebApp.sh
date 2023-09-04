#!/bin/bash
#------------------------------------------------------------------------------
# DevOps - Devployment Web Application
# Author: Leonardo Batista
# OS: Debian 11
# Description: 
#   - Download Google Drive
#   - Extract zip
#   - Rename Old Directory
#   - Stop Services (nginx and MyAppService - dotnet core)
#   - Move Directory (unzip)
#   - Start Services (nginx and MyAppService)
#------------------------------------------------------------------------------

#Variables
SECONDS=0
fileNameStandard="MyAppFile.com.zip"
directoryWebApp="MyApp.com"
startDate=$(date '+%Y-%m-%d %X')
urlFileWebApp=""

clear
echo
read -p "FileId... : " urlFileId 
urlFileWebApp="https://docs.google.com/uc?export=download&confirm=CONFIRM_CODE&id=$urlFileId"

#echo $urlFileWebApp

if test -f "$fileNameStandard"; then
    sudo rm -rf $fileNameStandard
else
    echo "No such file $fileNameStandard :("
fi

echo
sudo wget --load-cookies %TMP%/cookies.txt --no-check-certificate "$urlFileWebApp" -O $fileNameStandard
if [ $? -eq 0 ]; then
    echo "Command succeeded... wget"
else
    echo "Command failed... wget :("
    echo "Execution stopped!!!"
    echo
    exit 1
fi

if test -d "$directoryWebApp"; then
    sudo rm -rf $directoryWebApp
else
    echo "No such directory $directoryWebApp :(" 
fi

echo
sudo unzip $fileNameStandard
if [ $? -eq 0 ]; then
    echo "Command succeeded... unzip"
else
    echo "Command failed... unzip :("
fi
wait

echo
if test -d "__MACOSX"; then
    sudo rm -rf __MACOSX
else
    echo "No such directory __MACOSX :(" 
fi

echo
ls -la

echo
echo "Stopping services...."
echo
sudo systemctl stop MyAppService
if [ $? -eq 0 ]; then
    echo "Command succeeded... stop MyAppService"
else
    echo "Command failed... stop MyAppService :("
fi
wait

echo
sudo systemctl stop nginx
if [ $? -eq 0 ]; then
    echo "Command succeeded... stop nginx"
else
    echo "Command failed... stop nginx :("
fi
wait

echo
echo "Backup..."                        
echo "Directory rename"

if test -d "/var/www/html/$directoryWebApp"; then
    sudo mv /var/www/html/$directoryWebApp /var/www/html/$directoryWebApp"_"$(date '+%Y-%m-%d_%H%M%S')
else
    echo "No such directory /var/www/$directoryWebApp :("
fi

echo
echo "Moving directory (unzip)...."
if test -d "$directoryWebApp"; then
    sudo mv -vf $directoryWebApp /var/www/html/
else
    echo "No such directory $directoryWebApp :("
fi

echo
echo "Starting services...."
echo
sudo systemctl start MyAppService
if [ $? -eq 0 ]; then
    echo "Command succeeded... start MyAppService"
else
    echo "Command failed... start MyAppService :("
fi
wait

echo
sudo systemctl start nginx
if [ $? -eq 0 ]; then
    echo "Command succeeded... start nginx"
else
    echo "Command failed... start nginx :("
fi
wait

echo
echo "Start-Process... " $startDate
echo "End-Process..... " $(date '+%Y-%m-%d %X')
duration=$SECONDS
echo "Time Elapsed....  $(($duration / 60)) minutes and $(($duration % 60)) seconds"
echo
exit 0