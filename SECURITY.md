# Harbor 安全问题说明

## 密码环境变量

### 描述
Harbor 组件中存在一些使用环境变量配置的明文密码，这是由于 Harbor 项目实现直接依赖环境变量来传递和读取密码信息，代码中使用了类似如下的方式读取密码：

```yaml
dbPassword := os.Getenv("POSTGRESQL_PASSWORD")
```

### 涉及的环境变量
* Core 组件
  * HARBOR_ADMIN_PASSWORD Harbor 管理员密码
  * POSTGRESQL_PASSWORD Harbor 数据库密码
  * REGISTRY_CREDENTIAL_PASSWORD Harbor Registry 组件密码

* JobService 组件
  * REGISTRY_CREDENTIAL_PASSWORD Harbor Registry 组件密码

* Registry 组件
  * REGISTRY_REDIS_PASSWORD Redis 密码

### 影响
在容器中通过 env 命令可以查看到密码明文，有暴露风险。
