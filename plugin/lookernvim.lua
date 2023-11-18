vim.api.nvim_create_user_command("Lookup", function(opts)
	local err = require("nvimbib").lookup(opts)
	if err ~= nil then
		error(err)
	end
end, { nargs = '*', complete = 'file' })


vim.api.nvim_create_user_command("Bib", 'Lookup bib', { nargs = '?', complete = 'file' })