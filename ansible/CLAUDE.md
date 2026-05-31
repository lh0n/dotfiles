# Ansible Home Lab — AI Agent Instructions

> Project spec, architecture, tooling setup and roadmap: [README.md](README.md)

---

## Quick Reference

**Inventory groups:** `controller` (localhost), `desktop` (garkbit), `pinet` (rpi), `all`
Do not use `workstation` or `laptop` — they don't exist in the inventory.

**File layout:**
```
playbooks/   # standalone playbooks, one concern each
roles/       # docker role scaffolded, empty — next to implement
inventory/   # home.yaml + group_vars/
```

---

## Open Tech Debt

Flag these when touched; fix in context.

| File | Issue |
|------|-------|
| `apt.yaml` | APT module options duplicated across tasks — use `module_defaults` |
| `rustup.yaml` | No checksum verification on downloaded install script |
| `roles/docker` | Scaffolded but empty |

---

## Conventions

**Modules:**
- FQCN everywhere: `ansible.builtin.apt`, `community.general.cargo`, etc.
- `become: true` at play level only, not task level
- Prefer `ansible.builtin.*` → `community.*` only when a builtin equivalent
  doesn't exist and reimplementing with shell/command would be nearly identical

**Currently used community modules (justified):**
- `community.general.cargo` — idempotent cargo package management
- `community.general.pipx` — idempotent pipx package management

**Idempotency:**
- Avoid `ansible.builtin.shell`/`command` without `creates:`, `changed_when:`, or `failed_when:`

**Variables:**
- Group vars in `inventory/group_vars/` — not play-level `vars:` for host-specific values
- User-space paths: `ansible_facts['env']['HOME']` — never `ansible_env.HOME` (deprecated)

**Tags:**
Use: `packages`, `system`, `user`, `rust`, `python`, `files`, `config`,
`connectivity`, `reboot`, `apt`, `cargo`, `rustup`, `pipx`, `pip`, `neovim`, `qtile`

**Style:**
- `gather_facts: false` unless the play uses facts
- Always quote Jinja2 expressions in YAML string values
- Block sequences only — never flow style (`[a, b, c]`)
- Package lists alphabetically sorted

---

## AI Prompting Guide

**Provide this context when asking for changes:**
- Target hosts: `controller`, `desktop`, `pinet`, or `all`
- System-level (`become: true`) or user-space
- New playbook, adding to existing, or converting to a role

**Effective patterns:**
- "Add `<package>` to `<playbook>` for `<group>`"
- "Convert `<playbook>` to a role following the docker role structure"
- "Fix the open tech debt item for `<file>` from CLAUDE.md"

**Avoid:**
- Refactoring everything at once
- Adding vault, dynamic inventory, or galaxy roles without a stated reason

**Before accepting a suggestion, verify:**
1. Correct host group?
2. Task idempotent?
3. Does `--check --diff` produce sensible output?
4. FQCNs used throughout?
