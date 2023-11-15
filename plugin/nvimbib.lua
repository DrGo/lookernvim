vim.api.nvim_create_user_command("Bib", function (opts)
	 require("nvimbib").bib(opts.fargs[1] or nil)
end, {nargs='?'})
