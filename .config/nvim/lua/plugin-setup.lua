local status, packer = pcall(require, 'packer')
if not status then
	return
end

return packer.startup(function(use)
	use('wbthomason/packer.nvim')
	use 'tanvirtin/monokai.nvim'
	use 'nvim-tree/nvim-web-devicons'

	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

	use {
		'nvim-tree/nvim-tree.lua',
		requires = {
			'nvim-tree/nvim-web-devicons', -- optional
		},
	}

	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'nvim-tree/nvim-web-devicons', opt = true }
	}

	use {
		'nvim-telescope/telescope.nvim',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

end)
