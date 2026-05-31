return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Auto-install missing parsers when entering a buffer
      opts.auto_install = true

      -- Syntax highlighting
      opts.highlight = vim.tbl_deep_extend("force", opts.highlight or {}, {
        enable = true,
      })

      -- Indentation (keep NvChad default, disable for tsx/ts which have issues)
      opts.indent = vim.tbl_deep_extend("force", opts.indent or {}, {
        enable = true,
        disable = { "tsx", "typescript" },
      })

      -- ---------------------------------------------------------------
      -- Languages commonly used in Japan's tech industry
      -- ---------------------------------------------------------------
      -- Ruby      → created by Yukihiro Matsumoto (Matz), extremely popular
      -- Vue       → dominant frontend framework in Japanese companies
      -- PHP       → widespread legacy + modern web (Laravel)
      -- TypeScript/JavaScript → ubiquitous web dev
      -- Python    → AI/data science boom + scripting
      -- Go        → fast-growing in Japanese startups & infra
      -- Java      → enterprise, Android, Spring Boot
      -- Kotlin    → modern JVM, Android dev (rapidly growing in Japan)
      -- Swift     → iOS (high iPhone penetration in Japan)
      -- C#        → Unity (Nintendo, Cygames, DeNA, Gumi…) + enterprise
      -- Rust      → systems, embedded, game engines
      -- C / C++   → game industry (Nintendo, Capcom, Konami, SEGA…)
      -- Perl      → Japan legacy web (Hatena, ISPs, older SIer systems)
      -- Lua       → Neovim config + embedded scripting (embedded is big in JP)
      -- SQL       → universal
      -- Bash      → scripting + CI/CD
      -- HTML/CSS  → frontend essentials
      -- SCSS      → common with Vue/Rails projects
      -- GraphQL   → modern API layer
      -- Proto     → gRPC / Protocol Buffers (microservices standard)
      -- HCL       → Terraform infra-as-code (de-facto in JP cloud ops)
      -- JSON/YAML → config/API ubiquitous
      -- TOML      → Cargo, Rust, modern config
      -- Markdown  → docs, README
      -- Dockerfile → containers standard everywhere
      -- ---------------------------------------------------------------
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        -- Web (frontend)
        "html",
        "css",
        "scss",
        "javascript",
        "typescript",
        "tsx",
        "vue",
        "graphql",

        -- Ruby ecosystem (huge in Japan — Rails dominates)
        "ruby",
        "embedded_template", -- ERB templates

        -- PHP ecosystem
        "php",
        "phpdoc",

        -- Python
        "python",

        -- Go
        "go",
        "gomod",
        "gosum",
        "gowork",

        -- JVM
        "java",
        "kotlin",

        -- Apple / iOS
        "swift",

        -- C# (Unity game dev — dominant engine in Japanese game industry)
        "c_sharp",

        -- Systems / game dev
        "c",
        "cpp",
        "rust",

        -- Scripting / tooling
        "lua",
        "luadoc",
        "bash",
        "perl", -- legacy web (Hatena, older SIer / ISP systems)
        "sql",

        -- Config & data formats
        "json",
        "json5",
        "jsonc",
        "yaml",
        "toml",
        "proto",      -- gRPC / Protocol Buffers
        "hcl",        -- Terraform infra-as-code
        "markdown",
        "markdown_inline",
        "dockerfile",
        "regex",

        -- Neovim / editor
        "vim",
        "vimdoc",
        "query", -- treesitter query files
      })
    end,
  },
}
