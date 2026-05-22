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

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql-server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling mysql-server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql-server"

mysql -h mysql.devopsadipractice.online -u root -pExpenseApp@1 -e 'show databases;'

if [ $? -ne 0 ]; then
    echo "mysql root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-password ExpenseApp@1 &>>$LOG_FILE_NAME
    VALIDATE $? "setting mysql root password"
else
    echo -e "MySQL root password is already setup....$y Skipping $N"
fi





