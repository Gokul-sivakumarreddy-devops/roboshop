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

dnf install nginx -y
VALIDATE $? "Installing Nginx"

systemctl enable nginx
VALIDATE $? "Enabling Nginx"

systemctl start nginx
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removed default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "Downloaded web appliction"

cd /usr/share/nginx/html
VALIDATE $? "Moving nginx/html directory"

unzip /tmp/web.zip
VALIDATE $? "Unzipping web"

cp /home/centos/roboshop/6.1-roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "Copying Robodhop reverse proxy config"

systemctl restart nginx 
VALIDATE $? "Restarting nginx"

