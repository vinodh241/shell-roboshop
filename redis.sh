#!/bin/bash

USERID=$( id -u )
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enable redis 7 "
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"


