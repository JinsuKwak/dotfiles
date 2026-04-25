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
        pre_prompt: [{||
          if (which direnv | is-empty) {
            return
          }
          try {
            direnv export json | from json | default {} | load-env
            if "PATH" in $env {
              $env.PATH = ($env.PATH | split row (char esep))
            }
          } catch {}
        }]
        pre_execution: [{ null }]
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
