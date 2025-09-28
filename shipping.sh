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
dnf install maven -y &>>$LOGFILE
VALIDATE $? "installed"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGFILE
VALIDATE $? "added system user"

mkdir /app 
VALIDATE $? "made directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGFILE
VALIDATE $? "downloaded"

cd /app 
unzip /tmp/shipping.zip
VALIDATE $? "unzipped"
cd /app 
mvn clean package &>>$LOGFILE
VALIDATE $? "cleaned"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE "copied shipping service" 

systemctl daemon-reload
VALIDATE $? "reloaded"

systemctl enable shipping
VALIDATE $? "enabled" 

systemctl start shipping
VALIDATE $? "shipping started"


dnf install mysql -y &>>$LOGFILE

VALIDATE $? "installed mysql"

mysql -h $MYSQL_IP -uroot -pRoboShop@1 -e 'use cities' &>>$LOGFILE

if [ $? -ne 0]; then
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGFILE
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOGFILE
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGFILE
else
    echo "shipping data already exist ...$Y skipping $N"
fi
systemctl restart shipping