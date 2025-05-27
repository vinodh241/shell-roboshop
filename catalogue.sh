#!/bin/bash

#This is catalogue

USERID=$( id -u )
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER

echo "Script started executing at: $(date)" | tee -a $LOG_FILE

#LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

if [ $USERID -ne 0 ]
then
   echo -e "$R ERROR:: Please run this script with root access $N " | tee -a &LOG_FILE
   exit 1
else
   echo -e "$G youre running with root access $N " | tee -a $LOG_FILE
   fi
VALIDATE(){
    if [ $1 -eq 0 ]
    then 
       echo -e "Installing $2 is ... $G SUCCESS  $N " | tee -a $LOG_FILE
    else
       echo -e "Installing $2 is ... $R FAILURE  $N " | tee -a $LOG_FILE
       exit 1
    fi   
} 

dnf module disable nodejs -y
VALIDATE $? "disbaling default nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling nodejs-20 version"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding application user"

mkdir /app 
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading the catalogue.zip files"


cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping catalogue"

cd /app
npm install  &>>$LOG_FILE
VALIDATE $? "installing npm dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "cpoying catalogue services"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue

VALIDATE $? "strating catalogue services"

cp $SCRIPT_DIR/monogodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repos"

dnf install mongodb-mongosh -y &>>$LOG_FILE 
VALIDATE $? "installing mongodb client"

mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js
VALIDATE $?  "Loading data into mangodb"


