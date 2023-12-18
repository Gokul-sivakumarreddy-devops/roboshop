#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

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

dnf module disable nodejs -y
VALIDATE $? "Old nodejs disabled" 

dnf module enable nodejs:18 -y
VALIDATE $? "Enabling nodejs" 

dnf install nodejs -y
VALIDATE $? "Installing nodejs" 

useradd roboshop
VALIDATE $? "Creating Roboshop User"

mkdir /app
VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE
VALIDATE $? "Downloading Catalogue Application"

cd /app

unzip /tmp/cart.zip
VALIDATE $? "Unzipping Catalogue application"

npm install 
VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop/5.1-cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying Catalogue service file"

systemctl daemon-reload
VALIDATE $? "Loading the service"

systemctl enable cart
VALIDATE $? "Enabling Cart service"

systemctl start cart
VALIDATE $? "Starting cart service"