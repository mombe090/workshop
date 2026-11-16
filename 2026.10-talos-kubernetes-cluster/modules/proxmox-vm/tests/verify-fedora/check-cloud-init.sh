#!/usr/bin/env bash
# Verifies that cloud-init configured the Fedora VM:
#   - SSH key authentication works with the injected public key
#   - cloud-init reached the end of runcmd (/tmp/cloud-config.done marker)
#   - the hostname matches the module name
#   - qemu-guest-agent is active
#
# Always exits 0 and reports findings as JSON, so Terraform assertions produce a
# useful message instead of an opaque data source error.
set -uo pipefail

host="${1:?host is required}"
user="${2:?user is required}"
key_path="${3:-~/.ssh/id_ed25519}"
expected_hostname="${4:?expected hostname is required}"

# shellcheck disable=SC2088 # intentional: expand a leading ~ ourselves
key_path="${key_path/#\~/$HOME}"

ssh_command() {
  ssh -i "$key_path" \
    -o BatchMode=yes \
    -o ConnectTimeout=5 \
    -o IdentitiesOnly=yes \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    "$user@$host" "$@"
}

ssh_reachable="false"
cloud_init_done="false"
guest_agent_active="false"
hostname=""

# 1. Wait for SSH. The module's guest-agent provisioner usually gets here first,
#    but a fresh cloud image can take a couple of minutes to come up.
for _ in $(seq 1 40); do
  if ssh_command true >/dev/null 2>&1; then
    ssh_reachable="true"
    break
  fi
  sleep 10
done

# 2. Wait for cloud-init to finish. runcmd installs packages (dnf update +
#    qemu-guest-agent, net-tools, curl, git, openssh-server), which can take
#    several minutes on a fresh Fedora cloud image.
if [[ "$ssh_reachable" == "true" ]]; then
  for _ in $(seq 1 60); do
    if ssh_command 'test -f /tmp/cloud-config.done' >/dev/null 2>&1; then
      cloud_init_done="true"
      break
    fi
    sleep 10
  done

  hostname="$(ssh_command hostnamectl --static 2>/dev/null || true)"
  if ssh_command 'systemctl is-active --quiet qemu-guest-agent' >/dev/null 2>&1; then
    guest_agent_active="true"
  fi
fi

# Strip anything that would break the JSON payload (defensive; hostnames are
# alphanumeric and dashes).
hostname="${hostname//[^a-zA-Z0-9.-]/}"

printf '{"ssh_reachable":"%s","cloud_init_done":"%s","guest_agent_active":"%s","hostname":"%s","expected_hostname":"%s"}\n' \
  "$ssh_reachable" "$cloud_init_done" "$guest_agent_active" "$hostname" "$expected_hostname"
