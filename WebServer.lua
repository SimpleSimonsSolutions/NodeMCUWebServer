require("fileutils")
require("urlutils")

ServerID = "Server: ESP-SSS (nodeMCU)\n\n"  -- note - double newline = last header
print(ServerID, wifi.sta.getip())

OnSent = ""  -- here so it's global. Used to set the desired client:on("sent"...

-- Not all of these are implemented - not by any means
-- Content_Types = {"application", "audio", "image", "message", "multipart", "text", "video"}
-- Appl_SubTypes = {"zip"}
-- Audi_SubTypes = {"x-wav"} -- mp3 ?
-- Imag_SubTypes = {"bmp", "gif", "jpeg", "png", "tiff", "x-icon"}
-- Text_SubTypes = {"calendar", "css", "csv", "html", "plain", "x-vcalendar", "x-vcard"}
FileTypes = {}
-- executable files
FileTypes.lua = "executable"
FileTypes.lc  = "executable"
-- static files
FileTypes.zip = "application/zip"
FileTypes.wav = "audio/x-wav"
FileTypes.bmp = "image/bmp"
FileTypes.gif = "image/gif"
FileTypes.jpg = "image/jpeg"
FileTypes.png = "image/png"
FileTypes.tif = "image/tiff"
FileTypes.ico = "image/x-icon"
-- cal
FileTypes.css = "text/css"
FileTypes.csv = "text/csv"
FileTypes.htm = "text/html"
FileTypes.txt = "text/plain"
-- vcal, vcard

-- When you use a Response more than once, save space!
HttpResp200 = "HTTP/1.1 200 OK\n"
HttpResp405 = "HTTP/1.1 405 Method Not Allowed\n"
HttpRbuf405 = "<h1>405 That is a no-no</h1>"

srv=net.createServer(net.TCP)  -- create the server

-- everything after this point is callbacks or functions
-- the programs straight-line execution ends here (unless some turkey miscodes something)

-- REMEMBER: This is a callback function - NOT an inline program
srv:listen(80, function(conn)
    conn:on("receive", function (client, request)

        local function sendtext (client) -- only useful for SMALL send queues due to heap
        -- typical case: client:send of the headers & buf triggers us

            if #scontent > 0 then
                client:send(table.remove(scontent,1))
            else
                client:close()
                collectgarbage()
            end
        end
        -- client:on("sent", sendtext)

        local function sendfile (client) -- file must already be open
        -- typical case is a client:send of the headers triggers us

            fbuf = file.read()
            if fbuf ~= nil then
                client:send(fbuf)
            else  -- End Of File
                file.close();
                client:on("sent", sendtext)
                sendtext(client) -- output scontent after the file
            end
        end

        OnSent = ""  -- Make sure OnSent is default
        -- input (request) variables
        method = ""  -- GET, POST, PUT, DELETE
        path = ""  -- the target file
        qstring = ""  -- the URL query string (text after the "?")
        urlvars = {}  -- parsed and decoded qstring
        headervars = {}  -- parsed request headers
        formvars = {}  -- parsed and decoded POST (Form) variables

        -- output (response) variables
        hdr = ""  -- the response header lines
        buf = ""  -- optionally used for single-send output
        scontent = {}  -- optionally used for segmented output by "sendtext"

        _, _, method, path, qstring = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if (method == nil) then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end

        -- print("request^",request)
        print("***** web request *****")
        print("method^",method)
        print("path^",path)
        print("qstring^",qstring)
        
        if (qstring ~= nil) then
            urlvars = decode(qstring)
        end
        
        local _, _, headers, rcontent = string.find(request, "\n(.+)\n(.+)");
        -- print ("headers^",headers)
        print("content^",rcontent)

        if (headers ~= nil) then
            for name, value in string.gmatch(headers,"([^\n]+): ([^\n]+)") do
                name = unescape(name)
                value = unescape(value)
                headervars[name] = value
            end
            -- for k,v in pairs(headervars) do
            --     print("H**"..k.."="..v.."**")
            -- end
        end

        if (path == "/") then path = "/index.htm" end  -- hard-coded default name

        client:on("sent", sendtext) -- default sent handler - usually just closes
            
        local fname = string.sub(path,2)  -- trim off the leading "/"
        local ftype = filetype(fname)
        local fsize = filesize(fname) -- if nil, it's a not found
        local ctype = FileTypes[ftype] -- 
            
        if (string.find(fname, "/") ~= nil) then  -- too many "/"
            hdr = "HTTP/1.1 422 Unprocessable Entity\n"
            buf = "<h1>422 You're a slasher</h1>"
        elseif (ctype == nil) then  -- invalid filetype
            hdr = "HTTP/1.1 501 Not Implemented\n"
            buf = "<h1>501 No idea what to do with "..fname.."</h1>"
        elseif (method == "PUT") or (method == "DELETE") then
            hdr = HttpResp405
            buf = HttpRbuf405
        elseif (method == "GET") or (method == "POST") then
            if (fsize == nil) then  -- it doesn't exist
                hdr = "HTTP/1.1 404 NOT FOUND\n"
                buf = "<h1>404 The thing you want ("..fname..") is not within my grasp</h1>"
            elseif (fsize == 0) then  -- it's gone (zero size file placeholder)
                hdr = "HTTP/1.1 410 Gone\n"
                buf = "<h1>410 Aaaaaaannnndd - it's gone!</h1>"
            elseif (ctype == "executable") then
                if (method == "POST") then
                      formvars = decode(rcontent)
                    -- for k,v in pairs(formvars) do
                    --     print("F**"..k.."="..v.."**")
                    -- end
                end
                dofile(fname)  -- hdr must, and buf can, be set by the target
            elseif (method == "POST") then -- but not executable so it's not "POST"able
                hdr = HttpResp405
                buf = HttpRbuf405
            elseif file.open(fname) then -- it's static content - and we have it
                hdr = HttpResp200
                hdr = hdr.."Content-Type: "..ctype.."\n"
                hdr = hdr.."Content-Length: "..fsize.."\n" 
                -- file is read by the sendfile event callback
                OnSent = "sendfile" 
            else  -- unable to send the file
                hdr = "HTTP/1.1 500 Internal Server Error\n"
                buf = "<h1>500 Oops - sorry!<h1>"
            end
         --   print(hdr)
        else -- no idea what method it is
            hdr = "HTTP/1.1 400 Bad Request\n"
            buf = "<h1>400 Huh?</h1>"
        end

        if (OnSent == "sendfile") then
            client:on("sent", sendfile)  -- file must already be open
        else
            client:on("sent", sendtext)
        end
        client:send(hdr..ServerID..buf) -- This will also trigger the "sent" event
    end)
end)

