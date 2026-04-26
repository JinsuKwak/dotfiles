def _tmux_command_spinner_config_value [key: string] {
  let config_home = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config"))
  let config_file = ($config_home | path join "tmux" "command-spinner.conf")
  let prefix = $"($key)="

  if not ($config_file | path exists) {
    return null
  }

  let matches = (
    open --raw $config_file
    | lines
    | each {|line| (($line | split row "#" | first) | str trim) }
    | where {|line| ($line | str starts-with $prefix) }
  )

  if ($matches | is-empty) {
    null
  } else {
    $matches | first | str replace $prefix "" | str trim
  }
}

def _tmux_command_spinner_enabled [] {
  let value = if "TMUX_COMMAND_SPINNER" in $env {
    $env.TMUX_COMMAND_SPINNER
  } else {
    _tmux_command_spinner_config_value "enabled" | default "1"
  }

  let value = ($value | into string | str downcase)
  not ($value in ["0" "false" "off" "no"])
}

def _tmux_command_spinner_set [value: string] {
  if (($env.TMUX_PANE? | default "") != "") {
    try { tmux set-option -pqt $env.TMUX_PANE @pane_command_spinner $value } catch {}
  } else {
    try { tmux set-option -pq @pane_command_spinner $value } catch {}
  }
}

def _tmux_command_spinner_skip [raw_line: string] {
  let command_line = ($raw_line | str trim)

  if ($command_line | is-empty) {
    return true
  }

  let first_word = ($command_line | split row --regex '\s+' | first)

  if ($first_word in [fg bg jobs cd exit clear reset]) {
    return true
  }

  let config_home = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config"))
  let excludes_file = ($config_home | path join "tmux" "command-spinner-excludes")

  if not ($excludes_file | path exists) {
    return false
  }

  for raw_pattern in (open --raw $excludes_file | lines) {
    let pattern = (($raw_pattern | split row "#" | first) | str trim)

    if ($pattern | is-empty) {
      continue
    }

    if ($pattern | str ends-with "*") {
      let prefix = ($pattern | str replace "*" "")

      if (($command_line | str starts-with $prefix) or ($first_word | str starts-with $prefix)) {
        return true
      }
    } else if (($first_word == $pattern) or ($command_line == $pattern)) {
      return true
    }
  }

  false
}

def _tmux_command_spinner_stop [] {
  if (($env._TMUX_COMMAND_SPINNER_JOB? | default "") != "") {
    try { job kill ($env._TMUX_COMMAND_SPINNER_JOB | into int) } catch {}
    $env._TMUX_COMMAND_SPINNER_JOB = ""
  }

  if (($env.TMUX? | default "") != "") and (which tmux | is-not-empty) {
    _tmux_command_spinner_set ""
  }
}

def _tmux_command_spinner_start [] {
  if (($env.TMUX? | default "") == "") {
    return
  }

  if (which tmux | is-empty) {
    return
  }

  _tmux_command_spinner_stop

  if not (_tmux_command_spinner_enabled) {
    return
  }

  let command_line = (commandline | str trim)

  if (_tmux_command_spinner_skip $command_line) {
    return
  }

  let job_id = (job spawn {
    sleep 500ms
    let frames = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]

    loop {
      for frame in $frames {
        _tmux_command_spinner_set $frame
        sleep 140ms
      }
    }
  })

  $env._TMUX_COMMAND_SPINNER_JOB = ($job_id | into string)
}

$env.config = (
  $env.config?
  | default {}
  | merge {
      show_banner: false
      history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
      }
      completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        external: {
          enable: true
          max_results: 100
          completer: null
        }
      }
      hooks: {
        pre_prompt: [
          {|| _tmux_command_spinner_stop }
          {||
            if (which direnv | is-empty) {
              return
            }
            try {
              direnv export json | from json | default {} | load-env
              if "PATH" in $env {
                $env.PATH = ($env.PATH | split row (char esep))
              }
            } catch {}
          }
        ]
        pre_execution: [{|| _tmux_command_spinner_start }]
        env_change: {
          PWD: []
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
      }
    }
)

alias v = nvim
alias vim = nvim
alias vi = nvim
alias gst = git status -sb
alias ga = git add
alias gc = git commit
alias gps = git push
alias gco = git checkout
alias gl = git log --oneline --graph --decorate -20
alias k = kubectl
alias kgp = kubectl get pods
alias kgs = kubectl get svc

source ~/.cache/zoxide/init.nu
source ~/.cache/atuin/init.nu
use ~/.cache/starship/init.nu
use ~/.cache/mise/init.nu

if (which tv | is-not-empty) and ("~/.config/television/config.toml" | path expand | path exists) {
  def tv_smart_autocomplete [] {
    let line = (commandline)
    let cursor = (commandline get-cursor)
    let lhs = ($line | str substring 0..$cursor)
    let rhs = ($line | str substring $cursor..)
    let output = (tv --no-status-bar --inline --autocomplete-prompt $lhs | str trim)

    if ($output | str length) > 0 {
      let needs_space = not ($lhs | str ends-with " ")
      let lhs_with_space = if $needs_space { $"($lhs) " } else { $lhs }
      let new_line = $lhs_with_space + $output + $rhs
      let new_cursor = ($lhs_with_space + $output | str length)
      commandline edit --replace $new_line
      commandline set-cursor $new_cursor
    }
  }

  def tv_shell_history [] {
    let current_prompt = (commandline)
    let cursor = (commandline get-cursor)
    let current_prompt = ($current_prompt | str substring 0..$cursor)
    let output = (tv nu-history --no-status-bar --inline --input $current_prompt | str trim)

    if ($output | is-not-empty) {
      commandline edit --replace $output
      commandline set-cursor --end
    }
  }

  $env.config = (
    $env.config
    | upsert keybindings (
        ($env.config.keybindings? | default [])
        | append [
            {
              name: tv_completion
              modifier: Control
              keycode: char_t
              mode: [vi_normal vi_insert emacs]
              event: {
                send: executehostcommand
                cmd: "tv_smart_autocomplete"
              }
            }
            {
              name: tv_history
              modifier: Control
              keycode: char_g
              mode: [vi_normal vi_insert emacs]
              event: {
                send: executehostcommand
                cmd: "tv_shell_history"
              }
            }
          ]
      )
  )
}
