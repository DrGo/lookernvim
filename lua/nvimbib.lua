local M = {
	buf = 0,
	win = 0,
	destbuf = 0,
	destrow = 0,
	destcol = 0
}
M.config = {
	bibfile = '',
	close_on_selection = true,
}

local api = vim.api

local function close_window()
	vim.cmd(":quit")
end

local function isempty(s)
	return s == nil or s == ''
end

local function show(m, filename)
	m.destrow, m.destcol = unpack(api.nvim_win_get_cursor(0))
	m.destbuf = vim.fn.bufnr()
	m.buf = api.nvim_create_buf(false, true) --scratch buffer
	api.nvim_buf_set_option(m.buf, "bufhidden", "wipe")

	-- local mapopts         = { buffer = buf, noremap = true, silent = true }
	-- vim.keymap.set({ 'n' }, '<CR>', 	end, mapopts)
	-- vim.keymap.set({ 'n' }, 'q', api.nvim_win_close(win, true), mapopts)

	local width, height   = api.nvim_get_option("columns"), api.nvim_get_option("lines")
	local wheight, wwidth = math.ceil(height * 0.8 - 4), math.ceil(width * 0.8)
	local row, col        = math.ceil((height - wheight) / 2 - 1), math.ceil((width - wwidth) / 2)

	m.win                 = api.nvim_open_win(m.buf, true,
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
	api.nvim_win_set_option(m.win, "cursorline", true)
	local ok, res = pcall(vim.cmd, "read " .. filename)
	if not ok then
		vim.print("error opening file: " .. res)
		close_window()
		return false
	end

	api.nvim_buf_set_option(m.buf, "readonly", true)
	-- api.nvim_buf_set_option(m.buf, "modifiable", false)
	return true
end


local function pcite_select(m)
	local l = vim.fn.search("@", "beW")
	if l > -1 then
		local linetext = api.nvim_get_current_line()
		linetext = string.match(linetext, "{(.+),")
		if not isempty(linetext) then
			linetext = string.format("[@{%s};]", linetext)
			-- vim.print("modifying buffer:", m.buf)
			api.nvim_buf_set_text(m.destbuf, m.destrow - 1, m.destcol, m.destrow - 1, m.destcol, { linetext })
		end
		if m.config.close_on_selection then
			-- api.nvim_win_close(win, true) -- vim.cmd(":quit")
			close_window()
		end
	end
end

local function cite_select()
	pcite_select(M)
end

M.config.mappings = {
	['<cr>'] = cite_select,
	q = close_window,
}


local function set_mappings(m)
	for k, v in pairs(M.config.mappings) do
		vim.keymap.set({ 'n' }, k, v, {
			nowait = true, noremap = true, silent = true, buffer = m.buf
		})
	end
end
M.setup = function(args)
	M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.bib = function(bibfile)
	if bibfile == nil then
		bibfile = M.config.bibfile
	end
	if show(M, bibfile) then
		set_mappings(M)
	end
end
return M
