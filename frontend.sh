#!/bin/bash

USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[34m"
N="\e[0m"

LOGS="/var/log/shell-robotshop"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS/$SCRIPTNAME.log"
SCRIPT_DIR=$(pwd)
MONGODB_HOST=mongodb.abhishekdev.fun


mkdir -p $LOGS
echo "script start at: $(date)" &>>$LOG_FILE

if [ $USER_ID -ne 0 ]; then
    echo -e $R "please login with root access $N"
    exit 1
fi

VALIDATE(){

    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R failure $N"
        exit 1
    else
        echo -e "$2 ...$G success $N"
    fi
}
dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
systemctl enable nginx 
systemctl start nginx 
rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx 