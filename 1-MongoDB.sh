#!/bin/bash

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

  cp 1.1-mongo.repo /etc/yum.repos.d &>>$LOGFILE
  VALIDATE $? "Copied MongoDB Repo"

  dnf install mongodb-org -y &>>$LOGFILE
  VALIDATE $? "Installing MongoDB"
  systemctl enable mongod
  systemctl start mongod
  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGFILE
  VALIDATE $? "Remote access to MongoDB"
  systemctl restart mongod &>>$LOGFILE
  VALIDATE $? "MongoDB Restarted"