!/bin/bash

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

dnf module disable nodejs -y
VALIDATE $? "Old nodejs disabled" &>>$LOGFILE

dnf module enable nodejs:18 -y
VALIDATE $? "Enabling nodejs" &>>$LOGFILE

dnf install nodejs -y
VALIDATE $? "Installing nodejs" &>>$LOGFILE

useradd roboshop
VALIDATE $? "Creating Roboshop User" &>>$LOGFILE

mkdir /app
VALIDATE $? "Creating app directory" &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "CDownloading Catalogue Application" &>>$LOGFILE

cd /app
unzip /tmp/catalogue.zip

VALIDATE $? "Unzipping Catalogue application" &>>$LOGFILE

npm install 
VALIDATE $? "Installing dependencies" &>>$LOGFILE

cp /home/centos/Roboshop-shell/2.1-catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying Catalogue service file"

systemctl daemon-reload
VALIDATE $? "Loading the service" &>>$LOGFILE

systemctl enable catalogue
VALIDATE $? "Enabling Catalogue service" &>>$LOGFILE

systemctl start catalogue
VALIDATE $? "Starting Catalogue service" &>>$LOGFILE

cp /home/centos/Roboshop-shell/2.2-mongo.repo /etc/yum.repos.d
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org-shell -y
VALIDATE $? "Installing MongoDb Client" &>>$LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "Loading Schema" &>>$LOGFILE





