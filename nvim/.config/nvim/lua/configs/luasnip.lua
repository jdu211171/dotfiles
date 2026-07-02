local M = {}

M.vscode_snippets_path = vim.fn.stdpath "config" .. "/snippets"

function M.init()
  vim.g.vscode_snippets_path = M.vscode_snippets_path
end

return M
