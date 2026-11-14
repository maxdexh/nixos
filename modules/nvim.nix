{
  # TODO: Build nvim config as part of system, or bootstrap an init.lua
  # to clone it.
  parts.nvim = {
    enableIf.tags.basic = true;

    hm = {
      inputs,
      host,
      pkgs,
      ...
    }: {
      home.packages = with pkgs; [
        tree-sitter
        nixd
      ];
      # home.sessionPath = ["${config.xdg.dataHome}/bob/nvim-bin"];

      custom.sessionVars = {
        VISUAL = "nvim";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";

        # For nixd (see nvim config)
        NVIM_NIX_HOST_NAME = host.name;
        NVIM_NIX_IS_NIXOS = toString host.nixos.enable;
      };

      xdg.configFile."nvim/init.lua".text = let
        configLib = "${
          inputs.nvim-config.packages.${pkgs.stdenv.hostPlatform.system}.config-lib
        }";
      in
        if host.bootstrapNvim
        # lua
        then ''
          local bstrap_dir = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "bootstrap")

          if not vim.uv.fs_stat(bstrap_dir) then
            local out = vim.system({
              "git",
              "clone",
              "https://github.com/maxdexh/nvim-config.git",
              bstrap_dir,
            }):wait()
            if out.code ~= 0 then
              vim.api.nvim_echo({
                { "Failed to clone bootstrap config\n", "ErrorMsg" },
                { out.stderr or "", "WarningMsg" },
                { "\nPress any key to exit..." },
              }, true, {})
              vim.fn.getchar()
              os.exit(1)
            end
          end

          vim.opt.rtp:prepend(bstrap_dir)
          require("bootstrap.enter").enter_auto_build("${configLib}", bstrap_dir)
        ''
        # lua
        else ''
          require("bootstrap.enter").enter_fixed("${configLib}")
        '';
    };
  };
}
