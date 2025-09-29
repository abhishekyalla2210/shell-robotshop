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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding the repo"

dnf install mongodb-org -y &>>$LOGFILE
VALIDATE $? "mongodb installation"

systemctl enable mongod
VALIDATE $? "enabled mongodb"

systemctl start mongod
VALIDATE $? "started mongodb"

sed -i ' s/127.0.0.1/0.0.0.0 'g  /etc/mongod.conf
VALIDATE $? "allowing all"

systemctl restart mongod
VALIDATE $? "restarted"