# Statefull-Firewall-using-IP-tables-

video at : https://www.youtube.com/watch?v=ZILiOCLN0iY&t=6s

This project consists of two script Shell script and a python script.
Shell script is used to build the IP tables.
Python script is used for executing the shell script.
Python script continously runs on the background and keeps a check on the maximum number of connections by any particular user.
Using the kernel.log file python script if detects the number of connections by a particular user greater than a fixed number,
The python script in this case appends a new rule and blocks that particular IP address.
