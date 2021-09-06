#!/bin/env bash
set -eo pipefail

# Generate password hash
function generateHash () {
    local hash="$(echo "test" | mkpasswd --method=SHA-512 --rounds=4096 -s)"
    echo "$hash"
}

# Generate the FCC configuration file
function generateFCC () {
    local hash="$1"
    cat << EOF > fcos.fcc
    variant: openshift
    metadata:
      name: config-openshift
      labels:
        machineconfiguration.openshift.io/role: master,worker
    version: 4.8.0
    passwd:
      users:
      - name: core
        ssh_authorized_keys:
          - your-key-here
    storage:
      files:
      - path: /etc/hostname
        overwrite: true
        mode: 0644
        contents:
          inline: rhcos-server-test
      - path: /etc/static-ip-config.json
        overwrite: true
        mode: 0644
        contents:
          local: hosts.json
          verification: {}
      - path: /etc/static-ip-setup
        overwrite: true
        mode: 0644
        contents:
          local: static-ip-setup
          verification: {}
    systemd:
      units:
        - name: static-ip-setup.service
          enabled: true
          contents: |
            [Unit]
            Description=Setup Static IP's from mappings
            After=NetworkManager.service
            [Service]
            Type=oneshot
            RemainAfterExit=yes
            ExecStart=sh /etc/static-ip-setup
            [Install]
            WantedBy=multi-user.target
EOF
}

# Create a snapshot of the image to not modify original image
rm rhcos.qcow2 &>/dev/null || true
qemu-img create -f qcow2 -b rhcos-orig.qcow2 rhcos.qcow2

# Generate the FCC configuration file
generateFCC "$(generateHash)"

cp -f hosts.json static-ip-setup /tmp/embed/

# Generate Ignition file from FCC configuration
podman run --privileged -i --rm -v /tmp/embed/:/tmp/ quay.io/coreos/fcct:latest --files-dir=/tmp --raw --pretty --strict < fcos.fcc > config.ign

# Inject configuration file into system image
fs_boot_path=$(virt-filesystems -a rhcos.qcow2 -l | grep boot | awk -F ' ' '{print $1}')
config_file_path=./config.ign

guestfish add rhcos.qcow2 : \
          run : \
          mount "$fs_boot_path" / : \
          mkdir /ignition : \
          copy-in "$config_file_path" /ignition/ : \
          unmount-all : \
          exit
