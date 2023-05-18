#!/bin/bash
echo "This is script is not stable yet in case it does not work go ahead and follow the step-by-step in the README.md file, thank you."

sudo snap install microk8s --classic --channel=1.27 \
microk8s status --wait-ready \
microk8s enable dashboard \
microk8s enable dns \
microk8s enable registry \
microk8s enable community \
sudo systemctl enable iscsid \
microk8s enable openebs