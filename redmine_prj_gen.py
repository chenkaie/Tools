#!/usr/local/bin/python
# Redmine Create new project :
#	 http://rd1-1/redmine/projects/obm-projects/wiki/Product_management_process
# Python tutorial
#    http://caterpillar.onlyfun.net/Gossip/Python/index.html

import sys, os

sys.path.append(os.getcwd()) # Append "redmine.py" under the same folder
import redmine

import termios
TERMIOS = termios
def getkey():
	fd = sys.stdin.fileno()
	old = termios.tcgetattr(fd)
	new = termios.tcgetattr(fd)
	new[3] = new[3] & ~TERMIOS.ICANON & ~TERMIOS.ECHO
	new[6][TERMIOS.VMIN] = 1
	new[6][TERMIOS.VTIME] = 0
	termios.tcsetattr(fd, TERMIOS.TCSANOW, new)
	c = None
	try:
		c = os.read(fd, 1)
	finally:
		termios.tcsetattr(fd, TERMIOS.TCSAFLUSH, old)
	return c

'''
 Project Introduction (Modify this part by your need)
'''

PRJ_MODELNAME = "IP5978-DLNK"
PRJ_DESC = PRJ_MODELNAME + " project, PM: xxx, PL: xxx, FW: xxx, DQA: xxx, HW: xxx, ME: xxx"
PRJ_HOMEPAGE = "http://rd1-1/rd1wiki/index.php/Team:Division:Project:ProjectLeader:" + PRJ_MODELNAME.split('-')[0]
PRJ_IDENTIFIER = PRJ_MODELNAME.lower() 

print "+----------------------------------------------------------------------------------------+"
print "[Redmine VIVOTEK Project Robot] "

print "> Project Info: " + "\n    Model Name  = " + PRJ_MODELNAME  \
						 + "\n    Description = " + PRJ_DESC       \
						 + "\n    Identifier  = " + PRJ_IDENTIFIER \
						 + "\n    Homepage    = " + PRJ_HOMEPAGE


print "> Subproject Info:" 
print "    Name = " + PRJ_MODELNAME + " FW development"    + ", Identifier = " +  PRJ_IDENTIFIER + "-fw"
print "    Name = " + PRJ_MODELNAME + " HW development"    + ", Identifier = " +  PRJ_IDENTIFIER + "-hw"
print "    Name = " + PRJ_MODELNAME + " ME development"    + ", Identifier = " +  PRJ_IDENTIFIER + "-me"
print "    Name = " + PRJ_MODELNAME + " IMAGE development" + ", Identifier = " +  PRJ_IDENTIFIER + "-image"

print "+----------------------------------------------------------------------------------------+"
print ""

if __name__ == '__main__':
	print 'Are your sure above information is correct?'
	print 'Press y to continue, q to quit.'
	while 1:
		c = getkey()
		if c == 'y' or c == 'Y':
			break
		elif c == 'q' or c == 'Q':
			sys.exit(1)

print "Building..."

# For debug
#sys.exit(1)

'''
 Redmine Connection
'''

# Auth by "API access key" 
#demo = redmine.Redmine('http://rd1-1/redmine', key='aff383eedceb4538ce57844fb9ea6a25e84e694f')
# Auth by "username/password"
#demo = redmine.Redmine('http://rd1-1/redmine', username='kent.chen', password='11111111')
demo = redmine.Redmine('http://172.16.7.64/redmine', username='kent', password='kent')


'''
 Created project under "OBM projects >> OBM 2012 Project"
'''

# Get the parent Project, e.g. OBM projects: http://rd1-1/redmine/projects/obm-projects
# parent_prj = demo.getProject('obm-2012-projects').newSubProject(name=PRJ_MODELNAME, identifier=PRJ_IDENTIFIER, description=PRJ_DESC, parent_id=parent_prj.number)
#obm_prj = demo.getProject('1105-03-ip8362-vvtl')
obm_prj = demo.getProject('obm-2012-projects')

parent_prj  = obm_prj.newSubProject(name = PRJ_MODELNAME,
									identifier  = PRJ_IDENTIFIER,
									description = PRJ_DESC,
									#parent_id  = obm_prj.number,
									homepage    = PRJ_HOMEPAGE)

'''
 Create 4 subprojects
'''
# OBM projects >> OBM 2012 Project
# Note that, "description" is a MUST
sub_prj_fw    = parent_prj.newSubProject(name = PRJ_MODELNAME + " FW development"    , description = "TBD" , identifier = PRJ_IDENTIFIER + "-fw")
sub_prj_hw    = parent_prj.newSubProject(name = PRJ_MODELNAME + " HW development"    , description = "TBD" , identifier = PRJ_IDENTIFIER + "-hw")
sub_prj_me    = parent_prj.newSubProject(name = PRJ_MODELNAME + " ME development"    , description = "TBD" , identifier = PRJ_IDENTIFIER + "-me")
sub_prj_image = parent_prj.newSubProject(name = PRJ_MODELNAME + " IMAGE development" , description = "TBD" , identifier = PRJ_IDENTIFIER + "-image")

'''
 Create 4 Milestones in main project
'''
#TBD, only available in Versions Alpha 1.3

'''
 Add tasks for each project (main project and subprojects)
'''
parent_prj.newIssue(subject = PRJ_MODELNAME + " weekly meeting")

# FW
sub_prj_fw.newIssue(subject = PRJ_MODELNAME + " C2 FW design")
sub_prj_fw.newIssue(subject = PRJ_MODELNAME + " 0100a development")
sub_prj_fw.newIssue(subject = PRJ_MODELNAME + " 0100b regress")
#depend on target version: IP8888-VVTK FW approval
sub_prj_fw.newIssue(subject = PRJ_MODELNAME + " 0100c regress", fixed_version_id = "")
sub_prj_fw.newIssue(subject = PRJ_MODELNAME + " Plug-in development")
sub_prj_fw.newIssue(subject = PRJ_MODELNAME + " FW support")

# HW
sub_prj_hw.newIssue(subject = PRJ_MODELNAME + " C2 HW design")
sub_prj_hw.newIssue(subject = PRJ_MODELNAME + " C3 HW pilot run")
sub_prj_hw.newIssue(subject = PRJ_MODELNAME + " C3 Layout gerber")
sub_prj_hw.newIssue(subject = PRJ_MODELNAME + " C3 EMC debug")
sub_prj_hw.newIssue(subject = PRJ_MODELNAME + " C4 HW pilot run")
sub_prj_hw.newIssue(subject = PRJ_MODELNAME + " C4 Layout gerber")
sub_prj_hw.newIssue(subject = PRJ_MODELNAME + " C4 EMC license")

# ME
sub_prj_me.newIssue(subject = PRJ_MODELNAME + " C2 ME design")
sub_prj_me.newIssue(subject = PRJ_MODELNAME + " C3 ME prototyping")
sub_prj_me.newIssue(subject = PRJ_MODELNAME + " C4 ME pre-pilot run")
sub_prj_me.newIssue(subject = PRJ_MODELNAME + " C5 ME pilot run")

# IMAGE
sub_prj_image.newIssue(subject = PRJ_MODELNAME + " IMG tuning")
sub_prj_image.newIssue(subject = PRJ_MODELNAME + " IMG algorithm")


'''
 NOTE
'''
print "\nNOTE: Please setup each subproject Manager, Developer and Reporter by yourself. Then setup Assignee"
