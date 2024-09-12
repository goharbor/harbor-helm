#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
TEMP_DIR=$(mktemp -d)
# trap 'rm -rf ${TEMP_DIR}' EXIT

DOMAIN="example.com"
WILDCARD="*.${DOMAIN}"
KEY_FILE="${TEMP_DIR}/key.pem"
CSR_FILE="${TEMP_DIR}/csr.pem"
CRT_FILE="${TEMP_DIR}/cert.pem"
CONFIG_FILE="${TEMP_DIR}/openssl.cnf"
DAYS_VALID=3650

# 生成私钥
openssl genrsa -out "${KEY_FILE}" 2048

# 创建 OpenSSL 配置文件
cat >"${CONFIG_FILE}" <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = CN
O = My Company Name LTD.
CN = ${WILDCARD}

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${WILDCARD}
DNS.2 = ${DOMAIN}
EOF

# 生成证书签名请求 (CSR)
openssl req -new -key "${KEY_FILE}" -out "${CSR_FILE}" -config "${CONFIG_FILE}"

# 生成自签名证书
openssl x509 -req -days "${DAYS_VALID}" -in "${CSR_FILE}" -signkey "${KEY_FILE}" -out "${CRT_FILE}" -extfile "${CONFIG_FILE}" -extensions v3_req

cat <<EOF >${SCRIPT_DIR}/../testdata/resources/secret-tls-cert.yaml
apiVersion: v1
data:
  tls.crt: $(cat ${CRT_FILE} | base64)
  tls.key: $(cat ${KEY_FILE} | base64)
kind: Secret
metadata:
  labels:
    cpaas.io/hidden: "true"
    global-secret: "true"
  name: test-tls-cert
type: kubernetes.io/tls
EOF
