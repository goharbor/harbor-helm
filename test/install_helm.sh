#/bin/bash
set -e
version=${HELM_VERSION}
if [ "$version" = "2" ]
then
    dist="helm-v2.8.0-linux-amd64.tar.gz"
    # as the helm v3 removes tiller, here appends the "-c" option 
    # to args only when running helm v2 to display the client version
    version_args="-c"
elif [ "$version" = "3" ]
then
    # the "template" command doesn't work for helm beta3:
    # https://github.com/helm/helm/issues/6404, use the beta2 for now
    dist="helm-v3.0.0-beta.2-linux-amd64.tar.gz"
else
    echo "unsupported helm version: $version"
    exit 1
fi
wget -O /tmp/${dist} https://get.helm.sh/${dist}
tar -zxvf /tmp/${dist} -C /tmp/

sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
helm version $version_args
echo "Helm installed"