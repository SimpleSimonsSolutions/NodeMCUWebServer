-- URL utility functions
-- from http://www.lua.org/pil/20.3.html

    function unescape (s)
      s = string.gsub(s, "+", " ")
      s = string.gsub(s, "%%(%x%x)", function (h)
            return string.char(tonumber(h, 16))
          end)
      return s
    end

    function decode (s)
      local cgi = {}
      for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        name = unescape(name)
        value = unescape(value)
        cgi[name] = value
      end
      return cgi
    end

    function escape (s)
      s = string.gsub(s, "([&=+%c])", function (c)
            return string.format("%%%02X", string.byte(c))
          end)
      s = string.gsub(s, " ", "+")
      return s
    end

    function encode (t)
      local s = ""
      for k,v in pairs(t) do
        s = s .. "&" .. escape(k) .. "=" .. escape(v)
      end
      return string.sub(s, 2)     -- remove first `&'
    end