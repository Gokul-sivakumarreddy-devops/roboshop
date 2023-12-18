!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script starting executing at $TIMESTAMP" &>>$LOGFILE

VALIDATE(){
if [ $1 -ne 0 ]
 then
    echo -e "$2...$R FAILED $N"
    exit 1
 else
    echo -e "$2...$G SUCCESS $N"
  fi 
  }

if [ $ID -ne 0 ]
 then 
    echo -e "$R ERROR : user do not have root access $N"
    exit 1
 else
     echo -e "$G you are a root user $N"

fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Old nodejs disabled" 

dnf module enable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs" 

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs" 

useradd roboshop &>>$LOGFILE
VALIDATE $? "Creating Roboshop User"

mkdir /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE
VALIDATE $? "Downloading Catalogue Application"

cd /app

unzip /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "Unzipping Catalogue application"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop/5.1-cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying Catalogue service file"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Loading the service"

systemctl enable cart &>>$LOGFILE
VALIDATE $? "Enabling Cart service"

systemctl start cart &>>$LOGFILE
VALIDATE $? "Starting cart service"