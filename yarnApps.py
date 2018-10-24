#! /bin/python


import json 
import httplib#,urllib
import sys, getopt, re

## Settings
yarnAppsUrl="http://server:8080/update"
yarnAppsUrlDetails="http://server:8080/details?app="


## Functions

def usage():
	print "\n\t-- HELP --"	
	print "\t$ yarnApps (-h) --help"	
	print "\t$ yarnApps (-s) --status [ all | pattern ]"	
	print "\t$ yarnApps (-l) --list   [ all | pattern ]"		
	print "\t$ yarnApps (-a) --app    [ pattern ]"
	print "\t$ yarnApps      --getAppId  [ full app name + version ]"
	print "\t$ yarnApps      --getContainers [ full app name + version ]"
	print "\t$ yarnApps      --getServers [ full app name + version ]"
	print "\t$ yarnApps      --getLogsPath  [ full app name + version ]"

	print "\n"

def statusall(app):

	#if app:
	#	print "Pattern : ",app
	#elif not app:
	#	print "all"
	#print "-"+app+"-"


	urlsrvr = yarnAppsUrl.split("/")[2]
	urlpath = "/"+ yarnAppsUrl.split("/")[3]
	
	#conn = httplib.HTTPConnection('serverIP', 80, timeout=10)
	conn = httplib.HTTPConnection(urlsrvr)
	conn.request("get",urlpath)
	response = conn.getresponse()
	#print  response.status 

	jsonArray= json.loads(response.read())

	
	# status :
	# FAILED ,KILLED, RUNNING, SUCCEEDED,ACCEPTED , STOPPED (when app is stopped json is empty)


	for key  in jsonArray['apps'].keys():
		
		status=jsonArray['apps'][key]['status']		
		if not status:
			status="STOPPED"	

		if app == 'all':
			print '{:.<50}  {:<10}'.format(key,status)
			#print '{:>10}  {}'.format(status,key)	
		elif app:
			if app.lower() in key.lower(): #making case insensitive
				print '{:.<50}  {:<10}'.format(key,status)
		else:
			break
	


def statusapp(app):


	#appname =  app.split("-")[0] # with version or instance
	appname = re.split("-[0-9]",app)[0]

	urlsrvr = yarnAppsUrl.split("/")[2]
	urlpath = "/"+ yarnAppsUrl.split("/")[3]	
	conn = httplib.HTTPConnection(urlsrvr)
	conn.request("get",urlpath)
	response = conn.getresponse()
	jsonArray= json.loads(response.read())
	
	for key in jsonArray['apps'].keys():
		if appname in key:
			status=jsonArray['apps'][key]['status']
			if not status:
				status="STOPPED"			
			print '{:.<50}  {:<10}'.format(key,status)




def listapps(pattern):

	urlsrvr = yarnAppsUrl.split("/")[2]
	urlpath = "/"+ yarnAppsUrl.split("/")[3]	
	conn = httplib.HTTPConnection(urlsrvr)
	conn.request("get",urlpath)
	response = conn.getresponse()
	jsonArray= json.loads(response.read())
	

	for key  in jsonArray['apps'].keys():
		if pattern == 'all':
			print key
		elif pattern:
			if pattern.lower() in key.lower(): #making case insensitive
				print key
		else:
			break


def getAppId(app):
	urlsrvr = yarnAppsUrl.split("/")[2]
	urlpath = "/"+ yarnAppsUrl.split("/")[3]	
	appId = ""
	conn = httplib.HTTPConnection(urlsrvr)
	conn.request("get",urlpath)
	response = conn.getresponse()
	jsonArray= json.loads(response.read())
	for key in jsonArray['apps'].keys():
		if app.lower() in key.lower():			
			appId = jsonArray['apps'][key]['appId']
			#print jsonArray['apps'][key]['appId']
	return appId



#def getContainers(app):
#	urlsrvr = yarnAppsUrl.split("/")[2]
#	urlpath = "/"+ yarnAppsUrl.split("/")[3]	
#	conn = httplib.HTTPConnection(urlsrvr)
#	conn.request("get",urlpath)
#	response = conn.getresponse()
#	jsonArray= json.loads(response.read())
#	for key in jsonArray['apps'].keys():
#		if app.lower() in key.lower():
#			noContainers=jsonArray['apps'][key]['resources'].get('usedContainers') 
#			print noContainers

def getContainers(app):
	urlsrvr = yarnAppsUrlDetails.split("/")[2]
	urlpath = "/"+ yarnAppsUrlDetails.split("/")[3]+app	
	conn = httplib.HTTPConnection(urlsrvr)
	conn.request("get",urlpath)
	response = conn.getresponse()
	jsonArray= json.loads(response.read())
	for key in jsonArray['containers'].keys():
		print key


def getServers(app):
	urlsrvr = yarnAppsUrlDetails.split("/")[2]
	urlpath = "/"+ yarnAppsUrlDetails.split("/")[3]+app	
	conn = httplib.HTTPConnection(urlsrvr)
	conn.request("get",urlpath)
	response = conn.getresponse()
	jsonArray= json.loads(response.read())
	for key in jsonArray['containers'].keys():
		print jsonArray['containers'][key]
    

def getLogsPath(app):
	urlsrvr = yarnAppsUrlDetails.split("/")[2]
	urlpath = "/"+ yarnAppsUrlDetails.split("/")[3]+app	
	conn = httplib.HTTPConnection(urlsrvr)
	conn.request("get",urlpath)
	response = conn.getresponse()
	jsonArray= json.loads(response.read())
	for key in jsonArray['containers'].keys():
		print jsonArray['containers'][key]+":"+"/opt/vendor/analytics/log/yarn-nodemanager/"+getAppId(app)+"/"+key





def main(argv):

	if len(argv[1:]) == 0:
		usage()

	try:
		opts, args =  getopt.getopt(argv[1:],"hs:va:l:",["help","status=","app=","list=","getAppId=","getContainers=","getServers=","getLogsPath="])
	except getopt.GetoptError as err:
		print str(err)  
		usage()
		sys.exit(2)
	verbose = False
	for opt, arg in opts:
	
		if opt == "-v":
			verbose = True
	
		elif opt in ("-h","--help"):
			usage()
			sys.exit()

		elif opt in ("-s","--status"):
			statusall(arg)

		elif opt in ("-a","--app"):
			statusapp(arg)

		elif opt in ("-l","--list"):
			listapps(arg)

		elif opt in ("--getAppId"):
			print getAppId(arg)

		elif opt in ("--getContainers"):
			getContainers(arg)

		elif opt in ("--getServers"):
			getServers(arg)

		elif opt in ("--getLogsPath"):
			getLogsPath(arg)

		else:
			assert False, "Unhandled Option"

	
	#----------------------------------------------





if __name__ == '__main__':
	main(sys.argv)



