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

echo "Please enter the mysql root password"
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


dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping"

rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping"

mvn clean package  &>>$LOG_FILE
VALIDATE $? "packaging shipping app"

mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "copying the jas files"

cp $SCRIPT_DIR/shipping.service  /etc/systemd/system/shipping.service
VALIDATE $? "Moving and renaming jar file"

systemctl daemon-reload
VALIDATE $? "daemon reloaded"

systemctl enable shipping 
VALIDATE $? "enabling shipping"

systemctl start shipping
VALIDATE $? "starting shipping"

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "installing mysql"

mysql -h mysql.vinodh.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
VALIDATE $? "Login and Loading content to mysql for roboshop app"


mysql -h mysql.vinodh.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql 
VALIDATE $? "Login and Loading content to mysql for roboshop app"

mysql -h mysql.vinodh.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
VALIDATE $? "Login and Loading content to mysql for roboshop app"

systemctl restart shipping
VALIDATE $? "restarting the shipping application"



END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))


echo -e " Script execution completed successfully $Y total time taken : $TOTAL_TIME seconds $N" | tee -a $LOG_FILE