START_TIME=$(date +%s)
USERID=$( id -u ) 
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[30m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at:$(date)" | tee -a $LOG_FILE

# check the user id has root privigea are not
if [ $USERID -ne 0 ]
then
    echo -e "$R  ERROR:: Plase run this script with root access $N" | tee -a $LOGFILE
    exit 1
else
    echo -e "$G Your running this script with root access $N" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE (){
    if [ $1 -eq 0 ]
    then
        echo -e " $2 is ..  $G SUCCESS $N " | tee -a $LOG_FILE
        exit 1
    else
        echo -e " $2 is .. $R FAILURE $N " | tee -a $LOG_FILE
    fi
    
}

dnf module disable nodejs -y 
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y 
VALIDATE $? "enabling nodejs:20 version"

dnf install nodejs -y 
VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating roboshop user instead of system user"
else
    echo -e  "$G system user already added $Y .. nothing do $N " 
fi

