-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    "codegirl-007/code-standards",
    config = function()
      require("code-improver").setup({
        -- Required: Your Anthropic API key
        api_key = os.getenv("ANTHROPIC_API_KEY"),
        
        -- Path to standards folder (relative to current working directory)
        standards_folder = "./docs/standards/",
        
        -- Claude model to use (default: "claude-3-5-sonnet-20241022")
        model = "claude-sonnet-4-20250514",
        
        -- Maximum tokens for Claude response (default: 4096)
        max_tokens = 4096,
        
        -- Split window position: "right", "left", "above", "below" (default: "right")
        split_position = "right",
        
        -- Split window size (width for vertical, height for horizontal)
        -- nil = use default (50%)
        split_size = nil,
      })
    end,
  },
}
