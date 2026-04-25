#!/usr/bin/env sh

command -v mise >/dev/null 2>&1 || exit 0

mise ls --current 2>/dev/null | awk '
function icon(tool) {
  if (tool == "python") return " "
  if (tool == "node" || tool == "nodejs") return " "
  if (tool == "bun") return " "
  if (tool == "deno") return " "
  if (tool == "ruby") return " "
  if (tool == "go" || tool == "golang") return " "
  if (tool == "java") return " "
  if (tool == "rust") return " "
  if (tool == "lua") return " "
  if (tool == "php") return " "
  if (tool == "elixir") return " "
  if (tool == "erlang") return " "
  if (tool == "dart") return " "
  if (tool == "dotnet") return ".NET "
  if (tool == "swift") return " "
  if (tool == "kotlin") return " "
  if (tool == "terraform") return " "
  if (tool == "zig") return " "
  if (tool == "julia") return " "
  if (tool == "rlang" || tool == "r") return "󰟔 "
  if (tool == "scala") return " "
  if (tool == "haskell") return " "
  return ""
}

function version_text(first,    text) {
  text = first
  if (text !~ /^v/ && text ~ /^[0-9]/) text = "v" text
  return text
}

NR == 1 && $1 == "Tool" {
  next
}

$0 ~ /\(missing\)/ {
  next
}

NF >= 2 {
  glyph = icon($1)
  if (glyph == "") next
  printf "%s%s ", glyph, version_text($2)
  printed = 1
}

END {
  if (printed) printf "\n"
}
'
