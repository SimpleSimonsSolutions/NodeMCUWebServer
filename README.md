# NodeMCUWebServer
NodeMCU WeMos-D1R2 / ESP8266 WebServer

This WebServer may run on NodeMCU builds other than WeMos-D1R2 / ESP8266.

I would be very interested in finding out.

It should support serving up basic non-HTML such as jpg, wav, etc. But it's not tested.

(look in WebServer.lua for allowable types)

I use Esplorer as my IDE. Boot ID:

	NodeMCU 0.9.6 build 20150704  powered by Lua 5.1.4
	
	Boot heap: 32736. Webserver active idle heap: 18104.

WebServer.lua -- Main module. Needs to be run as a compiled (lc) file for memory reasons.

	fileutils.lua -- "require"d module - compile it
	
	urlutils.lua -- "required"d module - compile it

Some basic webcontent:

	favicon.ico - My logo. Initially used for basic testing, but now my "brand". :)
	
	index.htm - default web page - if no filename in URL, this is used
	
	gpio.lua / gpio.htm - just a basic form-based GET/POST combination for testing / demonstration
	
	WiFi.lua - does not yet exist. Will be a "port" of WiFiInfo, but currently just 404 testing. ;)

There are a few little utility programs that I've not been
able to find anywhere else (maybe I've reinvented the wheel):

	printfile.lua - parameter is the filename (duh)
	
	WiFiInfo.lua - prints all current wifi status it can find.
