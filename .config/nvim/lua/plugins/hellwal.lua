return {
	"danihek/hellwal-vim",
	lazy = false,
	priority = 1000,
	opts = {
		transparent = true,
	},
	config = function()
		vim.cmd([[colorscheme hellwal]])
	end,
}
