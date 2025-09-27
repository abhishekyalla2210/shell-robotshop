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

if [ $USER_ID -ne 0]; then
    echo -e $R "please login with root access $N"
    exit 1
fi

VALIDATE(){

    if [ $1 -ne 0]; then
        echo -e "$2 ...$R failure $N"
        exit 1
    else
        echo -e "$2 ...$G success $N"
    if
}
dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "disabled"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enable"
dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "installation"
id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
    VALIDATE $? "creating system user" 
else
    echo "user already exist...$Y skipping $N"

fi

mkdir -p /app
VALIDATE $? "created dir"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "download"
cd /app 
VALIDATE $? "changed to dir"
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"
npm install &>>$LOG_FILE
VALIDATE $? "installed npm"
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copied"
systemctl daemon-reload
VALIDATE $? "reloading"
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enabiling"
echo -e "Catalogue application setup ... $G SUCCESS $N"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copied mongorepo"
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "mongodb-mongsh installed"
mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "load catalogue products"
systemctl restart catalogue
VALIDATE $? "restarted catalogue"