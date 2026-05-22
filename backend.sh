#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/expenseshell-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$(date +%Y-%m-%d-%H-%M-%S).log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2....$R FAILURE $N"    
        exit 1
    else
         echo -e "$2....$G SUCCESS $N"
    fi
}

CHECK_ROOOT(){

    if [ $USERID -ne 0 ] 
    then
        echo "error: This script must be run as root."
        exit 1
    fi
}

echo "script execution started" &>>$LOG_FILE_NAME

CHECK_ROOOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disabling nodejs module"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling nodejs:20 module"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nodejs"

id expenseapp &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expenseapp &>>$LOG_FILE_NAME
    VALIDATE $? "creating expenseapp user"
else
    echo -e "expenseapp user already exists....$Y Skipping $N"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downloading backend code"


cd /app
rm-rf /app/* &>>$LOG_FILE_NAME

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping backend code"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "installing backend dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
VALIDATE $? "copying backend systemd service file"

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql client"

mysql -h mysql.devopsadipractice.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "creating backend database and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "reloading systemd daemon"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enabling backend service"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "restarting backend service"

