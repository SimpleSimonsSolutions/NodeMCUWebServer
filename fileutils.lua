-- just some misc. functions
-- use as a library with "require"

function split(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function filesize (fname)
    l = file.list()
    for k,v in pairs(l) do
        if (k == fname) then return v end
    end
    return nil
end

function filetype (fname)
    -- find last "." and return everything to the right of it - or nil
    x = nil
    x = split(fname, "%.")  -- % escapes the magic character "."
    return x[#x] -- return the last item
end
