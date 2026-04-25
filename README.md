# Jinsuk Dotfiles

새 맥에서도 바로 다시 올릴 수 있게, `stow` 기준으로 최소 구성만 남긴 개인용 dotfiles입니다.

## 선택한 스택

- Terminal: Ghostty
- Shell: zsh 또는 nushell + starship
- Runtime manager: mise
- Editor: LazyVim
- Terminal tools: tmux, zoxide, atuin, eza, bat, fd, ripgrep, jq, yq, lazygit
- Optional TUI: Television (`tv`)

## 셸 구조

`zsh`를 고르면:
: `~/.zshenv`, `~/.config/zsh/.zprofile`, `~/.config/zsh/.zshrc` 구조를 씁니다.

`nushell`을 고르면:
: `~/.config/nushell/env.nu`, `~/.config/nushell/config.nu` 구조를 씁니다.

`setup.sh`가 처음에 셸을 먼저 고르게 하고, 이후 설치와 링크도 그 셸에 맞춰 나눕니다. 기본값은 `zsh`입니다.

## 이번에 뺀 것

- `autojump`: `zoxide`가 더 낫고 관리도 단순합니다.
- `pyenv`, `fnm`: `mise` 하나로 합칩니다.
- `wezterm`, `kitty`, `alacritty`: 메인 터미널을 Ghostty로 고정합니다.
- `btop`, `fastfetch`: 예쁘긴 하지만 필수는 아닙니다.
- `k9s`: Kubernetes를 매일 깊게 보지 않으면 일단 보류해도 됩니다.

## 설치

```bash
cd ~/dotfiles
./setup.sh
```

셸까지 바로 지정하고 싶으면:

```bash
./setup.sh --shell zsh
./setup.sh --shell nu
```

`tv`를 바로 포함하고 싶으면:

```bash
./setup.sh --shell zsh --with-tv
./setup.sh --shell nu --with-tv
```

`tv`를 빼고 싶으면:

```bash
./setup.sh --shell zsh --without-tv
./setup.sh --shell nu --without-tv
```

`setup.sh`는 아래를 수행합니다.

1. `zsh`와 `nu` 중 셸 프로필을 먼저 고릅니다. 기본값은 `zsh`입니다.
2. `brew bundle`로 공통 패키지와 셸별 패키지를 설치합니다.
3. GUI 앱은 기본 Homebrew 위치인 `/Applications`에 설치합니다.
4. `tv`는 설치 시 사용자 입력을 받아 포함/제외를 나눕니다.
5. `stow`로 선택된 셸 설정만 홈 디렉터리에 심볼릭 링크를 겁니다.

## Theme

공통 배경/색/알약 스타일은 `theme/theme.toml` 하나에서 관리합니다. 앱별 설정에 색상값을 직접 복붙하지 않고, `sets.<name>`에 있는 `background`, `foreground`, `primary`, `secondary`, `accent`, `surface` 같은 token 이름을 참조합니다.

- `ghostty`: 배경색, opacity, blur, 폰트
- `tmux`: session/window/directory/time pill을 token 색으로 생성
- `tv`: 배경색
- `nvim`: colorscheme와 투명 배경 여부
- `sets.*`: 실제 컬러 세트

수정 후에는:

```bash
cd ~/dotfiles
python3 scripts/apply_theme.py
tmux source-file ~/.config/tmux/tmux.conf
```

컬러 세트는 이렇게 씁니다.

```bash
python3 scripts/apply_theme.py --list
python3 scripts/apply_theme.py --set tokyonight
python3 scripts/apply_theme.py --set storm
python3 scripts/apply_theme.py --set moon
python3 scripts/apply_theme.py --set mocha
python3 scripts/apply_theme.py --reset
```

- `--set NAME`: `active_set`만 바꾸고 Ghostty/tmux/tv/nvim 설정을 다시 생성합니다.
- `--reset`: `default_set`으로 복구합니다.
- 새 테마를 만들 때는 `theme/theme.toml`에 `[sets.my-theme]`만 추가하면 됩니다.
- tmux의 active window pill 오른쪽 값은 `현재 pane 번호/현재 window의 전체 pane 수`입니다.

Ghostty는 이 스크립트가 백그라운드에서 감시하지 않습니다. 테마 생성 스크립트는 실행 후 바로 종료되고, Ghostty는 다음 실행 시 설정을 읽거나 `cmd+shift+,`로 수동 reload 했을 때만 다시 읽습니다.

## 런타임 버전 관리

전역 기본값을 강하게 박지 않고, 프로젝트마다 `mise.toml` 또는 `.tool-versions`로 버전을 고정하는 쪽을 추천합니다.

예시:

```toml
[tools]
node = "22"
python = "3.12"
```

## 포함된 패키지

- `zsh/`: `~/.zshenv`, `~/.config/zsh/.zprofile`, `~/.config/zsh/.zshrc`
- `nushell/`: `~/.config/nushell/env.nu`, `~/.config/nushell/config.nu`
- `ghostty/`: `~/.config/ghostty/config`
- `starship/`: `~/.config/starship/starship.toml`
- `tmux/`: `~/.config/tmux/tmux.conf`
- `nvim/`: `~/.config/nvim/*`
- `television/`: 선택 시 `~/.config/television/*`
- `television-nu/`: `nu` 선택 시에만 `nu-history` 채널 추가

## Tmux

tmux는 원본 레포 방향을 따라 TPM + Catppuccin + SessionX + Floax 기준으로 구성했습니다.

- `prefix`: `Ctrl-A`
- `prefix + I`: TPM 플러그인 설치/갱신
- `prefix + o`: SessionX 세션 picker
- `prefix + p`: Floax floating pane

`setup.sh`는 TPM이 없으면 같이 설치하고, 가능한 경우 플러그인도 바로 받아옵니다.
플러그인은 repo 안이 아니라 `~/.local/share/tmux/plugins`에 설치되도록 분리했습니다.

자세한 키맵과 추천 window 구조는 [KEYMAPS.md](KEYMAPS.md)를 봅니다.

## Television

원본 레포의 `television/` 폴더는 채널 라이브러리입니다. `config.toml`은 UI/키바인딩이고, `cable/*.toml`은 파일, Git, Docker, Kubernetes, GitHub, history 같은 개별 picker 채널입니다.

`tv`는 선택형입니다. 넣으면 `Ctrl-T`로 스마트 자동완성 picker를 열 수 있습니다.

기본 배치는 이렇게 맞췄습니다.

- `Ctrl-T`: `tv` 스마트 자동완성
- `Ctrl-R`: `atuin` 히스토리
- `Ctrl-G`: `tv` 히스토리

`zsh` 선택 시에는 `nu` 전용 채널을 설치하지 않고, `nu` 선택 시에만 `nu-history` 채널을 같이 링크합니다.
