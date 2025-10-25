-- ============================================================================
-- NEOVIM VSCODE-STYLE CONFIGURATION
-- Makes Neovim behave like a traditional text editor (VSCode-style)
-- No modal editing, normal keybindings, beginner-friendly
-- ============================================================================

-- ============================================================================
-- BASIC SETTINGS
-- ============================================================================

-- Enable mouse support for clicking, selecting, and scrolling
vim.opt.mouse = 'a'

-- Show line numbers on the left
vim.opt.number = true

-- Highlight the current line
vim.opt.cursorline = true

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Use system clipboard for all yank/delete/paste operations
vim.opt.clipboard = 'unnamedplus'

-- Set tab width to 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Enable smart indenting
vim.opt.smartindent = true

-- Show matching brackets
vim.opt.showmatch = true

-- Enable line wrapping
vim.opt.wrap = true

-- Always show status line at the bottom
vim.opt.laststatus = 2

-- Show command in bottom bar
vim.opt.showcmd = true

-- Enable true color support
vim.opt.termguicolors = true

-- Set encoding to UTF-8
vim.opt.encoding = 'utf-8'

-- Keep 8 lines visible above/below cursor when scrolling
vim.opt.scrolloff = 8

-- Enable incremental search (search as you type)
vim.opt.incsearch = true

-- Highlight search results
vim.opt.hlsearch = true

-- Case insensitive search unless you use capitals
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ============================================================================
-- STATUS LINE (Simple and Clean)
-- ============================================================================

-- Custom status line showing: filename, modified flag, line/column, percentage
vim.opt.statusline = ' %f %m%=%l:%c | %p%% '

-- ============================================================================
-- START IN INSERT MODE (No Modal Editing)
-- ============================================================================

-- Automatically enter insert mode when opening a file
vim.cmd('autocmd BufRead,BufNewFile * startinsert')

-- Also start in insert mode when switching buffers
vim.cmd('autocmd BufEnter * if &buftype != "terminal" | startinsert | endif')

-- ============================================================================
-- VSCODE-STYLE KEYBINDINGS
-- ============================================================================

-- Make Escape work in insert mode (in case you want to use commands)
vim.keymap.set('i', '<Esc>', '<Esc>', { noremap = true })

-- Ctrl+S to save file (works in both insert and normal mode)
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })

-- Ctrl+C to copy (visual mode)
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })

-- Ctrl+X to cut (visual mode)
vim.keymap.set('v', '<C-x>', '"+d', { noremap = true })

-- Ctrl+V to paste (insert and normal mode)
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true })
vim.keymap.set('n', '<C-v>', '"+p', { noremap = true })

-- Ctrl+Z to undo (insert and normal mode)
vim.keymap.set('i', '<C-z>', '<Esc>ua', { noremap = true })
vim.keymap.set('n', '<C-z>', 'u', { noremap = true })

-- Ctrl+Y to redo (insert and normal mode)
vim.keymap.set('i', '<C-y>', '<Esc><C-r>a', { noremap = true })
vim.keymap.set('n', '<C-y>', '<C-r>', { noremap = true })

-- Ctrl+F to find/search (opens search prompt)
vim.keymap.set('i', '<C-f>', '<Esc>/', { noremap = true })
vim.keymap.set('n', '<C-f>', '/', { noremap = true })

-- Ctrl+A to select all (works in normal mode)
vim.keymap.set('n', '<C-a>', 'ggVG', { noremap = true })
vim.keymap.set('i', '<C-a>', '<Esc>ggVG', { noremap = true })

-- Ctrl+Q to quit (with confirmation if unsaved changes)
vim.keymap.set('n', '<C-q>', ':q<CR>', { noremap = true })
vim.keymap.set('i', '<C-q>', '<Esc>:q<CR>', { noremap = true })

-- ============================================================================
-- ARROW KEYS (Work Normally)
-- ============================================================================

-- Arrow keys work normally in insert mode (already default, but ensuring)
vim.keymap.set('i', '<Up>', '<Up>', { noremap = true })
vim.keymap.set('i', '<Down>', '<Down>', { noremap = true })
vim.keymap.set('i', '<Left>', '<Left>', { noremap = true })
vim.keymap.set('i', '<Right>', '<Right>', { noremap = true })

-- Arrow keys work normally in normal mode
vim.keymap.set('n', '<Up>', '<Up>', { noremap = true })
vim.keymap.set('n', '<Down>', '<Down>', { noremap = true })
vim.keymap.set('n', '<Left>', '<Left>', { noremap = true })
vim.keymap.set('n', '<Right>', '<Right>', { noremap = true })

-- ============================================================================
-- SELECTION WITH SHIFT+ARROWS (VSCode-style)
-- ============================================================================

-- Shift+Arrow keys for text selection in insert mode
vim.keymap.set('i', '<S-Up>', '<Esc>v<Up>', { noremap = true })
vim.keymap.set('i', '<S-Down>', '<Esc>v<Down>', { noremap = true })
vim.keymap.set('i', '<S-Left>', '<Esc>v<Left>', { noremap = true })
vim.keymap.set('i', '<S-Right>', '<Esc>v<Right>', { noremap = true })

-- Continue selection in visual mode with Shift+Arrows
vim.keymap.set('v', '<S-Up>', '<Up>', { noremap = true })
vim.keymap.set('v', '<S-Down>', '<Down>', { noremap = true })
vim.keymap.set('v', '<S-Left>', '<Left>', { noremap = true })
vim.keymap.set('v', '<S-Right>', '<Right>', { noremap = true })

-- ============================================================================
-- BACKSPACE AND DELETE (Work Normally)
-- ============================================================================

-- Make backspace work as expected
vim.opt.backspace = 'indent,eol,start'

-- Delete key works in insert mode (already default, but ensuring)
vim.keymap.set('i', '<Del>', '<Del>', { noremap = true })

-- ============================================================================
-- MISC IMPROVEMENTS
-- ============================================================================

-- Disable swap files (to avoid annoying .swp files)
vim.opt.swapfile = false

-- Use undo file for persistent undo history
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')

-- Create undo directory if it doesn't exist
vim.fn.mkdir(vim.fn.expand('~/.config/nvim/undo'), 'p')

-- Don't show mode in command line (since we're always in insert mode)
vim.opt.showmode = false

-- Faster update time for better experience
vim.opt.updatetime = 250

-- Always show sign column (prevents text shifting)
vim.opt.signcolumn = 'yes'

-- ============================================================================
-- WELCOME MESSAGE
-- ============================================================================

-- Print a welcome message when Neovim starts
print("✓ VSCode-style config loaded | Use Ctrl+S to save, Ctrl+F to find")
