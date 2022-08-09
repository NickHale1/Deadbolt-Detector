# Deadbolt-Detector
__Project Name:__ The Costello Deadbolt detector 

__Team Name:__ Peterborough Programmers 

__Team Members:__ 

- Brendan Neary (nearybatwit) – _Database Security, Python_ 

- Nick Hale (NickHale1) – _App development, Database implementation_ 

__Team GitHub repo link:__ https://github.com/NickHale1/Deadbolt-Detector 



## Introduction 

The Costello Deadbolt Detector is an application designed to improve daily security for the user. The patent is a non-intrusive home security device that delivers optimal security functionality by working with your IOS device to detect if the door has been locked. The idea is a door sensor that would be linked to the location of the phone. Once the user leaves the apartments designated geolocation, a sensor will determine if the door is locked or unlocked; if left unlocked it will notify the user phone after a certain interval of time. This will also be sensitive to multiple users in a network. If one user leaves the location and leaves the door unlocked, but there is still another user (roommate) in the designated location, the application will not keep notifying the travelling persons. 




## Functions/Features 

- Emergency locking of door (Brendan) 

- Account Management / Login Authentication (Nick) 

- Notification if door is unlocked for too long or if you leave the area while unlocked (Nick) 

- Request current status of lock (Brendan) 

## Technologies and Tools 

### Technologies 

- XCode 

- Best IDE for native IOS development. We have access to an M1 MacBook which will allow us to develop for the Apple platform 

- Raspbian/Raspberry Pi 4 

- Raspberry Pi will be used in tandem with python to measure the distance between the sensors and the deadbolt to tell if the door is locked or not 

- Proximity Sensor 

- Proximity sensor will be used in tandem with the Raspberry Pi to measure the distance of the deadbolt and ping the phone if left unlocked 



### Tools 

- GitHub – Version control  

- Google Drawings – designing UI 

- GitHub issues – Task tracking 

- VNC Viewer - Connect to Pi remotely
