-- Molten configuration
vim.g.molten_image_provider = "none"  -- Change to "none" if image.nvim fails
vim.g.molten_output_win_max_height = 20
vim.g.molten_auto_open_output = true
vim.g.molten_output_win_hide_on_leave = true
vim.g.molten_output_win_style = "minimal"
vim.g.molten_output_win_border = "single"
vim.g.molten_output_crop_border = true
vim.g.molten_virt_text_output = true
vim.g.molten_virt_lines_off_by_1 = true
vim.g.molten_virt_text_max_lines = 5
vim.g.molten_wrap_output = true
vim.g.molten_output_show_more = true
vim.g.molten_use_border_highlights = true
vim.g.molten_auto_init_behavior = "init"
vim.g.molten_enter_output_behavior = "open_and_enter"
vim.g.molten_auto_image_popup = false
vim.g.molten_tick_rate = 150

-- Check if image.nvim is available
local ok, _ = pcall(require, "image")
if ok then
  vim.g.molten_image_provider = "image.nvim"
end

