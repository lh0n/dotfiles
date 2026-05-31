# Ansible Home Lab

Personal Ansible automation for managing a small home lab. The goal is
idiomatic, production-quality Ansible — not enterprise complexity. Every
decision should favour clarity and simplicity over abstraction.

`~/ansible` is a symlink to `~/dotfiles/ansible` (stow-managed dotfiles).
Running `ansible-playbook` from either path works identically.

---

## Intent and Goals

- Learn and practise modern Ansible by doing real work on real machines
- Keep all hosts consistently configured from a single source of truth
- Automate the boring parts (package installs, tool bootstrapping, config files)
- Build toward a fully reproducible environment — new machine, run the playbooks, done

---

## Architecture

### Inventory

```
all
├── controller        # localhost — the machine running ansible (local connection)
│   └── localhost
├── desktop           # primary workstation (SSH)
│   └── garkbit
└── pinet             # Raspberry Pi (SSH, user: ansible)
    └── rpi
```

SSH authentication uses a dedicated `ansible` user with key-based auth
(NOPASSWD sudo) on all remote hosts. Key association lives in `~/.ssh/config`,
not in the inventory, to keep credentials out of the repo.

The controller uses `ansible_become_exe: /usr/bin/sudo.ws` to work around a
prompt-detection incompatibility with `sudo-rs` (Ubuntu ships both; sudo-rs is
the default but breaks Ansible's become plugin).

### Managed Stack

| Layer | Software |
|-------|----------|
| WM | Niri (Wayland), Waybar |
| Shell | ZSH + Starship |
| Terminal | Alacritty (built from cargo) |
| Editor | Neovim (built from source) |
| Rust tools | bat, eza, fd-find, ripgrep, git-delta, tealdeer, bkt, du-dust, starship |
| Python tools | ipython, ansible-lint, pre-commit (all via uv tool) |
| Dotfiles | GNU Stow |

---

## Project Structure

```
ansible.cfg                        # project config
inventory/
  home.yaml                        # static inventory
  group_vars/
    controller.yaml                # local connection + sudo-rs workaround
    desktop.yaml                   # ssh, ansible user
    pinet.yaml                     # ssh, ansible user
playbooks/                         # standalone playbooks, one concern each
  apt.yaml                         # system packages (all hosts)
  apt_recommends.yaml              # packages requiring install_recommends
  cargo.yaml                       # Rust/cargo packages
  files.yaml                       # deploy config files to /etc
  ping.yaml                        # connectivity check
  pip.yaml                         # pip package removals (cleanup only)
  pipx.yaml                        # pipx packages
  qtile.yaml                       # Qtile WM deps in virtualenv (controller)
  reboot.yaml                      # reboot desktop hosts
  rustup.yaml                      # bootstrap Rust toolchain
roles/
  docker/                          # in progress
collections/
  requirements.yml                 # community.general only
.ansible-lint                      # lint profile: production
.yamllint                          # YAML style rules
Makefile                           # convenience targets
```

---

## Getting Started

### Prerequisites

Install tooling via `uv`:

```bash
uv tool install ansible-core
uv tool install ansible-lint
uv tool install yamllint
uv tool install pre-commit
```

Install pre-commit hooks (from the dotfiles repo root):

```bash
pre-commit install
```

Install required Ansible collections:

```bash
make install-collections
```

### SSH Setup

Add to `~/.ssh/config` for each managed host:

```
Host garkbit
    User ansible
    IdentityFile ~/.ssh/<your-key>

Host rpi
    User ansible
    IdentityFile ~/.ssh/<your-key>
```

---

## Usage

```bash
# Verify connectivity
make ping

# Dry-run before applying (always do this first)
ansible-playbook playbooks/apt.yaml --check --diff
make check-apt

# Apply to a specific host
ansible-playbook playbooks/cargo.yaml --limit garkbit

# Run by tag
ansible-playbook playbooks/apt.yaml --tags packages

# Controller needs become password (sudo-rs quirk, see Architecture)
ansible-playbook playbooks/apt.yaml --ask-become-pass --limit controller
```

Available tags: `packages`, `system`, `user`, `rust`, `python`, `files`,
`config`, `connectivity`, `reboot`, `apt`, `cargo`, `rustup`, `pipx`, `pip`,
`neovim`, `qtile`

No `site.yml` orchestrator yet — playbooks are run individually.

---

## Tooling

### Linting

```bash
make lint          # full ansible-lint run (profile: production)
make yaml-lint     # yamllint only (faster)
ansible-lint --fix # auto-fix formatting issues
```

Intentionally skipped lint rules (see `.ansible-lint` for rationale):
- `yaml[line-length]` — long package lists are more readable unwrapped
- `no-free-form` — short shell one-liners are acceptable
- `package-latest` — home lab intentionally tracks latest tool versions

### Testing

- `--check --diff` for pre-run dry-runs (built into Makefile)
- Molecule (planned) for role-level testing once `roles/docker` is implemented

---

## Roadmap

### Open Tech Debt

| File | Issue |
|------|-------|
| `apt.yaml` | APT module options duplicated across tasks — use `module_defaults` |
| `rustup.yaml` | No checksum verification on downloaded install script |
| `roles/docker` | Scaffolded but empty |

### Completed

| Item | Notes |
|------|-------|
| Lint clean (profile: production) | All playbooks pass ansible-lint with zero violations |
| YAML block sequences enforced | No more flow-style `[a, b, c]` lists |
| Task tags on all playbooks | Full tag coverage |
| `ansible_env` deprecation | Migrated to `ansible_facts['env']` everywhere |
| `INJECT_FACTS_AS_VARS=False` | Opted into ansible-core 2.24 default early |
| Dead inventory groups removed | `workstation`/`laptop` → `desktop` |
| pip/pipx cleanup | Removed `--break-system-packages`, double-quoted args |
| Dedicated ansible SSH user | Key-based auth, NOPASSWD, key path in `~/.ssh/config` |
| sudo-rs workaround | Controller uses `sudo.ws` for Ansible become compatibility |

### Next Features

1. Implement `roles/docker` with Molecule tests
2. Add `site.yml` orchestrator importing playbooks in dependency order
3. Add checksum verification to `rustup.yaml`
4. Deduplicate APT module options using `module_defaults`
