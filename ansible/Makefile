.PHONY: lint yaml-lint ping check-apt install-collections

# Run ansible-lint against all playbooks
lint:
	ansible-lint

# Run yamllint standalone
yaml-lint:
	yamllint -c .yamllint .

# Test connectivity to all hosts
ping:
	ansible-playbook playbooks/ping.yaml

# Dry-run apt playbook (safe to run anytime)
check-apt:
	ansible-playbook playbooks/apt.yaml --check --diff

# Install required collections
install-collections:
	ansible-galaxy collection install -r collections/requirements.yml
