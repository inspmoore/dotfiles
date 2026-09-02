# Migrating to a new Mac

Follow these in order. Phases 0-2 are prerequisites; the dotfiles themselves
land in Phase 3.

> The `chezmoi apply` on a fully set-up machine is a **no-op** - it never
> removes apps and never overwrites local edits it hasn't captured. If you
> edit a config directly, run `chezmoi re-add <file>` to pull it back into
> the repo *before* the next apply.

---

## Phase 0 - system prerequisites

```sh
xcode-select --install                       # wait for it to finish
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"    # brew onto PATH for this shell
```

## Phase 1 - apps

Third-party taps first (19):

```sh
for t in \
  anomalyco/tap browsh-org/browsh cormacrelf/tap \
  dracula/install dwarvesf/tap facebook/fb \
  felixkratz/formulae gcenx/wine microsoft/git \
  mobile-dev-inc/tap ngrok/ngrok nikitabobko/tap \
  oven-sh/bun samtay/tui sikarugir-app/sikarugir \
  sst/tap teamookla/speedtest vldmrkl/formulae \
  withgraphite/tap; do brew tap "$t"; done
```

Formulae - `brew leaves`, i.e. things you explicitly installed (70).
Homebrew resolves the ~205 dependencies itself:

```sh
brew install \
  actionlint aerc atuin awscli \
  btop chawan chezmoi cocoapods \
  cpulimit deno fd felinks \
  felixkratz/formulae/borders fff ffmpegthumbnailer fnm \
  fzf gcalcli gemini-cli gh \
  glow gnirehtet go helix \
  imagemagick ios-deploy jless jq \
  lazydocker lazygit llama.cpp lsusb \
  lynx mkcert mono newsboat \
  openjdk@17 openvino pandoc perl \
  pinentry-mac pipx poppler postgresql@16 \
  pyenv-virtualenv python@3.12 qrcp qrencode \
  ranger rbenv ripgrep sc-im \
  sevenzip stow task thefuck \
  tmux trash unar w3m \
  walk watchman websocat yarn \
  yazi yq yt-dlp zellij \
  zlib zoxide
```

Casks (31), plus `font-jetbrains-mono` which your ghostty config
needs but which was only ever installed manually on the old Mac:

```sh
brew install --cask \
  1password-cli aerospace amethyst deskreen \
  docker docker-desktop dracula-xcode flipper \
  font-fira-code font-hack-nerd-font font-monaspace font-symbols-only-nerd-font \
  ghostty git-credential-manager git-credential-manager-core hammerspoon \
  iina kegworks localsend neovide \
  neovide-app ngrok orbstack qlmarkdown \
  reactotron stolendata-mpv warp wezterm \
  wineskin zulu11 zulu@11 \
  font-jetbrains-mono
```

## Phase 2 - node + Claude Code

The dotfiles' bootstrap scripts need `claude` and `npx` on PATH. They skip
gracefully if missing, so install these *before* Phase 3 or you will have to
re-run them afterwards.

```sh
brew install fnm && fnm install --lts && fnm use lts-latest
curl -fsSL https://claude.ai/install.sh | bash      # native installer
npm install -g agent-device typescript typescript-language-server
```

## Phase 3 - dotfiles

The repo is public, so clone over HTTPS. Do **not** use the
`git@github.com-personal:` URL here - that alias is defined in `~/.ssh/config`,
which is not synced, so it does not exist yet on a fresh machine.

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/inspmoore/dotfiles.git
```

This clones the repo, applies every dotfile, and runs the bootstrap scripts:
marketplaces + plugins, user-scope MCP servers, and third-party agent skills.

## Phase 4 - verify

```sh
chezmoi status            # expect no M/D rows
chezmoi diff              # expect empty
claude plugin list
claude mcp list
ls ~/.claude/skills
```

## Phase 5 - the manual leftovers

Nothing below is synced, by design. Each one is a silent failure if skipped.

1. **SSH keys.** Generate fresh rather than copying private keys, then add the
   public key to GitHub:
   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal
   ```
   Then recreate `~/.ssh/config` (not in the repo - it is public):
   ```
   Host github.com-personal
     HostName github.com
     User git
     IdentityFile ~/.ssh/id_ed25519_personal
     IdentitiesOnly yes
   ```
   Then switch the dotfiles remote back to SSH if you want push access:
   ```sh
   chezmoi cd && git remote set-url origin git@github.com-personal:inspmoore/dotfiles.git
   ```

2. **`~/.config/zsh/zsh-secrets`.** Excluded from git on purpose. Recreate it
   by hand. `GEMINI_API_KEY` is the one that is actually still in use.
   `zsh_add_file` sources it only `[ -f ]`, so a missing file fails silently.

3. **SDKMAN**, if you still want it - `~/.zshrc` sources it but it is not
   brew-installable:
   ```sh
   curl -s "https://get.sdkman.io" | bash
   ```

4. **GUI app logins** - 1Password, Docker/OrbStack, Hammerspoon and Karabiner
   accessibility permissions (System Settings -> Privacy & Security).

---

## Known gaps

- App installation in Phase 1 is **manual**. A `Brewfile` + `brew bundle` would
  collapse it to one command; designed but not yet built.
- `~/.ssh` is deliberately unmanaged because this repo is public.
- The Phase 1 list reproduces the old Mac exactly, including some duplicates
  worth pruning: `neovide` + `neovide-app`, `zulu11` + `zulu@11`,
  `git-credential-manager` + `-core`, three container runtimes
  (docker / docker-desktop / orbstack) and three terminals
  (ghostty / warp / wezterm, though only ghostty is configured).
