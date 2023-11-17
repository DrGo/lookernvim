local M = {}
local api = vim.api

M.config = {
	bibfile = '',
	close_on_selection = true,
}

function M.new(filename, config)
	local self = {}
	local isempty = function(s)
		return s == nil or s == ''
	end

	local close_window = function()
		vim.cmd(":quit")
	end
	if isempty(filename) then
		filename = M.config.bibfile
	end
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
	local ok, res = pcall(vim.cmd, "read " .. filename)
	if not ok then
		vim.print("error opening file: " .. res)
		close_window()
		return nil
	end

	api.nvim_buf_set_option(self.buf, "readonly", true)

	local cite_select = function()
		local l = vim.fn.search("@", "beW")
		if l == -1 then
			return
		end
		local linetext = api.nvim_get_current_line()
		linetext = string.match(linetext, "{(.+),")
		if not isempty(linetext) then
			linetext = string.format("[@{%s};]", linetext)
			api.nvim_buf_set_text(self.destbuf, self.destrow - 1, self.destcol, self.destrow - 1, self.destcol,
				{ linetext })
		end
		if config.close_on_selection then
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
	return {}
end

M.setup = function(args)
	M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.bib = function(bibfile)
	M.new(bibfile, M.config)
end

return M
