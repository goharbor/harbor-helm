# language: zh-CN
@harbor-chart-deploy
功能: 支持高可用模式部署 harbor

    @smoke
    @automated
    @priority-high
    @harbor-chart-deploy-ha
    场景: 使用高可用模式部署 harbor
        假定 集群已安装 ingress controller
        并且 已添加域名解析
            | domain                      | ip           |
            | test-ingress-ha.example.com | <ingress-ip> |
        并且 集群已存在存储类
        并且 命名空间 "harbor-ha" 已存在
        并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
        当 使用 helm 部署实例到 "harbor-ha" 命名空间
            """
            chartPath: ../
            releaseName: harbor-ha
            values:
            - testdata/snippets/base-values.yaml
            - testdata/snippets/values-storage-sc.yaml
            - testdata/snippets/values-ha.yaml
            """
        那么 "harbor-ha" 组件检查通过
        并且 "harbor" 可以正常访问
            """
            url: http://test-ingress-ha.example.com
            timeout: 10m
            """
        并且 资源检查通过
            | kind        | apiVersion | name                 | path            | value |
            | Deployment  | apps/v1    | harbor-ha-core       | $.spec.replicas | 2     |
            | Deployment  | apps/v1    | harbor-ha-registry   | $.spec.replicas | 2     |
            | Deployment  | apps/v1    | harbor-ha-jobservice | $.spec.replicas | 2     |
            | StatefulSet | apps/v1    | harbor-ha-trivy      | $.spec.replicas | 2     |
