vim.api.nvim_create_user_command("Bib", function(opts)
	require("nvimbib").lookup(opts.fargs[1] or nil)
end, { nargs = '?' })


vim.api.nvim_create_user_command("Lookup", function(opts)
	local err = require("nvimbib").lookup(opts)
	if err ~= nil then
		error(err)
	end
end, { nargs = '*' })
