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
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "copied rabbitmq repo"
dnf install rabbitmq-server -y &>>$LOGFILE
VALIDATE $? "installed"
systemctl enable rabbitmq-server
VALIDATE $? "enabled"
systemctl start rabbitmq-server
VALIDATE $? "started"
rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "user added"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "permissions set"