function printfile (fname)
    file.open(fname)
    
    local buf = ""
    while (buf ~= nil) do
        buf = file.readline()
        if (buf ~= nil) then
            print(string.sub(buf,1,-2))
        end
    end

    file.close()
end
