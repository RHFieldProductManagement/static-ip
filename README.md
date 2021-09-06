# [WIP] Static IP's in CoreOS

This repo is part of some work-in-progress code that will allow for static IP's to be pushed into CoreOS images to workaround the DHCP requirement for baremetal IPI OpenShift 4.x deployments.

There needs to be a counterpart to this that works with Ironic Python Agent (IPA), as Metal3 relies on IPA to lay down the disk image, and that needs the same sort of setup, but I've not looked into that yet.

NOTE: This is not a supported Red Hat repo and should only be used for testing.
