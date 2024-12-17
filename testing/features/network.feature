# language: zh-CN
@harbor-chart-deploy
@harbor-chart-deploy-network
功能: 支持多种网络模式部署 harbor

  @automated
  @priority-high
  @harbor-chart-deploy-network-http
  场景: 使用 http 方式部署 harbor
    假定 集群已安装 ingress controller
    并且 已添加域名解析
      | domain                        | ip           |
      | test-ingress-http.example.com | <ingress-ip> |
    并且 命名空间 "network-http" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "network-http" 命名空间
      """
      chartPath: ../
      releaseName: harbor-http
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-storage-hostpath.yaml
      - testdata/snippets/values-network-ingress-http.yaml
      """
    那么 "harbor" 可以正常访问
      """
      url: http://test-ingress-http.example.com
      timeout: 10m
      """

  @automated
  @priority-high
  @harbor-chart-deploy-network-https
  场景: 使用 https 方式部署 harbor
    假定 集群已安装 ingress controller
    并且 已添加域名解析
      | domain                         | ip           |
      | test-ingress-https.example.com | <ingress-ip> |
    并且 命名空间 "network-https" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    并且 已导入 "tls 证书" 资源: "./testdata/resources/secret-tls-cert.yaml"
    当 使用 helm 部署实例到 "network-https" 命名空间
      """
      chartPath: ../
      releaseName: harbor-https
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-storage-hostpath.yaml
      - testdata/snippets/values-network-ingress-https.yaml
      """
    那么 "harbor" 可以正常访问
      """
      url: https://test-ingress-https.example.com
      timeout: 10m
      """

  @smoke
  @automated
  @priority-high
  @harbor-chart-deploy-network-nodeport
  场景: 使用 nodeport 方式部署 harbor
    假定 命名空间 "network-nodeport" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "network-nodeport" 命名空间
      """
      chartPath: ../
      releaseName: harbor-nodeport
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-storage-hostpath.yaml
      - testdata/snippets/values-network-nodeport.yaml
      """
    那么 "harbor" 可以正常访问
      """
      url: http://<node.first>:<nodeport.http>
      timeout: 10m
      """
