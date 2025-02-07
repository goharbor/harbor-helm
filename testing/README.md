## 目录结构

- features：BDD feature 文件
- hack: 一些脚本，用于生成测试数据或者测试环境准备脚本
- steps: 自定义step
- testdata：测试数据
- main_test.go: 测试入口文件
- Makefile: 包含了一些常用命令

## 执行测试

### 基于chart 的集成测试

前置条件：
1. 设置好 kubeconfig，可以连接到 k8s 集群
2. 集群已安装 ingress controller（可以是 alb 或者是 nginx ingress controller，不限制）
3. 存在存储类，存储类需要支持 readwritemany 方式（nfs 和 ceph 都支持）

在 testing 目录下面执行命令即可。

```bash
make test-all
```

备注：目前 vcluster 所在的集群资源不足，无法运行测试。

### 基于 gitlab operator 的 e2e 测试

前置条件：

1. 准备一个配置文件，配置内容如下：

```yaml
acp:
  baseUrl: https://192.168.129.179 # acp 的 url
  token: xxxx # acp 的 token
  cluster: business-1 # 运行测试的集群名称
  username: dailyt-admin 
  password: 07Apples@
```
将配置文件保存在 testing 目录下，文件名称为 config.yaml。（也可以保存在其他路径，然后通过 E2E_CONFIG 环境变量指定配置文件的路径）

在 testing 目录下执行命令：

```bash
make test-e2e
```
