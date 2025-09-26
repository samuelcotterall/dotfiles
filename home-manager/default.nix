{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./git.nix
    inputs._1password-shell-plugins.hmModules.default
  ];

  nixpkgs.config.allowUnfree = true;

  home = {

    username = "samuelcotterall";
    homeDirectory = "/Users/samuelcotterall";
    stateVersion = "24.05"; # Please read the comment before changing.

    packages = with pkgs; [
      starship
      zsh-history-substring-search
      pyenv
      zsh-autosuggestions
      zsh-syntax-highlighting
      fzf
      zoxide
      direnv
      gitleaks
      pre-commit
      nodejs_22
      mkcert
      cmake
      gh
      yarn
      _1password-cli
  pipx
  pkgs.python3
    ];
  };

  # Provide a managed fallback docker completion so new shells always have
  # something to source even if the Docker CLI isn't available at activation.
  # The runtime updater in `programs.zsh.initExtra` will replace this stub
  # atomically when a real `docker completion zsh` is available.
  home.file = {
  ".local/share/zsh/site-functions/_docker".text = ''
    # Home Manager managed stub for docker completion
    # If the real Docker CLI is available the runtime updater will replace this
    # file with the full completion script; this stub gives a minimal useful
    # fallback to avoid missing completion errors.
    _docker() {
      compadd build run compose ps images pull push exec logs start stop rm rmi
    }
    compdef _docker docker
    '';
      ".zshenv".text = ''
    # Prepend the user site-functions directory to fpath early so compinit can
    # autoload completions managed by Home Manager (e.g. _docker). This runs for
    # all zsh shells before other init files.
      fpath=("$HOME/.local/share/zsh/site-functions" $fpath)
      # Ensure user-local bin is in PATH early so user-installed npm global
      # packages (prefix ~/.local) are found before system/nix paths.
      export PATH="$HOME/.local/bin:$PATH"
    '';
    ".npmrc".text = ''
      # Use a user-local npm prefix so `npm install -g` writes to ~/.local and
      # doesn't try to modify the read-only Nix store.
      prefix = ~/.local
    '';
  };


  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };
  programs.home-manager.enable = true;

  programs.zsh = {
      enable = true;
      sessionVariables = {
        OP_PLUGIN_ALIASES_SOURCED = 1;
        GITHUB_TOKEN = "op://Private/Github/token";
        PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:$PATH";
      };

      shellAliases = {
        gh = "op plugin run -- gh";
        h2 = "$(npm prefix -s)/node_modules/.bin/shopify hydrogen";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };
      initExtra = ''
        setopt completealiases
        eval "$(starship init zsh)"
        # Add Homebrew to PATH
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

        # fzf keybindings and completion
        [ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ] && source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        [ -f ${pkgs.fzf}/share/fzf/completion.zsh ] && source ${pkgs.fzf}/share/fzf/completion.zsh

        # zsh-autosuggestions (provide inline suggestions from history)
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

        # zsh-history-substring-search (up/down to search history by substring)
        source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down

        # zoxide (fast directory jumping)
        if [ -x "${pkgs.zoxide}/bin/zoxide" ]; then
          eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
        fi

        # direnv (project env management)
        if [ -x "${pkgs.direnv}/bin/direnv" ]; then
          eval "$( ${pkgs.direnv}/bin/direnv hook zsh )"
        fi

        # Initialize pyenv
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        if command -v pyenv 1>/dev/null 2>&1; then
          eval "$(pyenv init -)"
        fi

        # Ensure pipx is available and use it to install `uv` (astral-sh/uv).
        # This keeps the uv CLI isolated from global pip and makes it available
        # for the active Python (pyenv shims / Homebrew python).
        PIPX_BIN="${pkgs.pipx}/bin/pipx"
        # prefer the packaged pipx, fall back to any pipx on PATH
        if [ ! -x "$PIPX_BIN" ]; then
          PIPX_BIN="$(command -v pipx 2>/dev/null || true)"
        fi
        if [ -n "$PIPX_BIN" ]; then
          # ensure user-local bin is in PATH so pipx-installed apps are found
          export PATH="$HOME/.local/bin:$PATH"
          # make sure pipx has its path set up
          "$PIPX_BIN" ensurepath >/dev/null 2>&1 || true
          # install or upgrade uv idempotently
          if ! command -v uv >/dev/null 2>&1; then
            "$PIPX_BIN" install uv >/dev/null 2>&1 || "$PIPX_BIN" upgrade uv >/dev/null 2>&1 || true
          else
            # if uv exists but is older, attempt an upgrade quietly
            "$PIPX_BIN" upgrade uv >/dev/null 2>&1 || true
          fi
        fi

        # Docker CLI zsh completion: ensure site-functions dir is in fpath
        ZSH_SITE_FUNCS="$HOME/.local/share/zsh/site-functions"
        mkdir -p "$ZSH_SITE_FUNCS"
        fpath=("$ZSH_SITE_FUNCS" $fpath)

        # Safe updater: if the real `docker` CLI is available, generate a
        # temporary completion file and atomically replace the managed file
        # only when different. This avoids slowing every shell startup and
        # keeps the activation-time managed stub as the authoritative source.
        if command -v docker >/dev/null 2>&1; then
          # If the completion file is a symlink (managed by home-manager/Nix),
          # don't try to overwrite it from shell startup — that can trigger an
          # interactive "override" prompt. Only update when the target is a
          # regular file owned/writable by the user.
          if [ -L "$ZSH_SITE_FUNCS/_docker" ]; then
            : # skip updater for home-managed symlink
          else
            TMPFILE="$ZSH_SITE_FUNCS/_docker.tmp"
            if docker completion zsh > "$TMPFILE" 2>/dev/null; then
              if [ ! -f "$ZSH_SITE_FUNCS/_docker" ] || ! cmp -s "$TMPFILE" "$ZSH_SITE_FUNCS/_docker"; then
                mv -f "$TMPFILE" "$ZSH_SITE_FUNCS/_docker"
              else
                rm -f "$TMPFILE"
              fi
            fi
          fi
        fi

        # Ensure completion system is initialized so new completions are picked up
        autoload -Uz compinit
        compinit -u

        # zsh-syntax-highlighting should be sourced last
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        clear
      '';
    };

}
