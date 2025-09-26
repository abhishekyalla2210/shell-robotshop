#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[34m"

LOGS="/var/log/shell-script"
SCRIPTNAME=$( echo $0 | cut -d "." -f1 )
LOGFILE="$LOGS/$SCRIPTNAME.log" 

mkdir   -p  $LOGFILE
echo "script start at: $(date)"


if [ $USERID -ne 0 ]; then
    echo -e " $R please login with root access $N"
    exit 1
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e " $2 ... $R FAILURE $N" 
        exit 1
    else
        echo -e " $2 ... $G SUCCESS $N"
    fi
}



cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding the repo"

dnf install mongodb-org -y  &>>$LOGFILE
VALIDATE $? "mongodb installation"

