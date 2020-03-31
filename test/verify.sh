#/bin/bash
set -e

# Check linting
helm lint .
# Add required dependecies
helm dependency update .
# expose the service via ingress, this disables the deployment of nginx
helm template --set "expose.type=ingress" --output-dir /tmp/ .
# expose the service via node port, this enables the deployment of nginx
helm template --set "expose.type=nodePort,expose.tls.commonName=127.0.0.1" --output-dir /tmp/ .