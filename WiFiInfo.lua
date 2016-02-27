-- Display WiFi Info

local WiFiModes = {"STATION", "SOFTAP", "STATIONAP"}
local StaStatuses = {"IDLE", "CONNECTING", "WRONG_PASSWORD",
                     "NO_AP_FOUND", "CONNECT_FAIL", "GOT_IP"}
local PhyModes = {"B", "G", "N"}
local AuthModes = {"Open", "????", "WPA_PSK", "WPA2_PSK", "WPA_WPA2"}

print("Current WiFi configuration:"
.."\nWiFi Mode : "..WiFiModes[wifi.getmode()]..""
.."\nPhys. Mode: "..PhyModes[wifi.getphymode()]..""
.."\nChannel   : "..wifi.getchannel())
if (net.dns.getdnsserver(0) ~= nil) then
    print("DNS 0     : "..net.dns.getdnsserver(0))
end
if (net.dns.getdnsserver(1) ~= nil) then
    print("DNS 1     : "..net.dns.getdnsserver(1))
end
print("")

local ssid, password, bssid_set, bssid=wifi.sta.getconfig()
print("Current Station configuration:"
.."\nStatus    : "..StaStatuses[wifi.sta.status()+1]..""
.."\nSSID      : "..ssid
.."\nPassword  : "..password
.."\nBSSID_set : "..bssid_set
.."\nBSSID     : "..bssid
.."\nMAC       : "..wifi.sta.getmac()
)
if wifi.sta.status() == 5 then
    local StaIP, NetMask, Gateway=wifi.sta.getip()
    print(  "Station IP: "..StaIP
        .."\nNetMask   : "..NetMask
        .."\nGateway   : "..Gateway
        .."\nB-Cast IP : "..wifi.sta.getbroadcast()
        )
end
print("")
    
-- Note: get/sethostname is documented but doesn't seem to exist

-- getconfig doesn't exist: ssid, password, bssid_set, bssid=wifi.ap.getconfig()
local StaIP, NetMask, Gateway=wifi.ap.getip()
print("Current Access Point configuration:"
.."\nMAC       : "..wifi.ap.getmac()
.."\nAcc.Pt. IP: "..StaIP
.."\nNetMask   : "..NetMask
.."\nGateway   : "..Gateway
.."\nB-Cast IP : "..wifi.ap.getbroadcast()
.."\n")

-- Connected WiFi clients
if wifi.getmode() > 1 then
    FirstTime = 1;
    for mac,ip in pairs(wifi.ap.getclient()) do
        if (FirstTime == 1) then
            print("Attached Clients:\nMAC\t\t\t\t\tIP Address")
            FirstTime = 0
        end
        print(mac,"\t",ip)
    end
    print("")
end

-- Print AP list that is easier to read
wifi.sta.getap(1, listap);

function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
    print("\nVisible Access Points:")
    print("\t\t\t\t\t\tSSID\t\tCh.\tRSSI\tAUTHMODE\tBSSID")
    for bssid,v in pairs(t) do
        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        print(string.format("%32s",ssid)
              .."\t"..channel
              .."\t"..rssi
              .."\t\t"..AuthModes[authmode+1]..""
              .."\t"..bssid
              )
    end
end
