return {
  "Exafunction/codeium.vim",
  lazy = false,
  init = function()
    vim.g.codeium_disable_bindings = 1
  end,
  config = function()
    vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true })
    vim.keymap.set('i', '<C-r>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
    vim.keymap.set('i', '<C-R>', function() return vim.fn['codeium#CycleCompletions']( -1) end, { expr = true })
    vim.keymap.set('i', '<C-c>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    vim.api.nvim_set_hl(0, "CodeiumSuggestion", { link = "Comment" })
  end,
}
