#!/bin/bash

echo -e "Script name is : $G $0 $N "

START_TIME=$(date +%s)  # here declearing start time 
USERID=$( id -u )
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started execution: $(date)"

if [ $USERID -ne 0 ]
then
   echo -e "$R ERROR:: Please run this script with root access $N " | tee -a &LOG_FILE
   exit 1
else
   echo -e "$G youre running with root access $N " | tee -a $LOG_FILE
   fi


echo "Please enter thw mysql root password"
read -s MYSQL_ROOT_PASSWORD

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
       echo -e "Installing $2 is ... $G SUCCESS  $N " | tee -a $LOG_FILE
    else
       echo -e "Installing $2 is ... $R FAILURE  $N " | tee -a $LOG_FILE
       exit 1
    fi   
} 


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing MySql server"

systemctl enable mysqld
VALIDATE $? "enablling MySql server"

systemctl start mysqld  
VALIDATE $? "starting MySql Server"


mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD
VALIDATE $? " setuping root password to login mysql server"

END_TIME=$( date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME))

echo -e " $G Script execution is completed successfully $Y total time taken : $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
