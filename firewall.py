import os
import re
import time
from sys import argv

while(1):
	#if argv[1]=="start" or "":
		iplist = dict()
		file = open("/var/log/kern.log",'r+')
		data = file.readlines()

		for line in (data):

			newline = line.split(" ")
			if newline[8] == "IPTABLE_LOGGED":
			    newip = newline[12]
			    if newip not in iplist:
				iplist[newline[12]] = 1
			    else:
				iplist[newline[12]] += 1	
		for num in iplist.values():
			if num>6:

				string = "iptables -I INPUT -s %s -j DROP" % newline[12][4:]
		#print string
				os.system(string)
				print "Blocked:",newline[12]
		time.sleep(5000)

#elif argv[1] == "stop" or "STOP":
#	os.system("iptables --flush")



