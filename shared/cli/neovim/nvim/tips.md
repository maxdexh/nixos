## Vim Motions
- `ci"` to cut contents of `"..."`
- `%` jump matching delimiter
- Jump to next/previous occurence of string
  - `f<char>`/`F<char>` jump to next/previous occurence of character
  - `;`/`,` to search for currently hovered character, i.e. to repeat after `f`/`F`
  - `?<str><CR>`
- `set setting?` will show the value of a setting

## Utility Keybinds / Commands
- `<C-/>` (insert), `?` (normal) for telescope browser which-key, insert mode mapping is normal with ctrl instead of `/`
  - https://github.com/nvim-telescope/telescope-file-browser.nvim?tab=readme-ov-file#mappings
- `<leader>,` for Buffer grep
- `<leader>?` Buffer keymaps via which-key
- `<leader>|` vertical split, `<leader>w` for more utils
- `<leader>g` git
- `<leader>c` and `<leader>x` for code-related stuff
- `<leader>s` search literally anything, but also find and replace
  - `<leader>sj` search jumplist
  - `<leader>sC` search commands
  - `<leader>sk` search keybinds
  - `<leader>sg` grep
- `<leader><Tab>` tab-related stuff
- `:verbose map ` to search for keybinds starting with input
- `<leader>u` for ui stuff, like `<leader>uh` to toggle inlay hints
