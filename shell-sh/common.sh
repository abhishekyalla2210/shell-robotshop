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
START_TIME=$(date +%s)



mkdir -p $LOGS
echo "script start at: $(date)" &>>$LOG_FILE

CHECK_ROOT(){

    if [ $USER_ID -ne 0 ]; then
    echo -e $R "please login with root access $N"
    exit 1
fi
}

VALIDATE(){

    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R failure $N"
        exit 1
    else
        echo -e "$2 ...$G success $N"
    fi
}

NODEJS_SETUP(){

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "disabled"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enable"
dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "installation"
npm install &>>$LOG_FILE
VALIDATE $? "installed npm"
}

JAVA_SETUP(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Packing the application"
    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Renaming the artifact"
}

PYTHON_SETUP(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

APP_SETUP(){

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOG_FILE
    VALIDATE $? "creating system user" 
else
    echo -e "user already exist...$Y skipping $N"

fi
 mkdir -p /app
VALIDATE $? "created dir"
curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOG_FILE
VALIDATE $? "download"
cd /app 
VALIDATE $? "changed to dir"
rm -rf /app/*
VALIDATE $? "removing old code"
unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
VALIDATE $? "unzip $APP_NAME"
}

SYSTEM_SETUP(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "Copy systemctl service"
    systemctl daemon-reload
    systemctl enable $APP_NAME &>>$LOG_FILE
    VALIDATE $? "Enable $APP_NAME"
}
APP_RESTART(){
systemctl restart $APP_NAME
    VALIDATE $? "Restarted $APP_NAME"
}

PRINT_TOTAL_TIME(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}