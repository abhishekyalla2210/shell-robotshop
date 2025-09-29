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
dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "looking"

 id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
    VALIDATE $? "creating system user"
else
    echo -e "user already exist...$Y skipping $N"

fi

mkdir -p /app
VALIDATE $? "make dire"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "donwloading"
cd /app
rm -rf /app/*
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "installing pip3"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "looking"

systemctl daemon-reload
systemctl enable payment

systemctl start payment
VALIDATE $? "enabled"