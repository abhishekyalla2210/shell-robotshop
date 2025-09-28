#!/bin/bash

USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[34m"
N="\e[0m"

LOGS=/var/log/shell-robotshop/
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS/$SCRIPT_NAME.log

mkdir -p $LOGS

echo -e ''script start time: $(date)

if [ $USER_ID -ne 0 ]; then
    echo -e " $R please login with root access $N "
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
    echo -e "$2...$R failure $N"
else   
    echo -e "$2..,$G success $N"
fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installed mysql"
systemctl enable mysqld
VALIDATE $? "enabled"
systemctl start mysqld
VALIDATE $? "started"  
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "passwordset"
