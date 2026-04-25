# mise Examples

Copy an example into a project as `mise.toml`, trust it, and install the tools.

```bash
cp ~/dotfiles/examples/mise/python-node-java.toml ./mise.toml
mise trust
mise install
mise current
```

The Starship prompt only displays active tools that are installed. If `mise ls --current` shows `(missing)`, run `mise install` or remove that tool from `mise.toml`.
