#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source ${SCRIPT_DIR}/../testdata/script/common.sh

# Main execution starts here
main() {
    create_temp_dir

    config_file=${1:-./config.yaml}

    echo "Using config file: $config_file"

    if [ ! -f "$config_file" ]; then
        echo "Config file not found: $config_file"
        exit 1
    fi

    acp_host=$(yq '.acp.baseUrl' $config_file)
    acp_token=$(yq '.acp.token' $config_file)
    acp_test_cluster=$(yq '.acp.cluster' $config_file)

    echo "ACP Host: $acp_host"
    echo "ACP Token: *****"
    echo "ACP Test Cluster: $acp_test_cluster"

    kubeconfig_file="${TEMP_DIR}/kubeconfig"
    gen_kubeconfig "${acp_host}" "${acp_token}" "${acp_test_cluster}" "${kubeconfig_file}"

    export KUBECONFIG=${kubeconfig_file}
    cd ${SCRIPT_DIR}/..
    go test -timeout=1h -v -count 1 ./ ${GODOG_ARGS} --godog.tags="@e2e"
}

# Execute the main function with all script arguments
main "$@"
