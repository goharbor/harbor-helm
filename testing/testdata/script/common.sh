# Function to create and manage temporary directory
function create_temp_dir() {
  # Create a temporary directory and assign it to TEMP_DIR
  TEMP_DIR=$(mktemp -d)
  echo "Temporary directory created at: $TEMP_DIR"

  # Ensure the temporary directory is removed when the script exits
  trap 'echo "Removing temporary directory: $TEMP_DIR"; rm -rf "$TEMP_DIR"' EXIT
}

function gen_kubeconfig() {
  echo "Generating kubeconfig..."
  acp_host=$1
  acp_token=$2
  cluster=$3
  kubeconfig_file=$4

  cat <<EOF >$kubeconfig_file
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: ${acp_host}/kubernetes/${cluster}
  name: ${cluster}-cluster
contexts:
- context:
    cluster: ${cluster}-cluster
    user: user-${cluster}-cluster
  name: ${cluster}-cluster
current-context: ${cluster}-cluster
kind: Config
users:
- name: user-${cluster}-cluster
  user:
    token: ${acp_token}
EOF
}
