#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.practiceazure.com
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

id roboshop
if [$? -ne 0 ]
then
  useradd roboshop &>>$LOGFILE
  VALIDATE $? "Creating Roboshop User"
else
   echo -e "Roboshop user already exists $Y SKIPPING $N"
fi   

mkdir -p /app &>>$LOGFILE     # -p  it will not create if already existing
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "CDownloading Catalogue Application"

cd /app
unzip -o /tmp/catalogue.zip &>>$LOGFILE   # -o  overwrite files WITHOUT prompting
VALIDATE $? "Unzipping Catalogue application"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop/2.1-catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying Catalogue service file"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Loading the service"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "Enabling Catalogue service"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Starting Catalogue service"

cp /home/centos/roboshop/2.2-mongo.repo /etc/yum.repos.d
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "Installing MongoDb Client" &>>$LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>>$LOGFILE
VALIDATE $? "Loading Catalogue data into MongoDB"





