OMSCS/OMSCY CS-6250

SDN Firewall with POX Project Description

Spring 2026

This project involves the introduction of Software Defined Networking using the mininet network simulator and OpenFlow with the POX OpenFlow Controller.

Table of Contents

Section

Page

Project Introduction

2

Part 0: Project References

2

Part 1: Files Reference

2

Part 2: Mininet Overview

3

Part 3: Wireshark Demonstration

3

Part 4: Firewall Configuration Details and Coding Dictionary Items

5

Part 5: Firewall Implementation Code

7

Part 6: Firewall Configuration Requirements

8

Firewall Rules for Spring 2026:

8

Part 7: What to Turn In and Grading Rubric

9

Part 8: What Can and Cannot Share

9

Part 9: Troubleshooting Tips

9

Part 10: Youtube Videos

10

Appendix A: Review of Mininet

10

Appendix B: Testing Methodologies

11

Part A: How to Test Manually

11

Part B: Automated Testing Suite

13

How to test alternate cases:

13

How to test normal cases:

14

Appendix C: POX Excerpt

14

Flow Modification Object

14

Match Structure

14

OpenFlow Actions

16

Example: Sending a FlowMod Object

16

Project Introduction

This project is an introduction to Software Defined Networking using Mininet (network simulator) and a Python-based OpenFlow Controller named POX to create a relatively simple configurable firewall, although it can be extended to provide complex solutions.

For this project, there are several phases:

If you did complete the Simulating Networks optional project, you may want to review the Mininet Tutorial located in Appendix A. Mininet simulates a network topology that you will use in building your firewall rules.

Wireshark - In this phase, you will use the Wireshark (tshark) network packet capture utility to capture a subset of network traffic. The purpose of this phase is to introduce this powerful network tool and to demonstrate the different aspects of the packet headers that you will use in your firewall implementation and the configuration ruleset that you will use. You will need to submit the simple packet capture that you generate as a part of the submission.

POX Firewall Implementation - In this phase, you will build the firewall implementation that will ingest a firewall configuration and create the POX OpenFlow Flow Modification object, traffic matching, priorities, and an action item based on the configuration. You can code this implementation and then subsequently test using the alternate testing platform without needing to code your configuration first.

Firewall Configuration - In this phase, you will create a firewall configuration that will implement a simple firewall. You will be able to test this with your implementation from phase 3 using a provided testing suite.

You will NOT be able to submit this project to Gradescope in the Spring 2026 semester. You will submit this to Canvas in a ZIP file. You can test your submission with the included test-suites and any student-developed test suites that may be made available.

This project is released on March 9, 2026 and will be due at 23:59 AOE (Anywhere-On-Earth) on March 22, 2026. There is a 20 hour late submission period with a penalty of 5% of the grade per hour on March 23, 2026.

Part 0: Project References

You will find the following resources useful in completing this project. It is recommended that you review these resources before starting the project.

IP Header Format - https://erg.abdn.ac.uk/users/gorry/course/inet-pages/ip-packet.html

TCP Packet Header Format - https://en.wikipedia.org/wiki/Transmission_Control_Protocol

UDP Packet Header Format - https://en.wikipedia.org/wiki/User_Datagram_Protocol

The ICMP Protocol - https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol

IP Protocols - https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers

TCP and UDP Service and Port References - https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers

Wireshark - https://www.wireshark.org/docs/wsug_html/

CIDR Calculator - https://account.arin.net/public/cidrCalculator

CIDR - https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing

Part 1: Files Reference

The files for this project are available for download on Canvas. You will find a ZIP file named SDNFirewall-Spring2026.zip file. Please download this file from the VM or transfer the file to the Virtual machine. Suggested location is the home directory for the mininet user. Move the file to the home directory and run the following command from the terminal window:

unzip SDNFirewall-Spring2026.zip


If you get a notice that unzip cannot be found, run the following: sudo apt install unzip

The following table indicates the purposes of files that you should NOT modify in the SDNFirewall directory.

Filename

Purpose

cleanup.sh

Use this file to cleanup POX and zombie Python and POX process after each run of POX and/or the test-suite. Call using ./cleanup.sh

sdn-topology.py

This file creates the Mininet topology. You will find the IP and MAC addresses for the networking topology used for the firewall.

ws-topology.py

This file creates the Mininet topology used for the Wireshark Tutorial. It does not start the POX Controller.

setup-firewall.py

This is the instructor provided setup that creates the POX Openflow Controller and will read in your configuration rules and make them available as a list of a python dictionary. DO NOT MODIFY THIS FILE.

start-firewall.sh

This is the shell script that starts the firewall. It copies your firewall implementation and configuration to a directory in the ~/pox directory so the firewall can run. PLEASE DO NOT RUN THIS WITH SUDO OR AS ROOT!

start-topology.sh

This is the shell script that starts the Mininet Topology (sdn-topology.sh). Start with ./start-topology.sh

test-client.py

This is a script that you would run to simulate a client in manual testing.

test-server.py

This is a script that you would run to simulate a server in manual testing

The following table indicates the files that you will edit as a part of this project and what you will ZIP up for your submittal to Canvas before the project deadline.

Filename

Purpose

configure.pol

This file is a comma-delimited file that will contain your configuration file for the firewall to satisfy the requirements specified in this project description.

sdn-firewall.py

This file will contain your python implementation code.

packetcapture.pcap

This is the file that you create as a part of the Wireshark demonstration.

comments.txt

OPTIONAL - Submit this to provide your comments to the instruction team about this project. You will need to create this file if you want to provide it.

In the folder, you will also find a test-suite folder that contains two test-suites - one to test your code implementation and one to test your code implementation + your firewall configuration.

Part 2: Mininet Overview

If you did not complete the Simulating Networks Optional Project, you may want to review the "Mininet Review" section in Appendix A to learn about the different aspects of how a mininet network is setup, including how to configure the physical topology and assignment of addresses to hosts and switches.

Part 3: Wireshark Demonstration

Wireshark is a network packet capture program that will allow you to capture a stream of network packets and examine them. Wireshark is used extensively to troubleshoot computer networks and in the field of information security. We will be using Wireshark to examine the IP and TCP/UDP packet headers to learn how to use this information to match traffic that will be affected by the firewall we are constructing.

tshark is a command line version of Wireshark that we will be using to capture the packets between mininet hosts and we will use Wireshark for the GUI to examine these packets. However, you will be allowed to use the Wireshark GUI if you would like in doing the packet capture.

Please watch the Wireshark Tutorial Youtube Video if you would like to follow along in time for a live packet capture.

Open up a Terminal/Console Window and change directory to the SDNFirewall directory.

The first action is to start up the Mininet topology used for the Wireshark capture exercise. This topology matches the topology that you will be using when creating and testing your firewall. To start this topology, run the following command:

sudo python ws-topology.py


This will startup a Mininet session with all hosts created. If you use sdn-topology.py, you will get a controller error. Press Ctrl-C, run ./cleanup.sh and then retry this step with the correct topology name.

Using the mininet console (i.e., mininet> prompt), start up an xterm window for hosts us1 and host us2.

us1 xterm &
us2 xterm &


The window that opens first will be us1 and the second us2. You may change the prompt to help track the hosts, which will be important if you do manual testing of your firewall.

In this step, we want to start capturing all the traffic that traverses through the ethernet port on host us1. We do this by running tshark (or alternatively, wireshark) as follows from the mininet prompt:

us1 sudo tshark -w /tmp/packetcapture.pcap


This will start tshark and will output a pcap formatted file to packetcapture.pcap to the /tmp directory. Note that this file is created as root, so you will need to change ownership to mininet to use it in future steps:

sudo chown mininet:mininet /tmp/packetcapture.pcap


If you wish to use the Wireshark GUI instead of tshark, you would call us1 sudo wireshark &. You may use this method, but the TA staff will not provide support for any issues that may occur.

YOU WILL SUBMIT THIS FILE AS A PART OF YOUR SUBMITTAL.

Step 5: Now we need to capture some traffic. Do the following tasks in the appropriate xterm window:

In us1 xterm:
ping 10.0.1.2
(hit control C after a few ping requests)

In us2 xterm:
ping 10.0.1.1
(likewise hit control C after a few ping requests)

In us1 xterm:
python test-server.py T 10.0.1.1 80

In us2 xterm:
python test-client.py T 10.0.1.1 80
After the connection completes, in the us1 xterm, press Control-C to kill the server.

In us1 xterm:
python test-server.py U 10.0.1.1 8000

In us2 xterm:
python test-client.py U 10.0.1.1 8000

In us1 xterm:
press Control C to kill the server

In Mininet Terminal:
press Control C to stop tshark

Step 6: At the mininet prompt, type in exit and press enter. Next, do the chown command as described in step 4 above to your packet capture. You may also close the two xterm windows as they are finished. Copy the /tmp/packetcapture.pcap to your project This file is the deliverable for this phase of the project. See the instructions in Step 4 that describe how you will need to change ownership of this file in order to change or move it.

sudo chown mininet:mininet /tmp/packetcapture.pcap
cp /tmp/packetcapture.pcap ~/SDNFirewall


Step 7: At the bash prompt on the main terminal, run:

sudo wireshark


(You may also use a wireshark tool on your host computer if you'd like. If you do this, copy over the packet capture to your host computer)

Go to the File => Open menu item, browse to the /tmp directory and select the pcap file that you saved using tshark.

You will get a GUI that looks like the example packet capture. You will have a numbered list of all the captured packets with brief information consisting of source/destination, IP protocol, and a description of the packet. You can click on an individual packet and will get full details including the Layer 2 and Layer 3 packet headers, TCP/UDP/ICMP parameters for packets using those IP protocols, and the data contained in the packet.

Note the highlighted fields. You will be using the information from these fields to help build your firewall implementation and ruleset. Note the separate header information for TCP. This will also be the case for UDP packets.

Also, examine the three-way handshake that is used for TCP. What do you expect to find for UDP? ICMP?

Example TCP Three-Way Handshake

28 121.802282677 10.0.1.1  10.0.1.2  TCP  74 34404 -> 80 [SYN] Seq=0 Win=42348 Len=0 MSS=1460 SACK_PERM=1 T..
29 121.810800173 10.0.1.2  10.0.1.1  TCP  74 80 -> 34404 [SYN, ACK] Seq=0 Ack=1 Win=43440 Len=0 MSS=1460 SA...
30 121.810889156 10.0.1.1  10.0.1.2  TCP  66 34404 -> 80 [ACK] Seq=1 Ack=1 Win=42496 Len=0 TSval=948059323


Please examine the other packets that were captured to help you familiarize yourself with Wireshark.

Part 4: Firewall Configuration Details and Coding Dictionary Items

This part is a reference to assist you in coding your implementation file and for creating your configuration file.

Your firewall configuration (configure.pol) is a comma delimited file that has the following format:
Rule Num, Action, MACSource, MACDest, IPSource, IPDest, IPProtocol, PortSource, PortDest, Comment/Note

These values will be made available to you for use in your python code as a list of a dictionary object (one list item per line in your configure.pol) as STRINGS.

These items are defined as such:

Item

Description

RuleNum

This is a number or text that you can use to help when you troubleshoot your rules. Most students use a combination of rule number.item number. Do not use this to set priority. You'll see errors reference this with the following text: ValueError: Invalid Action Item for rulenum 1

Action

The only options are "Allow" or "Block". This is validated by the parser in setup-firewall.py. "Allow" will override a "Block" rule

MACSource

Source MAC Address from IP Header. Format is 00:00:00:00:00:00. This is also known as the Hardware ID

MACDest

The destination MAC Address

IPSource

The Source NETWORK address from the IP Header. Format is 10.0.10.10/32 (for a single host) or 10.0.10.10/24 for a network. Note that this field must be a valid NETWORK Address. See CIDR notation for a valid network address.

IPDest

The Destination NETWORK address from the IP Header.

IPProtocol

The IP Protocol from the IP Header. Format is a number (ICMP = 1, for instance)

PortSource

The Source Application Port Number from the TCP/UDP Header. Valid only for TCP/UDP. The IP Protocol for UDP/TCP must be specified if a Port is specified. Single Number. Not used for ICMP

PortDest

The Destination Application Port Number from the UDP/TCP Header. Single number.

Comment/Note

A Note or Comment about the rule.

There are a few particular "rules" about these fields:

An field not being used in a match should specify a - as its entry. A - is valid for any field except Action. Please note that when you build your POX traffic matching, do not pass a - to POX or you will get an error.

The minimum allowable subnet mask is /24. Do not use a /16.

Do not use 0.0.0.0/0 to address the internet as a whole. See statement about -.

MAC vs IP Addresses? Think about what Layer each address is used.

Example Rules (included in the project files):

1,Block,-,-,10.0.0.1/32,10.0.1.0/24,6,-,80, Block 10.0.0.1 host from accessing a web server on the 10.0.1.0/24 network
2,Allow,-,-,10.0.0.1/32,10.0.1.125/32,6,-,80, Allow 10.0.0.1 host to access a web server on 10.0.1.125 overriding rule


What do these rules do?
The first rule basically blocks host hq1 (IP Address 10.0.0.1/32) from accessing a web server on any host on the us network (the subnet 10.0.1.0/24 network). The web server is running on the TCP IP Protocol (6) and uses TCP Port 80.
The second rule overrides the initial rule to allow hq1 (IP Address 10.0.0.1/32) to access a web server running on us5 (IP Address 10.0.1.125/32).

As mentioned earlier, these values are passed back to you via code as a list of python dictionary objects.
"policies" is a python list that contains one entry for each rule line contained in your configure.pol file. Each individual line of the configure.pol file is represented as a dictionary object named "policy". This dictionary has the following keys:

policy['mac-src'] = Source MAC Address (00:00:00:00:00:00) or "-"

policy['mac-dst'] = Destination MAC Address (00:00:00:00:00:00) or "-"

policy['ip-src'] = Source IP Address (10.0.1.1/32 in CIDR notation) or "-"

policy['ip-dst'] = Destination IP Address (10.0.1.1/32) or "-"

policy['ipprotocol'] = IP Protocol (6 for TCP) or "-"

policy['port-src'] = Source Port for TCP/UDP (12000) or "-"

policy['port-dst'] = Destination Port for TCP/UDP (80) or "-"

policy['rulenum'] = Rule Number (1)

policy['comment'] = Comment (Example Rule)

policy['action'] = Allow or Block

Just a reminder that all items passed to you from the policy dictionary are STRINGS. You will need to convert as needed.

Part 5: Firewall Implementation Code

Before starting the project, please update your VM to the latest version pox by running the following four commands:

cd /home/mininet/pox
git pull
git checkout ichthyosaur
chown -R mininet:mininet ~/pox


Using the data from part 4, you will need to edit your sdn-firewall.py file to implement creating a flow modification object, traffic matching, priorities, and an action (if necessary). You will use the "policy" to create traffic matching rules based on a configuration passed to you. This code needs to be generic and should be able to handle all of the header parameters (source/destination MAC, IP, and Application Ports, as well as the IP Protocol). You will be implementing this using the POX API (an excerpted version is available in Appendix C).

Your code may include helper functions, but all such functions need to be in sdn-firewall.py. Please do not add any additional libraries unless they are already installed on the Virtual Machine. Your code itself should be fairly short (roughly between 20~30 lines should be all that is necessary).

By default, this is an open firewall which means no traffic is blocked unless it is blocked with a Block rule. You write Allow rules to override a previously more broad Block rule. These are the only two activities.

Your code should accomplish the following:

Create an OpenFlow Flow Modification object

Create a POX Packet Matching object that will integrate the elements from a single entry in the firewall configuration rule file (which is passed in the policy dictionary) to match the different IP and TCP/UDP headers if there is anything to match (i.e., no "-" should be passed to the match object, nor should None be passed to a match object if a "-" is provided).

Assign a priority to differentiate between Allow and Block

Create a POX Output Action, if needed, to specify what to do with the traffic.

Your code should start by rewriting the rule = None from the sdn-firewall.py file.

Some tips:

If POX matches a particular packet, it pulls it from the stream and does nothing with it unless you do an action to it.

POX traffic priorities are based on the level of exactness. A rule that matches three items has a higher implicit priority than one that matches two. Your Allow/Block rules need to overcome this bias. The suggestion is to use priorities a few thousands apart.

Remember that you may be tested with IP Protocols other than 1, 6, and 17. In addition, remember that "-" is a valid value for IP Protocol.

If Application Source or Destination port is specified, you may assume that you must specify IP Protocols 6 or 17. You will not be tested with an invalid rule.

You may assume that all traffic is IPv4. If you get weird errors about missing prerequisites, you may want to check to see if you are matching IP Type. It is allowable to specify this for all rules, but only certain rules actually require it.

Part 6: Firewall Configuration Requirements

You will need to submit a configure.pol firewall configuration file to create policies that implement the following scenarios. You may implement your rules in any manner that you want, but it is recommended using this step as an opportunity to check your firewall code implementation. The purpose of these rules is to test your firewall and to help determine how traffic flows across the network (source vs destination, protocols, etc).

DO NOT block all traffic by default and only block/allow traffic specified. You will lose many points because the firewall is open by default and only blocks the traffic that is specified. You do not need to remove the two example rules as they do not conflict with any of the tasks below. The rule counts given below are the typical minimum needed to satisfy this rule.

CIDR Primer Video: [可疑链接已删除]

The corporate networks are described as follows:

Headquarters (hosts hq1-hq5) on the 10.0.0.0/24 subnet

US Network (hosts us1-us5) on the 10.0.1.0/24 subnet

India Network (hosts in1-in5) on the 10.0.20.0/24 subnet

China Network (hosts cn1-cn5) on the 10.0.30.0/24 subnet

UK Network (hosts uk1-uk5) on the 10.0.40.0/24 subnet

There are also two additional hosts defined - wo1/wo2 or world1/world2. These are used to test world connections. DO NOT USE THEIR IP OR MAC ADDRESSES IN YOUR RULES OR YOU WILL LOSE POINTS.

You may find the MAC and IP Addresses for these hosts in your sdn-topology.py file.

Firewall Rules for Spring 2026:

Task 1: Host cn4 has a TCP-based worm virus. Block cn4 from initiating network communications to any host on the internet (world) including all of the corporate networks over the TCP Internet Protocol. You need not block ICMP or UDP. (one rule max)

Task 2: Host cn5 has had a security incident and needs to be completely isolated so it has no connectivity (incoming or outgoing) to any other host in the world including the corporate networks. (two rules max)

Task 3: Allow all of the hosts on the Headquarters network to be reachable via an ICMP ping from the world including the OTHER corporate networks. In addition, the other corporate subnets (except HQ and China) should not be pingable from the world. However, to satisfy the first half of this task, you must allow the Headquarters network to be able to ping the US, UK, and India subnets. Can you explain why this must happen? (six rules typically)
The China network is exempted from this rule because any overrides that you may do here will override aspects of Task 1 or Task 2 above (in other words, create no Block or Allow rules that involve the China Network). It is undefined whether or not the US, UK, or IN networks should be able to ping each other, so you may configure your rules as you wish.

Task 4: Do not allow any response back from a TCP web server (http and https) running on host cn3 to any other host on the internet (world). (two rules max) Use the standard application ports for HTTP and HTTPS.

Task 5: (CIDR Notation Rule) The servers located on hosts us3 and us4 run a micro webservice on TCP Port 9520 that processes financial information. Access to this service should be blocked from hosts uk2, uk3, uk4, uk5, in4, in5, us5, and hq5. Please use the minimal CIDR notation that will bracket the subset of hosts for each rule (it should NOT be broader than /28). (four rules typical)

Task 6: A rogue Raspberry Pi has been found on the network that has cloned the Hardware Address (or physical network address) of host us1. Block this device from accessing any other hosts on the internet (world) on the UDP Internet Protocol. (one rule max) Note that when testing this rule, the IP address for host us1 may differ from the published topology. In this case, you want to address the particular hardware network address. Note that this rule indicates that host us1 will be blocked as well as the Pi, which is acceptable)

Task 7: Block the internet (world) from accessing TCP Port 25 on any of the corporate subnets. The behavior of access to TCP Port 25 amongst members of the corporate subnets is undefined and you may handle it as you wish. (five rules max)

Part 7: What to Turn In and Grading Rubric

You need to submit your copy of packetcapture.pcap, sdn-firewall.py and configure.pol from your project directory using the zip command. To recap, zip up the three files using the following command, replacing gtlogin with your GT Login that you use to log into Canvas:

zip gtlogin_sdn.zip packetcapture.pcap configure.pol sdn-firewall.py


The key to properly zipping the project is to NOT zip up the directory. ZIP only the files you are included.

It is not important that the ZIP file contain your name. Also, note that resubmittals will attach a -1 or -2 to the filename which is acceptable. The autograder script will pull the last submission.

You may also include an additional text file if you have comments, criticisms, or suggestions for improvement for this project. If you wish to provide this information, add it to your ZIP file with the name comments.txt. This is completely optional.

IMPORTANT NOTE
Please check your submission after uploading. Many people have uploaded the wrong file to Canvas. Please re-download from Canvas after submission and unzip the files to make sure you have submitted all of the proper files and for the files for the correct project.

For the Fall 2025 Semester, this project is worth a total of 100 points which is distributed in the following fashion:

5 points for submitting a version of sdn-firewall.py that indicates effort was done.

5 points for submitting a version of configure.pol that indicates effort was done.

15 points for submitting a version of packetcapture.pcap that indicates effort was done.

25 points for testing your configure.pol file with a known-good implementation.

25 points for testing your configure.pol with your implementation.

25 points for testing your implementation with an alternate configure.pol and topology.

Note that if you get full credit for your configure.pol and your code implementation, you will automatically get full credit with the known-good implementation.

Part 8: What Can and Cannot Share

Do not share the content of your sdn-firewall.py, configure.pol, or packetcapture.pcap with your fellow students, on Ed Discussions, or elsewhere publicly. You may share any new topologies, testing rulesets, or testing frameworks, as well as packet captures that do not address the requirements of Part 6.

Part 9: Troubleshooting Tips

There is a post on EdStem that references common error conditions and how to resolve them. Please review that post in order to help with any error messages that you may receive while running or coding the project.

Part 10: Youtube Videos

Please check the Main Thread on EdStem for a link to helpful YouTube videos for the different aspects of this project.

Appendix A: Review of Mininet

Mininet is a network simulator that allows you to explore SDN techniques by allowing you to create a network topology including virtual switches, links, hosts/nodes, and controllers. It will also allow you to set the parameters for each of these virtual devices and will allow you to simulate real-world applications on the different hosts/nodes.

The following code sets up a basic Mininet topology like what is used for this project:

#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import CPULimitedHost, RemoteController
from mininet.util import custom
from mininet.link import TCLink
from mininet.cli import CLI

class FirewallTopo(Topo):
    def __init__(self, cpu=.1, bw=10, delay=None, **params):
        super(FirewallTopo,self).__init__()

        # Host in link configuration
        hconfig = {'cpu': cpu}
        lconfig = {'bw': bw, 'delay': delay}

        # Create the firewall switch
        s1 = self.addSwitch('s1')

        hq1 = self.addHost('hq1',ip='10.0.0.1',mac='00:00:00:00:00:1e', **hconfig)
        self.addLink(s1,hq1)


        us1 = self.addHost( 'us1', ip='10.0.1.1', mac='00:00:00:01:00:1e', **hconfig)
        self.addLink(s1,us1)


This code defines the following virtual objects:

Switch s1 – this is a single virtual switch with the label 's1'. In Mininet, you may have as many virtual ports as you need – for Mininet, “ports” are a virtual ethernet jack, not an application port that you would use in building your firewall.

Hosts hq1 and us1 – these are individual virtual hosts that you can access via xterm and other means. You can define the IP Address, MAC/Hardware Addresses, and configuration parameters that can define cpu speed and other parameters using the hconfig dictionary.

Links between s1 and hq1 and s1 and us1 – consider these like an ethernet cable that you would run between a computer and the switch port. You can define individual port numbers on each side (i.e., port on the host and port on the virtual switch), but it is advised to let Mininet automatically wire the network. Like hosts, you can define configuration parameters to set link speed, bandwidth, and latency. REMINDER – PORTS MENTIONED IN MININET TOPOLOGIES ARE WIRING PORTS ON THE VIRTUAL SWITCH, NOT APPLICATION PORT NUMBERS.

Useful Mininet Commands:

Copyright 2026 Page 10 of 16 This content is solely to be used for current CS 6250 Students Georgia Institute of Technology Any public posting of this material contained within All Rights Reserved is strictly forbidden by the Georgia Tech Honor Code

OMSCS/OMSCY CS-6250 SDN Firewall with POX Project Description Spring 2026

For this project, you can start Mininet and load the firewall topology by running the ./start-topology.sh from the project directory. You can quit Mininet by typing in the exit command.

After you are done running Mininet, it is recommended that you cleanup Mininet. There are two ways of doing this. The first is to run the sudo mn -c command from the terminal and the second is to use the ./cleanup.sh script provided in the project directory. Do this after every run to minimize any problems that might hang or crash Mininet.

You can use the xterm command to start an xterm window for one of the virtual hosts. This command is run from the mininet> prompt. For example, you can type in us1 xterm & to open a xterm window for the virtual host us1. The & causes the window to open and run in the background. In this project, you will run the test-*-client.py and test-*-server.py in each host to test connectivity.

The pingall command that is run from the mininet> prompt will cause all hosts to ping all other hosts. Note that this may take a long time. To run a ping between two hosts, you can specify host1 ping host2 (for example, us1 ping hq1 which will show the result of host us1 pinging hq1).

The help command will show all Mininet commands and dump will show information about all hosts in the topology.

Appendix B: Testing Methodologies

Part A: How to Test Manually

(There is a Youtube Video posted that depicts how to manually test)

This section is included for completeness. It is currently better to create your implementation and then test using the Alternate Test Suite.

Startup Procedure:

Step 1: Open two terminal windows or tabs on the VM and change to the SDNFirewall directory.

Step 2: In the first terminal window, type in: ./start-firewall.sh configure.pol

If you get the following error, run chmod +x start-firewall.sh and chmod +x start-topology.sh

mininet@mininet:~/SDNFirewall/student-test-suite/extra$ ./start-firewall.sh configure.pol
bash: ./start-firewall.sh: Permission denied


This should start up POX, read in your rules, and start up an OpenFlow Controller. You will see something like this in your terminal window:

mininet@mininet:~/SDNFirewall$ ./start-firewall.sh configure.pol
~/pox ~/SDNFirewall
POX 0.7.0 (gar) / Copyright 2011-2020 James McCauley, et al.
Starting POX Instance
Starting date and time : 2021-02-08 01:09:59

WARNING:version:Support for Python 3 is experimental.
INFO:core:POX 0.7.0 (gar) is up.
INFO:openflow.of_01:[00-00-00-00-00-01 1] connected
List of Policy Objects imported from configure.pol:

[{'rulenum': '1', 'action': 'Block', 'mac-src': '-', 'mac-dst': '-', 'ip-src': '10.0.0.1/32', 'ip-dst': '10.0.1.0/24', 'ipprotocol': '6', 'port-src': '-', 'port-dst': '80', 'comment': 'Block 10.0.0.1 from accessing a web server on the 10.0.1.0/32 network'}, {'rulenum': '2', 'action': 'Allow', 'mac-src': '-', 'mac-dst': '-', 'ip-src': '10.0.0.1/32', 'ip-dst': '10.0.1.125/32', 'ipprotocol': '6', 'port-src': '-', 'port-dst': '80', 'comment': 'Allow 10.0.0.1 to access a web server on 10.0.1.125 overriding previous rule'}]
Added Rule 1 : Block 10.0.0.1 from accessing a web server on the 10.0.1.0/32 network
Added Rule 2 : Allow 10.0.0.1 to access a web server on 10.0.1.125 overriding previous rule


TA Note: Note that you will not see the "List of Policy Objects imported from configure.pol" and the "Added Rule" lines until after you complete Step 3 below.

OMSCS/OMSCY CS-6250 SDN Firewall with POX Project Description Spring 2026

Step 3: In the second terminal window, type in: ./start-topology.sh

This should start up mininet and load the topology. You should see the following:

mininet@mininet:~/SDNFirewall$ ./start-topology.sh
Starting Mininet Topology...
If you see a Unable to Contact Remote Controller, you have an error in your code...
Remember that you always use the Server IP Address when calling test scripts...
mininet> 


This will start the firewall and set the topology. You do not need to repeat Steps 1-3 unless you are done testing, need to restart the firewall, or need to restart mininet. When you are done with testing all of the rules you intend to use, type in "quit" in the mininet window, close all of the extraneous xterm windows generated, and run the mininet cleanup script ./cleanup.sh

How to test connectivity between two hosts:

Step 1: To test the rule shown above, we want to use host us1 as server/destination and host hq1 as the client. The rule we are testing involves the hq1 host attempting to connect to the web server port (TCP Port 80) on host us1. At the mininet prompt, type in the following two commands on two different lines:

hq1 xterm &
us1 xterm &

Two windows should have popped up. You can always identify which xterm is which by running the command: ip address from the bash shell. This will give you the IP address for the xterm window, which will then let you discover which xterm window belongs to which host.

Step 2: In the xterm window for us1 (which is the destination host of the rule - remember that the destination is always the server), type in the following command:

python test-server.py T 10.0.1.1 80

This sets up the test server for us1 that will be listening on TCP port 80. The IP Address specified is always the IP address of the machine you are running it on. If you attempt to start the test-server on a machine that does not have the IP address that is specified in the command, you will get the following error: OSError: [Errno 99] Cannot assign requested address.

Step 6: In the xterm window for hq1 (which is the source host of the rule - remember that the source is always the client), type in the following command:

python test-client.py T 10.0.1.1 80

This will start up a client that will connect to the TCP Port 80 on the server 10.0.1.1 (destination IP address) and will send a message string to the server. However, if the firewall is set to block this connection, you will never see the message pass on either of the client or the server.

Examples of Connection Status:

OMSCS/OMSCY CS-6250 SDN Firewall with POX Project Description Spring 2026

The two windows below depict a successful un-blocked connection between the client and the server.

root@mininet:/home/mininet/SDNFirewall# python test-client.py T 10.0.1.125 80
connecting to 10.0.1.125 port 80
Sending "This is the message.  It will be repeated."
Received "This is the mess"
Received "age.  It will be"
Received " repeated."
Message sent successfully
Closing socket
root@mininet:/home/mininet/SDNFirewall#


root@mininet:/home/mininet/SDNFirewall# python test-server.py T 10.0.1.125 80
Starting Server on 10.0.1.125 port 80
Waiting for a Connection
Connection from  ('10.0.0.1', 59616)
Received "This is the mess"
Sending data back to the client
Received "age.  It will be"
Sending data back to the client
Received " repeated."
Sending data back to the client
Received ""
No more data from ('10.0.0.1', 59616)
Finished
Waiting for a Connection


A blocked connection will look like this (note that the client may take a while to timeout):

root@mininet:/home/mininet/SDNFirewall# python test-client.py T 10.0.1.1 80
connecting to 10.0.1.1 port 80



root@mininet:/home/mininet/SDNFirewall# python test-server.py T 10.0.1.1 80
Starting Server on 10.0.1.1 port 80
Waiting for a Connection



You may hit Control C to kill both the server and the client.

A timed out connection is shown below. The difference between a timed-out connection on how the connection was blocked or if it was blocked on a different side of the connection.

root@mininet:/home/mininet/SDNFirewall# python test-client.py T 10.0.1.1 80
connecting to 10.0.1.1 port 80
Traceback (most recent call last):
  File "test-client.py", line 29, in <module>
    sock.connect(server_address)
TimeoutError: [Errno 110] Connection timed out
root@mininet:/home/mininet/SDNFirewall#


If you get an error that says "No route to destination", you have blocked the routing protocol. Ensure that you do not have a Unspecified Prerequisite Error

Repeat this process for every rule you wish to test. If you feel that after some initial testing that your implementation and ruleset is good, you may then proceed to using the automated test suite.

Part B: Automated Testing Suite

The automated Test Suit was developed by a student in Summer 2021 (htian66) and has been updated to match the current version of this project. There are two test-suites to use. The "alt" will test your firewall code implementation with a known good configuration file. The second, or "standard" test-suite will test your firewall code implementation with your configuration file.

How to test alternate cases:

Change to the <projectroot>/test-scripts/alt directory

Copy your sdn-firewall.py file into this folder. DO NOT COPY YOUR CONFIGURE.POL HERE!!

Run ./start-firewall.sh (you do not need to specify your configure.pol file

OMSCS/OMSCY CS-6250 SDN Firewall with POX Project Description Spring 2026

Open a new window, run sudo python test_all.py in the test-suite/alt folder.

Total passed cases are calculated. Wrong cases will be displayed. For example, `2: us1 -> hq1 with U at 53, should be True, current False` means the connection from client us1 to host hq1 using UDP at hq1 53 port is failed, which should be successful. The first number is the index (0-based) of testcases.

True indicates that a connection was made or was expected. False indicates the opposite condition.

How to test normal cases:

Change to the <projectroot>/test-scripts/standard directory

Copy your `sdn-firewall.py` and `configure.pol` into this directory.

Run ./start-firewall.sh configure.pol as usual.

Open a new window, run sudo python test_all.py.

Total passed cases are calculated. Wrong cases will be displayed. For example, `2: us1 -> hq1 with U at 53, should be True, current False` means the connection from client us1 to host hq1 using UDP at hq1 53 port is failed, which should be successful. The first number is the index (0-based) of testcases.

True indicates that a connection was made or was expected. False indicates the opposite condition.

Appendix C: POX Excerpt

This section contains a highly modified excerpt from the POX Manual (modified to remove extraneous features not used in this project and to provide clarifications). You should not need to use any other POX objects for this project. TA Comments are highlighted. Everything on these pages is important to complete the project.

Excerpted and modified from: https://noxrepo.github.io/pox-doc/html/

Flow Modification Object

The main object used for this project is a "Flow Modification" object. This adds a rule to the OpenFlow controller that will affect a modification to the traffic flow based on priority, packet characteristic matching, and an action that will be done to the traffic that is matched. IF AN OBJECT is matched, it is pulled from the network stream and will only be forwarded, modified, or redirected if you do an action. If you do not specify an action and the packet is matched, the packet will basically be dropped.

The following class descriptor describes the contents of a flow modification object. You need to define the match, priority, and actions (if necessary) for the object.

class ofp_flow_mod (ofp_header):
  def __init__ (self, **kw):
    ofp_header.__init__(self)
    self.header_type = OFPT_FLOW_MOD
    self.match = ofp_match()
    self.priority = OFP_DEFAULT_PRIORITY
    self.actions = []


Match Structure

OpenFlow defines a match structure – ofp_match – which enables you to define a set of headers for packets to match against.

The match structure is defined in pox/OpenFlow/libOpenFlow_01.py in class ofp_match. Its attributes are derived from the members listed in the OpenFlow specification, so refer to that for more information, though they are summarized in the table below.

You should create a match object and attach it to the flow modification object.

OMSCS/OMSCY CS-6250 SDN Firewall with POX Project Description Spring 2026

Attribute

Meaning

dl_src

Ethernet/MAC source address (Type of EthAddr)

dl_dst

Ethernet/MAC destination address (Type of EthAddr)

dl_type

Ethertype / length (e.g. 0x0800 = IPv4) (Type of Integer)

nw_proto

IP protocol (e.g., 6 = TCP) or lower 8 bits of ARP opcode (Type of integer)

nw_src

IP source NETWORK address (Type of String)

nw_dst

IP destination NETWORK address (Type of String)

tp_src

TCP/UDP source application port (Type of Integer)

tp_dst

TCP/UDP destination application port (Type of Integer)

Attributes may be specified either on a match object or during its initialization. That is, the following are equivalent:

matchobj = of.ofp_match(tp_src = 5, dl_type = 0x800,dl_dst = EthAddr("01:02:03:04:05:06"))
# .. or ..
matchobj = of.ofp_match()
matchobj.tp_src = 5
matchobj.dl_type = 0x800
matchobj.dl_dst = EthAddr("01:02:03:04:05:06")


<div style="border: 1px solid black; padding: 10px;">
IMPORTANT NOTE ABOUT IP ADDRESSES

TA Note: What isn't very clear by this documentation is that nw_* is expecting a network address. If you are calling out an IP Address like 10.0.1.1/32, it is an acceptable response to nw_*. However, if you are calling out a subnet like 10.0.1.0/24, the IP address portion of the response MUST BE the Network Address.

From Wikipedia: IP addresses are described as consisting of two groups of bits in the address: the most significant bits are the network prefix, which identifies a whole network or subnet, and the least significant set forms the host identifier, which specifies a particular interface of a host on that network. This division is used as the basis of traffic routing between IP networks and for address allocation policies. (https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)

Thus for a /24 network, the first 24 bits of the address comprises the network address. Thus, it would be 10.0.1.0. For a /25 network, there would be two networks in the 10.0.1.x space – a 10.0.1.0/25 and a 10.0.1.128/25.

Your implementation code does NOT need to convert the given IP Address into a network – you can assume that any given address in a possible configuration file must be valid. However, your configure.pol file MUST be using the proper form if you are using a CIDR notation other than /32. Why would you do this? To reduce the number of rules needed.

</div>

Note that some fields have prerequisites. Basically this means that you can't specify higher-layer fields without specifying the corresponding lower-layer fields also. For example, you can not create a match on a TCP port without also specifying that you wish to match TCP traffic. And in order to match TCP traffic, you must specify that you wish to match IP traffic. Thus, a match with only tp_dst=80, for example, is invalid. You must also specify nw_proto=6 (TCP), and dl_type=0x800 (IPv4). If you violate this, you should get the warning message 'Fields ignored due to unspecified prerequisites'.

This question also presents itself as "What does the Fields ignored due to unspecified prerequisites warning mean?"

Basically this means that you specified some higher-layer field without specifying the corresponding lower-layer fields also. For example, you may have tried to create a match in which you specified only tp_dst=80, intending to capture HTTP traffic. You can't do this. To match TCP port 80, you must also specify that you intend to match TCP (nw_proto=6). And to match on the TCP protocol, you must also match on IPV4 type (dl_type=0x800).

OMSCS/OMSCY CS-6250 SDN Firewall with POX Project Description Spring 2026

OpenFlow Actions

The final aspect needed to fully implement a flow modification object is the action. With this, you specify what you want done to a port. This can include forwarding, dropping, duplicating and redirecting, or modify the header parameters. For the purposes of this project, we are only dealing with forwarding of match traffic to its destination. But please note that for a Software Defined Network system, you can do all sorts of actions including round robin server, DDOS blocking, and many other possible options.

Forward packets out of a physical or virtual port. Physical ports are referenced to by their integral value, while virtual ports have symbolic names. Physical ports should have port numbers less than 0xFF00.

Structure definition:

class ofp_action_output (object):
  def __init__ (self, **kw):
    self.port = None # Purposely bad -- require specification


port (int) the output port for this packet. This is a bit misleading because it can confuse you with the application "port" for TCP/UDP. For openflow, this port represents the physical swith port that the host is plugged into. However, you do NOT know which physical port on which switch a host is connected to. Thus, you will need to use one of the virtual ports to define what you want to happen:

of.OFPP_IN_PORT – This action will send the port back to the sender (i.e., the port it came into the network on)

of.OFPP_NORMAL - Process the packet and handle via a normal L2/L3 legacy switch configuration (i.e., send traffic to its destination without modification) – See https://study-ccna.com/layer-3-switch/ for information on how normal L2/L3 legacy switches work.

of.OFPP_FLOOD – This action will cause the traffic to be sent out to all ports except the source (IN_PORT) and any ports that have flooding turned off. This is very chatty and can be used to do network based attacks (see UDP Amplifications). This should be avoided.

of.OFPP_ALL - output all OpenFlow ports except the source (IN_PORT). This is the same as FLOOD but it includes ports that have had flood turned off.

of.OFPP_CONTROLLER – This action sends the packet to the switch controller. What happens with the port depends on the state of the switch controller. Thus it may work, but also may not work, based on the current state of the switch.

Think carefully about the definitions given above for output actions. Remember that if you match a packet, no action (i.e., packet will be dropped) will be done unless you set an output action as the packet is pulled from the stream until it is resolved.

Example: Sending a FlowMod Object

The following example describes how to create a flow modification object including matching a destination IP Address, IP Type, and Destination IP Port, and setting an action that would redirect the matching packet out to physical switch port number 4 (note that you generally DO NO KNOW what physical switch port to use.

rule = of.ofp_flow_mod()
rule.match = of.ofp_match()
rule.match.dl_type = 0x800
rule.match.nw_dst = "192.168.101.101/32"
rule.match.nw_proto = 6
rule.match.tp_dst = 80
rule.priority = 42
rule.actions.append(of.ofp_action_output(port = of.OFPP_????))
