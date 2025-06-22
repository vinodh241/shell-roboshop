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

dnf install python3 gcc python3-devel -y
VALIDATE $? "installing python"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "creating a directiory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment"

rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping payment"


pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? " installing python dependencies"

cp $SCRIPT_DIR/payment.service //etc/systemd/system/payment.service
VALIDATE $? "copying the payment services"

systemctl daemon-reload
VALIDATE $? "daemon reloaded"

systemctl enable payment 
VALIDATE $? "enabling payment"

systemctl start payment
VALIDATE $? "started payment"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))


echo -e " Script execution completed successfully $Y total time taken : $TOTAL_TIME seconds $N" | tee -a $LOG_FILE