require("fileutils")

-- led1 = 5 -- originally 3 - 5 is the SCK LED
-- led2 = 4 -- GPIO2 - reversed ("off" is LIT)
-- gpio.mode(led1, gpio.OUTPUT)
-- gpio.mode(led2, gpio.OUTPUT)

if (urlvars.p ~= nil) and (urlvars.s ~= nil) then
print("url:",urlvars.p, urlvars.s)
    gpio.mode(urlvars.p, gpio.OUTPUT)
    gpio.write(urlvars.p, urlvars.s)
end
if (formvars.p ~= nil) and (formvars.s ~= nil) then
print("form:",formvars.p, formvars.s)
    gpio.mode(formvars.p, gpio.OUTPUT)
    gpio.write(formvars.p, formvars.s)
end

-- Build messages and statuses into buf
buf = buf.."<h3>Pin Status</h3>"
for p = 0,12 do
    buf = buf.."Pin "..p.."="..gpio.read(p).."<br/>"
end

local fname = "gpio.htm"
local clen = filesize(fname) + #buf

hdr =      HttpResp200
hdr = hdr.."Content-Type: text/html\n"
hdr = hdr.."Content-Length: "..clen.."\n"
-- hdr = hdr..ServerID  -- this is added by the caller

file.open(fname)
OnSent = "sendfile"  -- tell caller to: client:on("sent", sendfile)
-- client:send(hdr..buf) done by the caller
