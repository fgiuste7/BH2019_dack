# Brainhack 2019 Track 1
Team Members: Felipe Giuste, Muriah Wheelock, Katarzyna Kazimierczak

Please create EC2 instance with the following parameters:
Zone: US East (N. Virginia)
AMI (with all necessary scripts): 'BH2019_Final'
Instance type: m5.8xlarge (CPU:32, Mem:128, EBS only)

Subject Allocation: SEE "Subject Allocation Instructions.txt" for details
7 subjects in 7 instances
6 subjects in 1 instance
=55 subjects total 
=8 instances total

Instructions: ssh within each EC2 instance
Step 1: 
	Copy Subjects to instance (instructions: "Subject Allocation Instructions.txt")
Step 2: 
	cd /home/ubuntu/data 
Step 3:
	bash runALL.sh

