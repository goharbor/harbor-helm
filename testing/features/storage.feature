# language: zh-CN

@harbor-chart-deploy
@harbor-chart-deploy-storage
功能: 支持多种存储类型部署 harbor

  @automated
  @priority-high
  @harbor-chart-deploy-storage-sc
  场景: 使用存储类方式部署 harbor
    假定 集群已存在存储类
    并且 命名空间 "storage-sc" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "storage-sc" 命名空间
      """
      chartPath: ../
      releaseName: harbor-sc
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-sc.yaml
      """
    那么 "harbor" 可以正常访问
      """
      url: http://<node.first>:<nodeport.http>
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                 | path                                                                            | value                  |
      | harbor-sc-registry   | $.spec.volumes[?(@.name == 'registry-data')][0].persistentVolumeClaim.claimName | harbor-sc-registry     |
      | harbor-sc-jobservice | $.spec.volumes[?(@.name == 'job-logs')][0].persistentVolumeClaim.claimName      | harbor-sc-jobservice   |
      | harbor-sc-trivy      | $.spec.volumes[?(@.name == 'data')][0].persistentVolumeClaim.claimName          | data-harbor-sc-trivy-0 |
      | harbor-sc-registry   | $.status.conditions[?(@.type == 'Ready')][0].status                             | True                   |
      | harbor-sc-core       | $.status.conditions[?(@.type == 'Ready')][0].status                             | True                   |
      | harbor-sc-jobservice | $.status.conditions[?(@.type == 'Ready')][0].status                             | True                   |
      | harbor-sc-trivy      | $.status.conditions[?(@.type == 'Ready')][0].status                             | True                   |

  @smoke
  @automated
  @priority-high
  @harbor-chart-deploy-storage-hostpath
  场景: 使用 hostpath 方式部署 harbor
    假定 命名空间 "storage-hostpath" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    当 使用 helm 部署实例到 "storage-hostpath" 命名空间
      """
      chartPath: ../
      releaseName: harbor-hostpat h
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-hostpath.yaml
      """
    那么 "harbor" 可以正常访问
      """
      url: http://<node.first>:<nodeport.http>
      timeout: 10m
      """
  并且 Pod 资源检查通过
    | name                       | path                                                | value        |
    | harbor-hostpath-registry   | $.status.hostIP                                     | <node.first> |
    | harbor-hostpath-jobservice | $.status.hostIP                                     | <node.first> |
    | harbor-hostpath-trivy      | $.status.hostIP                                     | <node.first> |
    | harbor-sc-registry         | $.status.conditions[?(@.type == 'Ready')][0].status | True         |
    | harbor-sc-core             | $.status.conditions[?(@.type == 'Ready')][0].status | True         |
    | harbor-sc-jobservice       | $.status.conditions[?(@.type == 'Ready')][0].status | True         |
    | harbor-sc-trivy            | $.status.conditions[?(@.type == 'Ready')][0].status | True         |

  @automated
  @priority-high
  @harbor-chart-deploy-storage-pvc
  场景: 使用指定 pvc 的方式部署 harbor
    假定 命名空间 "storage-pvc" 已存在
    并且 已导入 "password" 资源: "./testdata/resources/secret-password.yaml"
    并且 已导入 "pvc" 资源: "./testdata/resources/storage-pvc.yaml"
    当 使用 helm 部署实例到 "storage-pvc" 命名空间
      """
      chartPath: ../
      releaseName: harbor-pvc
      values:
      - testdata/snippets/base-values.yaml
      - testdata/snippets/values-network-nodeport.yaml
      - testdata/snippets/values-storage-pvc.yaml
      """
    那么 "harbor" 可以正常访问
      """
      url: http://<node.first>:<nodeport.http>
      timeout: 10m
      """
    并且 Pod 资源检查通过
      | name                  | path                                                                            | value          |
      | harbor-pvc-registry   | $.spec.volumes[?(@.name == 'registry-data')][0].persistentVolumeClaim.claimName | pvc-registry   |
      | harbor-pvc-jobservice | $.spec.volumes[?(@.name == 'job-logs')][0].persistentVolumeClaim.claimName      | pvc-jobservice |
      | harbor-pvc-trivy      | $.spec.volumes[?(@.name == 'data')][0].persistentVolumeClaim.claimName          | pvc-trivy      |
      | harbor-sc-registry    | $.status.conditions[?(@.type == 'Ready')][0].status                             | True           |
      | harbor-sc-core        | $.status.conditions[?(@.type == 'Ready')][0].status                             | True           |
      | harbor-sc-jobservice  | $.status.conditions[?(@.type == 'Ready')][0].status                             | True           |
      | harbor-sc-trivy       | $.status.conditions[?(@.type == 'Ready')][0].status                             | True           |
