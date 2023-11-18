local M = {}
local api = vim.api

M.config = {
	bib = {
		search_file = '',
		record_marker = "@",
		extract_id_regex = "{(.+),",
		id_format = "[@{%s};]",
		close_on_selection = true,
	},
}

local isempty = function(s)
	return s == nil or s == ''
end

local close_window = function()
	vim.cmd(":quit")
end

local err = function(msg, close)
	vim.print(msg)
	if close then
		close_window()
	end
	return msg
end

local function show(search_spec)
	local self = {}

	self.destrow, self.destcol = unpack(api.nvim_win_get_cursor(0))
	self.destbuf = vim.fn.bufnr()
	self.buf = api.nvim_create_buf(false, true) --scratch buffer
	api.nvim_buf_set_option(self.buf, "bufhidden", "wipe")

	local width, height   = api.nvim_get_option("columns"), api.nvim_get_option("lines")
	local wheight, wwidth = math.ceil(height * 0.8 - 4), math.ceil(width * 0.8)
	local row, col        = math.ceil((height - wheight) / 2 - 1), math.ceil((width - wwidth) / 2)

	self.win              = api.nvim_open_win(self.buf, true,
		{
			style = "minimal",
			relative = "editor",
			width = wwidth,
			height = wheight,
			row = row,
			col = col,
			border = "rounded",
		}
	)
	api.nvim_win_set_option(self.win, "cursorline", true)
	local ok, res = pcall(vim.cmd, "read " .. search_spec.search_file)
	if not ok then
		err("cannot load file " .. search_spec.search_file .. res, search_spec.close_on_selection)
	end

	api.nvim_buf_set_option(self.buf, "readonly", true)

	local cite_select = function()
		local l = vim.fn.search(search_spec.record_marker, "beW")
		if l == -1 then
			return
		end
		local linetext = api.nvim_get_current_line()
		linetext = string.match(linetext, search_spec.extract_id_regex)
		if not isempty(linetext) then
			linetext = string.format(search_spec.id_format, linetext)
			api.nvim_buf_set_text(self.destbuf, self.destrow - 1, self.destcol, self.destrow - 1, self.destcol,
				{ linetext })
		end
		if search_spec.close_on_selection then
			close_window()
		end
	end

	local mappings = {
		['<cr>'] = cite_select,
		q = close_window,
	}
	for k, v in pairs(mappings) do
		vim.keymap.set({ 'n' }, k, v, {
			nowait = true, noremap = true, silent = true, buffer = self.buf
		})
	end
	-- api.nvim_buf_set_option(m.buf, "modifiable", false)
	return nil
end

M.setup = function(args)
	M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

-- lookup accepts either 1 or 2 arguments
-- if 1 argument, it's interpreted as command if it was string
-- or as search_spec table if it was a table
-- if 2 arguments, the first must be a valid command entry  in
-- the config table and the second is a path to file to search
-- (it will override the search_file entry in the config table)

M.lookup = function(opts)
	local cmd, search_spec, search_file
	if #opts.fargs == 1 then
		-- a command passed
		if type(opts.fargs[1]) == "string" then
			cmd = opts.fargs[1]
			-- search_spec passed
		elseif type(opts.fargs[1]) == "table" then
			search_spec = opts.fargs[1]
		else
			return err("must specify a command or search_spec")
		end
		-- a command and filename passed passed 	
	elseif #opts.fargs == 2 and type(opts.fargs[1]) == "string" and type(opts.fargs[2]) == "string" then
		cmd = opts.fargs[1]
		search_file = opts.fargs[2]
	else
		return err("Lookup: invalid arguments")
	end

	if cmd == nil then
		M.new(search_spec)
	elseif M.config == nil then
		return err("command specified  without valid config")
	else
		search_spec = M.config[cmd]
		if search_spec == nil then
			return err("config does not have an entry for command:" .. cmd)
		end
		if not isempty(search_file) then
			search_spec.search_file = search_file
		end
	end
	if isempty(search_spec.search_file) then
		return err("must specifiy a search file" .. cmd)
	end
	return show(search_spec)
end

return M
