if "XDG_CACHE_HOME" not-in $env {
  $env.XDG_CACHE_HOME = ($env.HOME | path join ".cache")
}
if "XDG_CONFIG_HOME" not-in $env {
  $env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
}
if "XDG_DATA_HOME" not-in $env {
  $env.XDG_DATA_HOME = ($env.HOME | path join ".local" "share")
}
if "XDG_STATE_HOME" not-in $env {
  $env.XDG_STATE_HOME = ($env.HOME | path join ".local" "state")
}

use std "path add"
path add "/opt/homebrew/bin"
path add "/opt/homebrew/sbin"
path add ($env.HOME | path join ".local" "bin")
path add ($env.XDG_DATA_HOME | path join "mise" "shims")

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.PAGER = "less -FRX"
$env.STARSHIP_CONFIG = ($env.XDG_CONFIG_HOME | path join "starship" "starship.toml")
$env.DIRENV_LOG_FORMAT = ""

mkdir ~/.cache/starship
mkdir ~/.cache/mise
mkdir ~/.cache/zoxide
mkdir ~/.cache/atuin

if (which starship | is-not-empty) {
  starship init nu | save --force ~/.cache/starship/init.nu
}

if (which mise | is-not-empty) {
  ^mise activate nu | save --force ~/.cache/mise/init.nu
}

if (which zoxide | is-not-empty) {
  zoxide init nushell | save --force ~/.cache/zoxide/init.nu
}

if (which atuin | is-not-empty) {
  atuin init nu | save --force ~/.cache/atuin/init.nu
}
