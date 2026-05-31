# Ansible Home Lab — AI Agent Instructions

## Project Overview

Personal home lab Ansible automation for managing a small multi-host environment.
This is a learning/experimentation project, so the goal is idiomatic Ansible, not
enterprise complexity. Prefer clarity and simplicity over abstraction.

`~/ansible` is a symlink to `~/dotfiles/ansible` (stow-managed dotfiles).
Running `ansible-playbook` from either path works identically.

---

## Inventory Topology

```
all
├── controller        # localhost (local connection) — the machine running ansible
│   └── localhost
├── desktop           # SSH — primary workstation
│   └── garkbit
└── pinet             # SSH as user 'pi' — Raspberry Pi
    └── rpi
```

**Dead groups in playbooks** (not in inventory — treat as tech debt):
- `workstation` (referenced in `cargo.yaml`, `reboot.yaml`)
- `laptop` (referenced in `cargo.yaml`)

When editing playbooks, use the actual group names: `controller`, `desktop`, `pinet`, or `all`.

---

## File Layout

```
ansible.cfg              # project config; inventory points to ~/ansible/inventory/home.yaml
inventory/
  home.yaml              # static inventory
  group_vars/
    controller.yaml      # ansible_connection: local
    desktop.yaml         # ansible_connection: ssh
    pinet.yaml           # ansible_connection: ssh; ansible_user: pi
playbooks/               # standalone playbooks, one concern each
  apt.yaml               # system packages (all hosts)
  apt_recommends.yaml    # packages needing install_recommends
  cargo.yaml             # Rust/cargo packages
  files.yaml             # deploy config files to /etc
  ping.yaml              # connectivity check
  pip.yaml               # pip packages + removals
  pipx.yaml              # pipx packages
  qtile.yaml             # Qtile WM deps in virtualenv (controller only)
  reboot.yaml            # reboot hosts
  rustup.yaml            # bootstrap Rust toolchain
roles/
  docker/                # SCAFFOLDED BUT EMPTY — in progress
    handlers/
    tasks/
    vars/
```

---

## Tooling Stack

All tools are installed via `uv tool` and available on PATH.

| Tool | Version | Purpose |
|------|---------|---------|
| `ansible-core` | 2.20.x | Core engine |
| `ansible-lint` | 26.x | Linting — profile: production |
| `pre-commit` | 4.x | Git hook enforcement |

**Key config files:**
- `.ansible-lint` — lint rules, skip_list, profile
- `.yamllint` — YAML formatting rules (ansible-lint-compatible)
- `collections/requirements.yml` — pinned collection dependencies
- `~/dotfiles/.pre-commit-config.yaml` — git hooks (git root, scoped to `ansible/`)
- `Makefile` — convenience targets

**Install collections after a fresh clone:**
```bash
make install-collections
```

**Lint workflow:**
```bash
make lint            # full ansible-lint run
make yaml-lint       # yamllint only (faster)
ansible-lint --fix   # auto-fix what's fixable, then re-run to verify
```

**Skipped rules (intentional — see `.ansible-lint` for rationale):**
- `yaml[line-length]` — package lists are more readable unwrapped
- `no-free-form` — short shell one-liners acceptable
- `package-latest` — home lab tracks latest tool versions

**Community module policy:**
Prefer `ansible.builtin.*` for all new tasks. Use community modules only when
a builtin equivalent doesn't exist AND reimplementing with shell/command would
produce nearly identical logic. Currently used: `community.general.cargo`,
`community.general.pipx` (both justified by idempotency complexity).

---

## How to Run

```bash
# connectivity check
ansible-playbook playbooks/ping.yaml
make ping

# dry-run (check mode) — always run before applying
ansible-playbook playbooks/apt.yaml --check --diff
make check-apt

# target a specific host or group
ansible-playbook playbooks/cargo.yaml --limit garkbit

# run with verbose output
ansible-playbook playbooks/rustup.yaml -v
```

No `site.yml` orchestrator exists yet. Playbooks are run individually.

---

## Stack Context

- **WM:** Niri (Wayland compositor), Waybar
- **Shell:** ZSH + Starship prompt
- **Terminal:** Alacritty (built from cargo)
- **Editor:** Neovim (built from source)
- **Rust tools:** bat, eza, fd-find, ripgrep, git-delta, tealdeer, bkt, du-dust, starship
- **Python tools:** ipython (uv tool), ansible-lint (uv tool), pre-commit (uv tool)
- **Dotfiles:** managed with GNU Stow

---

## Known Issues and Tech Debt

These should be addressed incrementally — flag them when touched, fix them in context.

| File | Issue | Status |
|------|-------|--------|
| `cargo.yaml` | References `workstation`/`laptop` groups that don't exist in inventory | open |
| `apt.yaml` | `autoclean`, `autoremove`, `clean`, `update_cache`, `cache_valid_time` duplicated across tasks | open |
| `rustup.yaml` | Fetches and runs shell script from the internet with no checksum verification | open |
| `pip.yaml` | `--break-system-packages` flag is unsafe; `pip` install list is empty (vestigial) | open |
| `pipx.yaml` | `pip_args: "'--verbose'"` has extra quotes (likely a bug) | open |
| All playbooks | No task tags — can't run subsets with `--tags` | open |
| `roles/docker` | Scaffolded but completely empty | open |
| `files.yaml` | Unquoted Jinja2 in `src:` values | **fixed** |
| All playbooks | Missing `---` document start | **fixed** |
| `rustup.yaml` | Used `ansible.builtin.shell` where `command` suffices | **fixed** |

---

## Conventions to Follow

**Module usage:**
- Use FQCN everywhere: `ansible.builtin.apt`, `community.general.cargo`, etc.
- Prefer `ansible.builtin.package` for cross-distro tasks (future-proofing for rpi)
- `become: true` only at play level, not task level (unless unavoidable)

**Idempotency:**
- Every task must be idempotent — avoid `ansible.builtin.shell`/`command` unless wrapped with `creates:`, `changed_when:`, or `failed_when:`
- Add `check_mode: true` support where possible

**Variables:**
- Group vars belong in `inventory/group_vars/`
- Avoid play-level `vars:` for things that differ per host — use group_vars instead
- Use `ansible_env.HOME` (not hardcoded paths) for user-space paths

**Tags (to adopt going forward):**
- Use consistent tags: `packages`, `system`, `user`, `rust`, `python`, `files`, `config`

**Style:**
- `gather_facts: false` unless the play uses facts
- Quote all Jinja2 expressions in YAML string values
- Keep package lists alphabetically sorted
- Always use block sequences (vertical lists) — never flow style (`[a, b, c]`)

---

## AI Prompting Guide

**When asking for help, provide this context:**
- Which host(s) the change targets (`controller`, `desktop`, `pinet`, or `all`)
- Whether it needs `become: true` (system-level) or not (user-space)
- Whether it's a new playbook, adding to an existing one, or converting to a role

**Good prompt patterns:**
- "Add `<package>` to `<playbook>` for `<group>`" — surgical, scoped
- "Convert `<playbook>` to a role following the existing docker role structure"
- "Fix the known issue in `<file>` described in CLAUDE.md"
- "Add tags to all tasks in `<playbook>` using the tag conventions in CLAUDE.md"

**Avoid:**
- Asking to refactor everything at once
- Adding complexity (galaxy roles, vault, dynamic inventory) without a stated reason
- Generating playbooks targeting `workstation` or `laptop` groups

**When the AI suggests something, validate:**
1. Is the host group correct for the intended targets?
2. Is the task idempotent?
3. Does `--check --diff` produce sensible output?
4. Are FQCNs used for all modules?

---

## Next Logical Improvements (prioritized)

1. Remove or replace dead `workstation`/`laptop` group references in `cargo.yaml`, `reboot.yaml`
2. Fix `pipx.yaml` double-quoted `pip_args`
3. Clean up `pip.yaml` (empty install list, remove `--break-system-packages`)
4. Add task tags to all playbooks
5. Implement `roles/docker`
6. Add a `site.yml` that imports all playbooks in dependency order
7. Add checksum verification to `rustup.yaml`
