#!/bin/bash

USER_ID =$(id -u)

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

dnf module disable redis -y
VALIDATE $? "redis disable"
dnf module enable redis:7 -y
VALIDATE $? "enable redis"
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "changed remote"

sed -i 's/protected-mode/protected-mode no'g /etc/redis/redis.conf
VALIDATE $? "protect mode"
systemctl enable redis 
VALIDATE $? "enabled"
systemctl start redis 
VALIDATE $? "started"
