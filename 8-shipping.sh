#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"



echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end


dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing Maven"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir /app
VALIDATE $? "Creating app directory" &>$LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
VALIDATE $? "Downloading shipping Application" &>$LOGFILE

cd /app

unzip -o /tmp/shipping.zip
VALIDATE $? "Unzipping Shipping Application" &>$LOGFILE

mvn clean package
VALIDATE $? "Creating Package" &>$LOGFILE

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Renaming Application" &>$LOGFILE

cp /home/centos/roboshop/8.1-shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying Shipping Application" &>$LOGFILE

systemctl daemon-reload
VALIDATE $? "Loading the service" &>$LOGFILE

systemctl enable shipping
VALIDATE $? "Enabing the service" &>$LOGFILE

systemctl start shipping
VALIDATE $? "Starting the service" &>$LOGFILE

dnf install mysql -y
VALIDATE $? "Installing MySQL service" &>$LOGFILE

mysql -h mysql.practiceazure.com -uroot -pRoboShop@1 < /app/schema/shipping.sql 
VALIDATE $? "Loading Shipping data" &>$LOGFILE

systemctl restart shipping
VALIDATE $? "Restarting the service" &>$LOGFILE

