return {
  -- tools
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- Ensure opts.ensure_installed is a table
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "js-debug-adapter",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "roslyn",
        "emmet-language-server",
        "svelte-language-server",
        "python-lsp-server",
      })

      -- Ensure opts.registries is a table
      opts.registries = opts.registries or {}
      vim.list_extend(opts.registries, {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      })
    end,
  },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      ---@type lspconfig.options
      servers = {
        cssls = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                extraPaths = {
                  "C:/repos/stubs/rvt/2022",
                  "C:/pyrevit/pyrevitlib",
                },
              },
            },
          },
        },
        -- omnisharp = {
        --   -- https://github.com/OmniSharp/omnisharp-roslyn/wiki/Configuration-Options
        --   settings = {
        --     FormattingOptions = {
        --       -- Enables support for reading code style, naming convention and analyzer
        --       -- settings from .editorconfig.
        --       EnableEditorConfigSupport = true,
        --       -- Specifies whether 'using' directives should be grouped and sorted during
        --       -- document formatting.
        --       OrganizeImports = true,
        --     },
        --     MsBuild = {
        --       -- If true, MSBuild project system will only load projects for files that
        --       -- were opened in the editor. This setting is useful for big C# codebases
        --       -- and allows for faster initialization of code navigation features only
        --       -- for projects that are relevant to code that is being edited. With this
        --       -- setting enabled OmniSharp may load fewer projects and may thus display
        --       -- incomplete reference lists for symbols.
        --       LoadProjectsOnDemand = false,
        --     },
        --     RoslynExtensionsOptions = {
        --       -- Enables support for roslyn analyzers, code fixes and rulesets.
        --       EnableAnalyzersSupport = true,
        --       -- Enables support for showing unimported types and unimported extension
        --       -- methods in completion lists. When committed, the appropriate using
        --       -- directive will be added at the top of the current file. This option can
        --       -- have a negative impact on initial completion responsiveness,
        --       -- particularly for the first few completion sessions after opening a
        --       -- solution.
        --       EnableImportCompletion = true,
        --       -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
        --       -- true
        --       AnalyzeOpenDocumentsOnly = false,
        --       EnableDecompilationSupport = true,
        --     },
        --     Sdk = {
        --       -- Specifies whether to include preview versions of the .NET SDK when
        --       -- determining which version to use for project loading.
        --       IncludePrereleases = true,
        --       path = os.getenv("USERPROFILE") .. "\\scoop\\apps\\dotnet-sdk\\current",
        --     },
        --     RenameOptions = {
        --       RenameInComments = false,
        --       RenameOverloads = true,
        --       RenameInStrings = false,
        --     },
        --   },
        -- },
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        tsserver = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        html = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        lua_ls = {
          -- enabled = false,
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      setup = {},
    },
  },
}
