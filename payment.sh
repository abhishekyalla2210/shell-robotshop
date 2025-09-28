#!/bin/bash

# -----------------------------
# RoboShop Payment Deployment
# -----------------------------

USER_ID=$(id -u)
LOGS="/var/log/shell-robotshop"
SCRIPT_NAME=$(echo "$0" | cut -d "." -f1)
LOG_FILE="$LOGS/$SCRIPT_NAME.log"
SCRIPT_DIR=$(pwd)
APP_USER="roboshop"
APP_HOME="/app"
MONGODB_HOST="mongodb.abhishekdev.fun"
PAYMENT_URL="https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip"

# Color codes
R="\e[31m"
G="\e[32m"
N="\e[0m"

# Create log directory
mkdir -p $LOGS
echo -e "Script started at: $(date)\n" &>>$LOG_FILE

# Root check
if [ $USER_ID -ne 0 ]; then
    echo -e "$R Please run the script with root access $N"
    exit 1
fi

# Function to validate each step
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R FAILURE $N" &>>$LOG_FILE
        exit 1
    else
        echo -e "$2 ...$G SUCCESS $N" &>>$LOG_FILE
    fi
}

# Install required packages
dnf install python3 gcc python3-devel unzip -y &>>$LOG_FILE
VALIDATE $? "Install required packages"

# Create system user if not exists
if id $APP_USER &>/dev/null; then
    echo "User $APP_USER already exists" &>>$LOG_FILE
else
    useradd --system --home $APP_HOME -m --shell /sbin/nologin --comment "RoboShop system user" $APP_USER &>>$LOG_FILE
    VALIDATE $? "Create $APP_USER user"
fi

# Create /app directory if not exists
if [ ! -d $APP_HOME ]; then
    mkdir -p $APP_HOME
    VALIDATE $? "Create $APP_HOME directory"
else
    echo "$APP_HOME directory already exists" &>>$LOG_FILE
fi

# Download the payment service zip
curl -L -o /tmp/payment.zip $PAYMENT_URL &>>$LOG_FILE
VALIDATE $? "Download payment service"

# Extract the service
cd $APP_HOME
unzip -o /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Extract payment service"

# Install Python dependencies
pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Install Python dependencies"

# Copy systemd service file
cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copy payment systemd service"

# Reload systemd and enable/start service
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enable payment service"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Start payment service"

echo -e "\nDeployment completed successfully!" &>>$LOG_FILE
