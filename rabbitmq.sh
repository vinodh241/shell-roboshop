#!/bin/bash

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




VALIDATE(){
    if [ $1 -eq 0 ]
    then 
       echo -e "Installing $2 is ... $G SUCCESS  $N " | tee -a $LOG_FILE
    else
       echo -e "Installing $2 is ... $R FAILURE  $N " | tee -a $LOG_FILE
       exit 1
    fi   
} 


cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "copying rabbitmq repos"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing rabbitmq server" 

systemctl enable rabbitmq-server
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "Adding user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "setting up the permissions" 


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))


echo -e " Script execution completed successfully $Y total time taken : $TOTAL_TIME seconds $N" | tee -a $LOG_FILE