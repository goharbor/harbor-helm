#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source ${SCRIPT_DIR}/common.sh

# Main function to prepare SSO configuration
prepare_sso_config() {
  create_temp_dir

  acp_host=$1
  acp_token=$2
  cluster=$3
  harbor_base_url=${4:-"https://test-sso.example.com"}

  echo "acp_host: $acp_host"
  echo "acp_token: ******"
  echo "cluster: $cluster"

  if [ -z "$acp_host" ] || [ -z "$acp_token" ] || [ -z "$cluster" ]; then
    echo "请指定 acp_host, acp_token 和 cluster 参数"
    exit 1
  fi

  echo "generate kubeconfig yamls ..."
  business_kubeconfig="${TEMP_DIR}/business_kubeconfig.yaml"
  global_kubeconfig="${TEMP_DIR}/global_kubeconfig.yaml"
  gen_kubeconfig "${acp_host}" "${acp_token}" "${cluster}" "${business_kubeconfig}"
  gen_kubeconfig "${acp_host}" "${acp_token}" "global" "${global_kubeconfig}"

  # 创建 Oauth2Client 资源
  echo "creating Oauth2Client resource ..."
  KUBECONFIG=${global_kubeconfig} kubectl apply -f - <<EOF
apiVersion: dex.coreos.com/v1
kind: OAuth2Client
name: OIDC
metadata:
  name: orsxg5bnmrsxqllimfzge33szpzjzzeeeirsk
  namespace: cpaas-system
alignPasswordDB: true
id: test-dex-harbor
public: false
redirectURIs:
  - ${harbor_base_url}/c/oidc/callback
secret: Z2l0bGFiLW9mZmljaWFsLTAK
spec: {}
EOF

  echo "SSO configuration preparation completed."
}

# Execute the main function with all script arguments
prepare_sso_config "$@"
