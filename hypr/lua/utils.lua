local M = {}

function M.hostname()
	local f = io.open("/etc/hostname", "r")
	if not f then
		return os.getenv("HOSTNAME") or ""
	end

	local name = f:read("*l") or ""
	f:close()

	return name:gsub("%s+$", "")
end

function M.is_host(name)
	return M.hostname() == name
end

return M
