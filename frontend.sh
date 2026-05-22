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

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "cleaning default nginx html directory"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "downloading frontend code"

cd /usr/share/nginx/html
VALIDATE $? "changing directory to nginx html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "extracting frontend code"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "restarting nginx"

