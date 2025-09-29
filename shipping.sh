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
SCRIPT_DIR=$(pwd)

mkdir -p $LOGS
echo "script start at: $(date)" &>>$LOGFILE

if [ $USERID -ne 0 ]; then
    echo -e " $R Please run with root access $N"
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e " $2 ... $R FAILURE $N"
        exit 1
    else
        echo -e " $2 ... $G SUCCESS $N"
    fi
}

# 1. Install Maven
dnf install maven -y &>>$LOGFILE
VALIDATE $? "Maven installed"

# 2. Create roboshop user if not exists
id roboshop &>>$LOGFILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGFILE
    VALIDATE $? "roboshop user created"
else
    echo -e "User already exists... $Y Skipping $N"
fi

# 3. Create /app if not exists
if [ ! -d "/app" ]; then
    mkdir /app
    VALIDATE $? "/app directory created"
else
    echo -e "/app directory already exists... $Y Skipping $N"
fi

# 4. Download and setup shipping app
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGFILE
VALIDATE $? "Shipping app downloaded"

cd /app
rm -rf /app/* &>>$LOGFILE
unzip /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "Unzipped shipping code"

# 5. Build JAR
mvn clean package &>>$LOGFILE
VALIDATE $? "Maven build successful"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "JAR renamed to shipping.jar"

# 6. Copy systemd service
cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "Copied shipping.service"

# 7. Enable & start service
systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Systemd reloaded"

systemctl enable shipping &>>$LOGFILE
VALIDATE $? "Shipping service enabled"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Shipping service started"

# 8. Install MySQL client
dnf install mysql -y &>>$LOGFILE
VALIDATE $? "MySQL client installed"

# 9. Load database schema if not present
mysql -h mysql.abhishekdev.fun -uroot -p'RoboShop@1' -e 'USE cities;' &>>$LOGFILE
if [ $? -ne 0 ]; then
    mysql -h mysql.abhishekdev.fun -uroot -p'RoboShop@1' < /app/db/schema.sql &>>$LOGFILE
    mysql -h mysql.abhishekdev.fun -uroot -p'RoboShop@1' < /app/db/app-user.sql &>>$LOGFILE
    mysql -h mysql.abhishekdev.fun -uroot -p'RoboShop@1' < /app/db/master-data.sql &>>$LOGFILE
    VALIDATE $? "Database schema loaded"
else
    echo -e "Shipping data already exists... $Y Skipping $N"
fi

# 10. Restart service after DB load
systemctl restart shipping &>>$LOGFILE
VALIDATE $? "Shipping service restarted"

echo -e "$G ✅ Shipping deployment completed successfully! $N"
