#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  openRedirect.py
#  
#  Copyright 2018 mszatanik <mszatanik@parrot>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  
import requests
from lxml import html, etree
from http.cookies import SimpleCookie
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import time
import json
import sys

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

global BA_BASE_URL, BA_LOGIN, BA_HASH, BA_LINE_VAR_CORRECT, ERROR_COUNT, BA_LOGIN_DATA

BA_LINE_VAR = "{{LINE}}"

BA_HEADERS = {
	"Cache-Control": "max-age=0",
	"Connection": "keep-alive",
	"Content-Type": "application/x-www-form-urlencoded",
	"Upgrade-Insecure-Requests": "1",
	"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36"
}
COLORS = [
    "\033[1;31m"    # red
    ,"\033[1;34m"   # blue
    ,"\033[1;36m"   # cyan
    ,"\033[0;32m"   # green
    ,"\033[93m"     # yellow
]
ENDC = '\033[0m'

def main():
	# ARGS CHECK
	if (len(sys.argv) != 5):
		hello(len(sys.argv) - 1)
	else :
		BA_BASE_URL = sys.argv[1]
		BA_LOGIN = sys.argv[2]
		BA_HASH = sys.argv[3]
		BA_LINE_VAR_CORRECT = sys.argv[4]
		BA_LOGIN_DATA = {
			"login": BA_LOGIN,
			"password": BA_HASH,
			"moduleCode": "",
			"token": "",
			"id": "",
			"method:Login": "true"
		}
	
	''' OPEN FILE '''
	f = open("openRedirect.txt", "r")
	
	''' INIT ERROR COUNT '''
	ERROR_COUNT = 0
	
	''' FOR EACH LINE IN FILE '''
	for l in f: 
		try:
			
			''' REPLACE {{LINE}} WITH DEFAULT VALUE FROM PARAM '''
			if (BA_LINE_VAR in l):
				#print("DD :: LINE = " + l)
				l = l.replace(BA_LINE_VAR, BA_LINE_VAR_CORRECT)
				#print("DD :: LINE = " + l)
			
			''' CREATE URL '''
			ru = BA_BASE_URL + l
			
			''' BEGIN TEST '''
			print(COLORS[4] + "\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" + ENDC)
			print(COLORS[4] + "II :: TESTING: " + ru + ENDC)
			
			''' GET COOKIES '''
			r = requests.get(ru, verify=False)
			cookies = getCookies(r)
			print(COLORS[1] + "II :: cookies: " + json.dumps(cookies) + ENDC)
			
			''' LOGIN TO BACKOFFICE WITH PROVIDED PARAMS '''
			r = requests.post(ru, data=BA_LOGIN_DATA, cookies=cookies, headers=BA_HEADERS, verify=False, allow_redirects=True)
			c = r.status_code
			print(COLORS[1] + "II :: status code: " + str(c) + ENDC)
			
			if (r.status_code == 200):
				tree = html.fromstring(r.content)
				title = tree.cssselect('title')[0].text_content()
				
				if (title != "Welcome"):
					print (COLORS[0] + "EE :: wrong page title: " + title + ENDC)
					ERROR_COUNT += 1
					
					''' WRONG PAGE - BASED ON <TITLE></TITLE> '''
				else:
					print (COLORS[1] + "II :: landed on: " + title + ENDC)
				
				''' NOT 200 HTTP STATUS CODE '''
			else:
				print (COLORS[0] + "EE :: wrong status code: " + str(c) + ENDC)
				ERROR_COUNT += 1
			
			''' DELAY TO LIMIT SERVER LOAD '''
			time.sleep(1)
			
			''' OTHER EXCEPTIONS + CONTINUE '''
		except Exception:
			print(COLORS[0] + "EE :: " + str(sys.exc_info()[0]) + ENDC)
			continue # SO THAT AN EXCEPTION WILL NOT BREAK THE TEST
	
	''' PRINT SUMMARY BASED ON ERROR COUNT '''
	print (COLORS[4] + "\n\n============================================================================" + ENDC)
	if (ERROR_COUNT == 0):
		print (COLORS[1] + "NO ERRORS" + ENDC)
	else:
		print (COLORS[0] + "PLS CHECK THE OUTPUT, ERRORS DETECTED: " + str(ERROR_COUNT) + ENDC)
	
	return 0

''' GETS COOKIES FROM RESPONSE '''
def getCookies(response):
	cookieString = response.headers["Set-Cookie"]
	cookie = SimpleCookie()
	cookie.load(cookieString)
	
	cookies = {}
	for key, morsel in cookie.items():
		cookies[key] = morsel.value
		
	return cookies

''' HELP '''
def hello(paramsNo):
	if (paramsNo > 0):
		print(COLORS[0] + "EE :: got " + str(paramsNo) + " parameters, expected 4" + ENDC)
		
	print(COLORS[4] + "pls provide URL, LOGIN, password HASH and DEFAULT returnUrl value e.g.:" + ENDC)
	print(COLORS[0] + "python openRedirect.py \"https://example.com/login?returnUrl=\" login pass \"/where/i/should/be/redirected\"" + ENDC)
	quit()

main()

