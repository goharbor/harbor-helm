#/bin/bash
set -e
wget -O /tmp/helm2/helm-v2.8.0-linux-amd64.tar.gz https://get.helm.sh/helm-v2.8.0-linux-amd64.tar.gz
tar -zxvf /tmp/helm2/helm-v2.8.0-linux-amd64.tar.gz
mv /tmp/helm2/linux-amd64/helm /usr/local/bin/helm2