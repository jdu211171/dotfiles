return {
  {
    "antosha417/nvim-lsp-file-operations",
    lazy = false, -- ensure it loads early so explorer integrations are registered
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- integrates with file explorers like nvim-tree to trigger LSP rename events
      "nvim-tree/nvim-tree.lua",
    },
    config = function()
      require("lsp-file-operations").setup({
        -- set to true temporarily if you want verbose logs in :messages
        debug = false,
      })

      -- After a successful rename, silently write any modified file buffers.
      -- This avoids a flurry of unsaved buffers created by workspace edits
      -- (e.g. TypeScript import updates).
      local ok_api, api = pcall(require, "nvim-tree.api")
      if ok_api then
        local Event = api.events.Event
        api.events.subscribe(Event.NodeRenamed, function()
          vim.schedule(function()
            if vim.g.lsp_fileops_autowrite == false then return end
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf)
                and vim.api.nvim_get_option_value("modified", { buf = buf })
                and vim.api.nvim_buf_get_name(buf) ~= ""
                and vim.bo[buf].buftype == ""
                and vim.bo[buf].modifiable
                and not vim.bo[buf].readonly
              then
                pcall(vim.api.nvim_buf_call, buf, function()
                  vim.cmd("silent noautocmd write")
                end)
              end
            end
          end)
        end)
      end
    end,
  },
}
