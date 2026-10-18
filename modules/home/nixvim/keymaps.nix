{ ... }: {
  keymaps = [
    {
      action = "$";
      key = "'";
      mode = [
        "n"
        "v"
      ];
    }
    {
      action = "<CMD>nohlsearch<CR>";
      key = "<Esc>";
      mode = "n";
    }
    {
      action = "<C-w><C-h>";
      key = "<C-h>";
      mode = "n";
    }
    {
      action = "<C-w><C-l>";
      key = "<C-l>";
      mode = "n";
    }
    {
      action = "<C-w><C-j>";
      key = "<C-j>";
      mode = "n";
    }
    {
      action = "<C-w><C-k>";
      key = "<C-k>";
      mode = "n";
    }
    {
      action = "<C-o>";
      key = "gk";
      mode = "n";
      options = {
        desc = "go back";
        noremap = true;
      };
    }
    {
      action = "<C-i>";
      key = "gj";
      mode = "n";
      options = {
        desc = "go forward";
        noremap = true;
      };
    }
    {
      action = "\"\"y/\\V<C-R>=escape(@\", '/\\')<CR><CR>";
      key = "/";
      mode = "v";
      options = {
        desc = "Search Visual Selection";
      };
    }
    {
      action = "<CMD>Oil<CR>";
      key = "<leader>fs";
      mode = "n";
      options = {
        desc = "File System";
      };
    }
    {
      action = "<CMD>tabnew<CR><CMD>Oil<CR>";
      key = "<leader>nt";
      mode = "n";
      options = {
        desc = "New Tab";
      };
    }
    {
      action = "<CMD>LazyGit<CR>";
      key = "<leader>lg";
      mode = "n";
      options = {
        desc = "LazyGit";
      };
    }
    {
      action = {
        __raw = "function()\n    require('flash').jump()\nend\n";
      };
      key = "<leader>;";
      mode = "n";
      options = {
        desc = "Jump Code";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').files()\nend\n";
      };
      key = "<leader>ff";
      mode = "n";
      options = {
        desc = "Find Files";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').buffers()\nend\n";
      };
      key = "<leader>ge";
      mode = "n";
      options = {
        desc = "Find Buffers";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').oldfiles()\nend\n";
      };
      key = "<leader>fh";
      mode = "n";
      options = {
        desc = "Find History";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').tabs()\nend\n";
      };
      key = "<leader>ft";
      mode = "n";
      options = {
        desc = "Find Tab";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').keymaps()\nend\n";
      };
      key = "<leader>fk";
      mode = "n";
      options = {
        desc = "Find Keymaps";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').live_grep({ resume = true })\nend\n";
      };
      key = "<leader>fe";
      mode = "n";
      options = {
        desc = "Find Everything";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').helptags()\nend\n";
      };
      key = "<leader>?";
      mode = "n";
      options = {
        desc = "Find Helps";
      };
    }
    {
      action = {
        __raw = "function()\n    require('fzf-lua').grep_visual()\nend\n";
      };
      key = "<leader>fe";
      mode = "v";
      options = {
        desc = "Find Under Cursor";
      };
    }
    {
      action = "<CMD>ToggleTerm<CR>";
      key = "<leader>tt";
      mode = "n";
      options = {
        desc = "Toggle Term";
        noremap = true;
      };
    }
    {
      action = "<CMD>Outline<CR>";
      key = "<leader>ot";
      mode = "n";
      options = {
        desc = "Toggle Outline";
        noremap = true;
      };
    }
    {
      action = "<CMD>OutlineFocus<CR>";
      key = "<leader>of";
      mode = "n";
      options = {
        desc = "Focus Outline";
        noremap = true;
      };
    }
    {
      action = "<CMD>set wrap!<CR>";
      key = "<leader>sw";
      mode = "n";
      options = {
        desc = "Toggle Wrap";
        noremap = true;
      };
    }
    {
      action = {
        __raw = "function()\n  vim.cmd.packadd(\"nvim.undotree\")\n  require(\"undotree\").open()\nend\n";
      };
      key = "<leader>u";
      mode = "n";
      options = {
        desc = "Toggle Builtin Undotree";
        noremap = true;
      };
    }
  ];
}
