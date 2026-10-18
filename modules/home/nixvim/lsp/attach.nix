{ ... }: {
  lsp.onAttach = "require('spreadconfig.lsp.attach')(event)";
  lsp.keymaps = [
    {
      key = "grn";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: [R]e[n]ame";
      };
      lspBufAction = "rename";
    }
    {
      key = "gra";
      mode = [
        "n"
        "x"
      ];
      options = {
        desc = "LSP: [G]oto Code [A]ction";
      };
      action = {
        __raw = "require('fzf-lua').lsp_code_actions";
      };
    }
    {
      key = "grr";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: [G]oto [R]eferences";
      };
      action = {
        __raw = "require('fzf-lua').lsp_references";
      };
    }
    {
      key = "gri";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: [G]oto [I]mplementation";
      };
      action = {
        __raw = "require('fzf-lua').lsp_implementations";
      };
    }
    {
      key = "gd";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: [G]oto [D]efinition";
      };
      action = {
        __raw = "require('fzf-lua').lsp_definitions";
      };
    }
    {
      key = "gD";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: [G]oto [D]eclaration";
      };
      action = {
        __raw = "require('fzf-lua').lsp_declarations";
      };
    }
    {
      key = "<leader>q";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: questions";
      };
      action = {
        __raw = "require('fzf-lua').diagnostics_document";
      };
    }
    {
      key = "<leader>d";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: [D]ocumentation";
      };
      lspBufAction = "hover";
    }
    {
      key = "<leader>D";
      mode = [
        "n"
      ];
      options = {
        desc = "LSP: [D]iagnos";
      };
      action = {
        __raw = "vim.diagnostic.open_float";
      };
    }
  ];
  extraFiles."lua/spreadconfig/lsp/attach.lua".source = ../lua/lsp/attach.lua;
}
