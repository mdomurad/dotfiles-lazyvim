local user = os.getenv("USERNAME")

local function echoCommitInfo(response)
  -- Get the list of files in the last commit
  local committedFiles = io.popen("git log -1 --name-only"):read("*all")
  vim.api.nvim_echo({ { "Commit message: " .. response, "HighlightGroup" } }, true, {})
  vim.api.nvim_echo({ { "Files in the last commit:\n" .. committedFiles, "HighlightGroup" } }, true, {})
end

local function formatGitResponse(response)
  -- Split the response into lines
  local lines = {}
  for s in response:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end

  -- Construct the git commit command with the first line as a separate -m argument and the rest as another -m argument
  local commitCmd = "git commit"
  if #lines > 0 then
    commitCmd = commitCmd .. ' -m "' .. lines[1] .. '"'
    table.remove(lines, 1)
  end
  if #lines > 0 then
    commitCmd = commitCmd .. ' -m "' .. table.concat(lines, " ") .. '"'
  end

  -- Execute the git commit command
  os.execute(commitCmd)
end

-- [ chatGPT ]
local chatGPT = {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      actions_paths = { "chatGPTactions.json" },
      openai_params = {
        model = "gpt-4o-mini",
      },
      openai_edit_params = {
        model = "gpt-4o-mini",
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}

-- [Minuet-ai]
local minuet_ai = {
  "milanglacier/minuet-ai.nvim",
  priority = 1000,
  config = function()
    require("minuet").setup({
      -- virtualtext = {
      --   auto_trigger_ft = {},
      --   keymap = {
      --     -- accept whole completion
      --     accept = "<A-A>",
      --     -- accept one line
      --     accept_line = "<A-a>",
      --     -- accept n lines (prompts for number)
      --     -- e.g. "A-z 2 CR" will accept 2 lines
      --     accept_n_lines = "<A-z>",
      --     -- Cycle to prev completion item, or manually invoke completion
      --     prev = "<A-[>",
      --     -- Cycle to next completion item, or manually invoke completion
      --     next = "<A-]>",
      --     dismiss = "<A-e>",
      --   },
      -- },
      provider_options = {
        openai = {
          model = "gpt-4o-mini",
          system = "see [Prompt] section for the default value",
          few_shots = "see [Prompt] section for the default value",
          chat_input = "See [Prompt Section for default value]",
          stream = true,
          api_key = "OPENAI_API_KEY",
          optional = {
            stop = { "end" },
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },
    })
  end,
}

local kind_icons = {
  -- LLM Provider icons
  claude = "󰋦",
  openai = "󱢆",
  codestral = "󱎥",
  gemini = "",
  Groq = "",
  Openrouter = "󱂇",
  Ollama = "󰳆",
  ["Llama.cpp"] = "󰳆",
  Deepseek = "",
}

-- [ Blink-cmp ]
-- configuration for minuet
if user == "ianus" then
  require("blink-cmp").setup({
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "normal",
      kind_icons = kind_icons,
    },
    -- keymap = {
    -- Manually invoke minuet completion.
    --   ["<A-y>"] = require("minuet").make_blink_map(),
    -- },
    sources = {
      -- Enable minuet for autocomplete
      default = { "lsp", "path", "buffer", "snippets", "minuet" },
      -- For manual completion only, remove 'minuet' from default
      providers = {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          score_offset = 8, -- Gives minuet higher priority among suggestions
        },
      },
    },
    -- Recommended to avoid unnecessary request
    completion = { trigger = { prefetch_on_insert = false } },
  })
end

-- [ Avante ]

local avanteProvider = user == "ianus" and "claude" or "copilot"

local avantePlugin = {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = {
    -- add any opts here
    -- for example
    provider = avanteProvider,
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false", -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

-- Copilot
local copilotVim = {
  "github/copilot.vim",
}

local copilotChat = {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
    { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
  },
  opts = {
    debug = true, -- Enable debugging
    window = {
      layout = "float",
      relative = "editor",
      width = 0.8,
      height = 0.6,
    },
    mappings = {
      complete = {
        insert = "<C-z>",
      },
    },
    prompts = {
      FixGrammar = {
        prompt = "/COPILOT_GENERATE Rewrite text to improve clarity and style. Fix all grammar and spelling mistakes. Use language of the original text. Remove line numbers.",
        description = "Fix spelling and grammar",
        mapping = "<leader>tg",
        close = true,
        selection = function(source)
          local select = require("CopilotChat.select")
          return select.visual(source) or select.line(source)
        end,
      },
      FullCommit = {
        prompt = "> #git:staged\n#git:unstaged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Do not add any surrounding quotes.",
        description = "Stage all and commit",
        mapping = ";C",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")
          vim.schedule(function()
            os.execute("git add -A")
            formatGitResponse(response)

            copilot.close()
            echoCommitInfo(response)
          end)
        end,
      },
      FullCommitStaged = {
        prompt = "> #git:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Do not add any surrounding quotes.",
        description = "Commit staged",
        mapping = ";c",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")

          vim.schedule(function()
            formatGitResponse(response)
            copilot.close()
            echoCommitInfo(response)
          end)
        end,
      },
      QuickCommit = {
        prompt = "> #git:staged\n#git:unstaged\n\nWrite commit title for the change with commitizen convention. Provide information about scope of the change. If only one file was updated provide its name. Make sure the title has maximum 50 characters. Do not add any surrounding quotes.",
        description = "Stage all and commit with title only",
        mapping = ";Q",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")

          vim.schedule(function()
            os.execute("git add -A")
            os.execute('git commit -m "' .. response .. '"')
            copilot.close()
            echoCommitInfo(response)
          end)
        end,
      },
      QuickCommitStaged = {
        prompt = "> #git:staged\n\nWrite commit title for the change with commitizen convention. Provide information about scope of the change. If only one file was updated provide its name. Make sure the title has maximum 50 characters. Do not add any surrounding quotes.",
        description = "Commit staged with title only",
        mapping = ";q",
        close = true,
        callback = function(response)
          local copilot = require("CopilotChat")
          vim.schedule(function()
            os.execute('git commit -m "' .. response .. '"')

            copilot.close()
            echoCommitInfo(response)
          end)
        end,
      },
    },
  },
}
-- See Commands section for default commands if you want to lazy load on them

local enabledPlugins = user == "ianus" and { avantePlugin, chatGPT, minuet_ai }
  or { avantePlugin, copilotChat, copilotVim }

return enabledPlugins
