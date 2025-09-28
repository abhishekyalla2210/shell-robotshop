#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[34m"
N="\e[0m"

LOGS="/var/log/shell-robotshop"
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE="$LOGS/$SCRIPTNAME.log"
MYSQL_IP=mysql.abhishekdev.fun
SCRIPT_DIR=$(pwd)

mkdir -p $LOGS
echo "script start at: $(date)" &>>$LOGFILE

if [ $USERID -ne 0 ]; then
    echo -e " $R please login with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e " $2 ... $R FAILURE $N"
        exit 1
    else
        echo -e " $2 ... $G SUCCESS $N"
    fi
}
dnf install maven -y
VALIDATE $? "installed"

if [ $? -ne 0]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

fi



mkdir /app 
VALIDATE $? "made directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "downloaded"

cd /app 
unzip /tmp/shipping.zip
VALIDATE $? "unzipped"
cd /app 
mvn clean package 
VALIDATE $? "cleaned"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE "copied shipping service" 

systemctl daemon-reload
VALIDATE $? "reloaded"

systemctl enable shipping
VALIDATE $? "enabled" 

systemctl start shipping
VALIDATE $? "shipping started"


