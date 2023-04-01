#!/bin/bash
# This is trivy bash script for scan the all running docker images save the outputs in table formate.

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID_LIKE" == "ubuntu" ] || [ "$ID_LIKE" == "debian" ]; then
        sudo apt-get install wget apt-transport-https gnupg lsb-release
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install trivy
    elif [ "$ID_LIKE" == "centos" ] || [ "$ID_LIKE" == "rhel" ]; then
        sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.20.0/trivy_0.20.0_Linux-64bit.rpm
    else
        echo "Unsupported distribution: $ID_LIKE"
        exit 1
    fi
else
    echo "Failed to detect Linux distribution."
    exit 1
fi

IMAGE_NAMES=$(docker images --format "{{.Repository}}:{{.Tag}}")
OUTPUT=$(mkdir ./trivy_output)
for IMAGE_NAME in $IMAGE_NAMES
do
  echo "Scanning image $IMAGE_NAME..."
  sudo trivy -f table $IMAGE_NAME -o $OUTPUT/$IMAGE_NAMES
  echo "Scanning Done!"
done

