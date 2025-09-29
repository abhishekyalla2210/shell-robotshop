# #!/bin/bash

# USERID=$(id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# W="\e[34m"
# N="\e[0m"

# LOGS="/var/log/shell-robotshop"
# SCRIPTNAME=$(echo $0 | cut -d "." -f1)
# LOGFILE="$LOGS/$SCRIPTNAME.log"
# SCRIPT_DIR=$(pwd)
# MYSQL_ID=mysql.abhishekdev.fun

# mkdir -p $LOGS
# echo "script start at: $(date)" &>>$LOGFILE

# if [ $USERID -ne 0 ]; then
#     echo -e " $R please login with root access $N"
#     exit 1
# fi

# VALIDATE(){
#     if [ $1 -ne 0 ]; then
#         echo -e " $2 ... $R FAILURE $N"
#         exit 1
#     else
#         echo -e " $2 ... $G SUCCESS $N"
#     fi
# }
# dnf install maven -y &>>$LOGFILE
# VALIDATE $? "installed"

# id roboshop
# if [ $? -ne 0 ]; then
# useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
# else
#     echo -e "user already exist...$Y skipping $N"

# fi


# if [ -d "/app" ]; then
#     echo "Directory exists"
# else
#     mkdir /app
# fi




# curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
# VALIDATE $? "downloaded"

# cd /app 
# rm -rf /app/*

# unzip /tmp/shipping.zip
# VALIDATE $? "unzipped"
# cd /app 
# mvn clean package 
# VALIDATE $? "cleaned"

# mv target/shipping-1.0.jar shipping.jar 
# VALIDATE $? "MVED"


# cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
# VALIDATE $? "copied shipping service" 

# systemctl daemon-reload
# VALIDATE $? "reloaded"

# systemctl enable shipping
# VALIDATE $? "enabled" 

# systemctl start shipping
# VALIDATE $? "shipping started"


# dnf install mysql -y &>>$LOGFILE

# VALIDATE $? "installed mysql"

# mysql -h mysql.abhishekdev.fun -uroot -pRoboShop@1 -e 'use cities' &>>$LOGFILE

# if [ $? -ne 0 ]; then
# mysql -h $MYSQL_ID -uroot -pRoboShop@1 < /app/db/schema.sql 
# mysql -h $MYSQL_ID -uroot -pRoboShop@1 < /app/db/app-user.sql  
# mysql -h $MYSQL_ID -uroot -pRoboShop@1 < /app/db/master-data.sql 
# else
#     echo "shipping data already exist ...$Y skipping $N"
# fi
# systemctl restart shipping

#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
#MONGODB_HOST=mongodb.abhishekdev.fun
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
MYSQL_HOST=mysql.abhishekdev.fun

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install maven -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzip shipping"

mvn clean package  &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar 

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
systemctl daemon-reload
systemctl enable shipping  &>>$LOG_FILE

dnf install mysql -y  &>>$LOG_FILE

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping