require("fileutils")

-- led1 = 5 -- originally 3 - 5 is the SCK LED
-- led2 = 4 -- GPIO2 - reversed ("off" is LIT)
-- gpio.mode(led1, gpio.OUTPUT)
-- gpio.mode(led2, gpio.OUTPUT)

hdr = ""
buf = ""

-- the next 2 lines could be in the .htm file if we weren't doing dynamic 'buf' stuff
buf = buf.."<!DOCTYPE HTML><html><body>\n"
buf = buf.."<h1>WeMos-D1 GPIO Control</h1>\n"

if (urlvars.p ~= nil) and (urlvars.s ~= nil) then
 -- print("url:",urlvars.p, urlvars.s)
    gpio.mode(urlvars.p, gpio.OUTPUT)
    gpio.write(urlvars.p, urlvars.s)
    buf = buf.."<h3>GPIO "..urlvars.p.." set to "..urlvars.s.." by URL</h3>\n"
end
if (formvars.p ~= nil) and (formvars.s ~= nil) then
 -- print("form:",formvars.p, formvars.s)
    gpio.mode(formvars.p, gpio.OUTPUT)
    gpio.write(formvars.p, formvars.s)
    buf = buf.."<h3>GPIO "..formvars.p.." set to "..formvars.s.." by Form</h3>\n"
end

-- Build messages and statuses into scontent
table.insert(scontent, "<h3>Pin Status</h3>\n")
for p = 0,12 do
    table.insert(scontent, "Pin "..p.."="..gpio.read(p).."<br/>\n")
end
table.insert(scontent, "</body></html>\n") -- could be in the .htm if not for using scontent

sconlen = 0
for i,line in ipairs(scontent) do 
    sconlen = sconlen + #line
end

local fname = "gpio.htm"
local clen = filesize(fname) + #buf + sconlen
-- print(filesize(fname) , #buf , sconlen)

-- Headers are built at the end so that we have content length (clen)
hdr = HttpResp200
hdr = hdr.."Content-Type: text/html\n"
hdr = hdr.."Content-Length: "..clen.."\n"
-- hdr = hdr..ServerID  -- this is added by the caller

file.open(fname)
OnSent = "sendfile"  -- tell caller to: client:on("sent", sendfile)
-- client:send(hdr..buf) done by the caller
