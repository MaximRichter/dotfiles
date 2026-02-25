return {
	"AlphaTechnolog/pywal.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local pywal = require("pywal")
		pywal.setup()

		-- Перезагружать тему при получении SIGUSR1
		vim.api.nvim_create_autocmd("Signal", {
			pattern = "SIGUSR1",
			callback = function()
				pywal.setup()
				vim.cmd("colorscheme pywal")
				vim.schedule(function()
					vim.cmd("redraw!")
				end)
			end,
		})
	end,
}
