# [WIP] Static IP's in CoreOS

This repo is part of some work-in-progress code that will allow for static IP's to be pushed into CoreOS images to workaround the DHCP requirement for baremetal IPI OpenShift 4.x deployments.

There needs to be a counterpart to this that works with Ironic Python Agent (IPA), as Metal3 relies on IPA to lay down the disk image, and that needs the same sort of setup, but I've not looked into that yet.

*NOTE*: This is not a supported Red Hat repo and should only be used for testing.

## How to use

* Grab a CoreOS disk image and put it in this same directory as `rhcos-orig.qcow2`
* Update the hosts.json file with a list of your potential hosts and their IP's etc.
* Run the `rhcos-embed.sh` script and it will create a new qcow2 with the injected config
* `static-ip-setup` will be executed as part of a systemd unit file on boot up and will create NetworkManager configs
* If you put an ssh public key into the `rhcos-embed.sh` script, you should be able to `ssh core@<your ip>` to validate
