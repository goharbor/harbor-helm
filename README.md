# Helm Chart for Harbor

**Notes:** The master branch is in heavy development, please use the codes on other branch instead. A high available solution for Harbor based on chart can be find [here](docs/High%20Availability.md). And refer to the [guide](docs/Upgrade.md) to upgrade the existing deployment.  

## Introduction
This [Helm](https://github.com/kubernetes/helm) chart installs [Harbor](https://github.com/goharbor/harbor) in a Kubernetes cluster. Welcome to [contribute](CONTRIBUTING.md) to Helm Chart for Harbor.

## Prerequisites
- Kubernetes cluster 1.10+
- Helm 2.8.0+

## Installation
### Download the chart
Download Harbor helm chart code.
```bash
git clone https://github.com/goharbor/harbor-helm
```
Checkout the branch.
```bash
cd harbor-helm
git checkout branch_name
```
### Configure the chart
The following items can be configured in `values.yaml` or set via `--set` flag during installation.  

#### Configure the way how to expose Harbor service:
- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.  
**Notes:** if the TLS is disabled, the port must be included in the command when pulling/pushing images. Refer to issue [#5291](https://github.com/goharbor/harbor/issues/5291) for the detail.  
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. 
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`.  

#### Configure the external URL
The external URL for Harbor core service is used to:  
1) populate the docker/helm commands showed on portal  
2) populate the token service URL returned to docker/notary client  

Format: `protocol://domain[:port]`. Usually:  
- if expose the service via `Ingress`, the `domain` should be the value of `expose.ingress.hosts.core`  
- if expose the service via `ClusterIP`, the `domain` should be the value of `expose.clusterIP.name`  
- if expose the service via `NodePort`, the `domain` should be the IP address of one Kubernetes node  

If Harbor is deployed behind the proxy, set it as the URL of proxy.  

#### Configure the way how to persistent data:
- **Disable**: The data does not survive the termination of a pod.
- **Persistent Volume Claim(default)**: A default `StorageClass` is needed in the Kubernetes cluster to dynamic provision the volumes. Specify another StorageClass in the `storageClass` or set `existingClaim` if you have already existing persistent volumes to use.
- **External Storage(only for images and charts)**: For images and charts, the external storages are supported: `azure`, `gcs`, `s3` `swift` and `oss`.  

#### Configure the other items listed in [configuration](#configuration) section.

### Install the chart
Install the Harbor helm chart with a release name `my-release`:
```bash
helm install --name my-release .
```

## Uninstallation
To uninstall/delete the `my-release` deployment:

```bash
helm delete --purge my-release
```

## Configuration
The following table lists the configurable parameters of the Harbor chart and the default values.

| Parameter                  | Description                        | Default                 |
| -----------------------    | ---------------------------------- | ----------------------- |
| **Expose** |
|`expose.type`|The way how to expose the service: `ingress`, `clusterIP` or `nodePort`|`ingress`|
|`expose.tls.enabled`|Enable the tls or not|`true`|
|`expose.tls.secretName`|Fill the name of secret if you want to use your own TLS certificate and private key. The secret must contain keys named `tls.crt` and `tls.key` that contain the certificate and private key to use for TLS. The certificate and private key will be generated automatically if it is not set||
|`expose.tls.notarySecretName`|By default, the Notary service will use the same cert and key as described above. Fill the name of secret if you want to use a separated one. Only needed when the `expose.type` is `ingress`.||
|`expose.tls.commonName`|The common name used to generate the certificate, it's necessary when the `expose.type` is `clusterIP` or `nodePort` and `expose.tls.secretName` is null||
| `expose.ingress.hosts.core` | The host of Harbor core service in ingress rule | `core.harbor.domain` |
| `expose.ingress.hosts.notary` | The host of Harbor Notary service in ingress rule | `notary.harbor.domain` |
| `expose.ingress.annotations` | The annotations used in ingress ||
| `expose.clusterIP.name` | The name of ClusterIP service |`harbor`|
| `expose.clusterIP.ports.httpPort` | The service port Harbor listens on when serving with HTTP |`80`|
| `expose.clusterIP.ports.httpsPort` | The service port Harbor listens on when serving with HTTPS |`443`|
| `expose.clusterIP.ports.notaryPort` | The service port Notary listens on. Only needed when `notary.enabled` is set to `true` |`4443`|
| `expose.nodePort.name` | The name of NodePort service |`harbor`|
| `expose.nodePort.ports.http.port` | The service port Harbor listens on when serving with HTTP |`80`|
| `expose.nodePort.ports.http.nodePort` | The node port Harbor listens on when serving with HTTP |`30002`|
| `expose.nodePort.ports.https.port` | The service port Harbor listens on when serving with HTTPS |`443`|
| `expose.nodePort.ports.https.nodePort` | The node port Harbor listens on when serving with HTTPS |`30003`|
| `expose.nodePort.ports.notary.port` | The service port Notary listens on. Only needed when `notary.enabled` is set to `true` |`4443`|
| `expose.nodePort.ports.notary.nodePort` | The node port Notary listens on. Only needed when `notary.enabled` is set to `true` |`30004`|
| **Persistence** |
| `persistence.enabled`     | Enable the data persistence or not | `true` |
| `persistence.resourcePolicy`     | Setting it to `keep` to avoid removing PVCs during a helm delete operation. Leaving it empty will delete PVCs after the chart deleted | `keep` |
| `persistence.persistentVolumeClaim.registry.existingClaim`     | Use the existing PVC which must be created manually before bound | |
|`persistence.persistentVolumeClaim.registry.storageClass`     | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning | |
|`persistence.persistentVolumeClaim.registry.subPath`     | The sub path used in the volume | |
|`persistence.persistentVolumeClaim.registry.accessMode`     | The access mode of the volume | `ReadWriteOnce` |
|`persistence.persistentVolumeClaim.registry.size`     | The size of the volume | `5Gi` |
|`persistence.persistentVolumeClaim.chartmuseum.existingClaim`     | Use the existing PVC which must be created manually before bound | |
|`persistence.persistentVolumeClaim.chartmuseum.storageClass`     | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning | |
|`persistence.persistentVolumeClaim.chartmuseum.subPath`     | The sub path used in the volume | |
|`persistence.persistentVolumeClaim.chartmuseum.accessMode`     | The access mode of the volume | `ReadWriteOnce` |
|`persistence.persistentVolumeClaim.chartmuseum.size`     | The size of the volume | `5Gi` |
|`persistence.persistentVolumeClaim.jobservice.existingClaim`     | Use the existing PVC which must be created manually before bound | |
|`persistence.persistentVolumeClaim.jobservice.storageClass`     | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning | |
|`persistence.persistentVolumeClaim.jobservice.subPath`     | The sub path used in the volume | |
|`persistence.persistentVolumeClaim.jobservice.accessMode`     | The access mode of the volume | `ReadWriteOnce` |
|`persistence.persistentVolumeClaim.jobservice.size`     | The size of the volume | `1Gi` |
|`persistence.persistentVolumeClaim.database.existingClaim`     | Use the existing PVC which must be created manually before bound. If external database is used, the setting will be ignored | |
|`persistence.persistentVolumeClaim.database.storageClass`     | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning. If external database is used, the setting will be ignored | |
|`persistence.persistentVolumeClaim.database.subPath`     | The sub path used in the volume. If external database is used, the setting will be ignored | |
|`persistence.persistentVolumeClaim.database.accessMode`     | The access mode of the volume. If external database is used, the setting will be ignored | `ReadWriteOnce` |
|`persistence.persistentVolumeClaim.database.size`     | The size of the volume. If external database is used, the setting will be ignored | `1Gi` |
|`persistence.persistentVolumeClaim.redis.existingClaim`     | Use the existing PVC which must be created manually before bound. If external Redis is used, the setting will be ignored | |
|`persistence.persistentVolumeClaim.redis.storageClass`     | Specify the `storageClass` used to provision the volume. Or the default StorageClass will be used(the default). Set it to `-` to disable dynamic provisioning. If external Redis is used, the setting will be ignored | |
|`persistence.persistentVolumeClaim.redis.subPath`     | The sub path used in the volume. If external Redis is used, the setting will be ignored | |
|`persistence.persistentVolumeClaim.redis.accessMode`     | The access mode of the volume. If external Redis is used, the setting will be ignored | `ReadWriteOnce` |
|`persistence.persistentVolumeClaim.redis.size`     | The size of the volume. If external Redis is used, the setting will be ignored | `1Gi` |
|`persistence.imageChartStorage.type`     | The type of storage for images and charts: `filesystem`, `azure`, `gcs`, `s3`, `swift` or `oss`. The type must be `filesystem` if you want to use persistent volumes for registry and chartmuseum. Refer to the [guide](https://github.com/docker/distribution/blob/master/docs/configuration.md#storage) for more information about the detail | `filesystem` |
| |
| `externalURL` | The external URL for Harbor core service | `https://core.harbor.domain` |
| `imagePullPolicy` | The image pull policy | `IfNotPresent` |
| `logLevel` | The log level | `debug` |
| `harborAdminPassword`  | The initial password of Harbor admin. Change it from portal after launching Harbor | `Harbor12345` |
| `secretkey` | The key used for encryption. Must be a string of 16 chars | `not-a-secure-key` |
| **Nginx**(if expose the service via `ingress`, the Nginx will not be used) |
| `nginx.image.repository` | Image repository | `goharbor/nginx-photon` |
| `nginx.image.tag` | Image tag | `dev` |
| `nginx.replicas` | The replica count | `1` |
| `nginx.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `nginx.nodeSelector` | Node labels for pod assignment | `{}` |
| `nginx.tolerations` | Tolerations for pod assignment | `[]` |
| `nginx.affinity` | Node/Pod affinities | `{}` |
| `nginx.podAnnotations` | Annotations to add to the nginx pod | `{}` |
| **Portal** |
| `portal.image.repository` | Repository for portal image | `goharbor/harbor-portal` |
| `portal.image.tag` | Tag for portal image | `dev` |
| `portal.replicas` | The replica count | `1` |
| `portal.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `portal.nodeSelector` | Node labels for pod assignment | `{}` |
| `portal.tolerations` | Tolerations for pod assignment | `[]` |
| `portal.affinity` | Node/Pod affinities | `{}` |
| `portal.podAnnotations` | Annotations to add to the portal pod | `{}` |
| **Core** |
| `core.image.repository` | Repository for Harbor core image | `goharbor/harbor-core` |
| `core.image.tag` | Tag for Harbor core image | `dev` |
| `core.replicas` | The replica count | `1` |
| `core.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `core.nodeSelector` | Node labels for pod assignment | `{}` |
| `core.tolerations` | Tolerations for pod assignment | `[]` |
| `core.affinity` | Node/Pod affinities | `{}` |
| `core.podAnnotations` | Annotations to add to the core pod | `{}` |
| **Adminserver** |
| `adminserver.image.repository` | Repository for adminserver image | `goharbor/harbor-adminserver` |
| `adminserver.image.tag` | Tag for adminserver image | `dev` |
| `adminserver.replicas` | The replica count | `1` |
| `adminserver.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `adminserver.nodeSelector` | Node labels for pod assignment | `{}` |
| `adminserver.tolerations` | Tolerations for pod assignment | `[]` |
| `adminserver.affinity` | Node/Pod affinities | `{}` |
| `adminserver.podAnnotations` | Annotations to add to the adminserver pod | `{}` |
| **Jobservice** |
| `jobservice.image.repository` | Repository for jobservice image | `goharbor/harbor-jobservice` |
| `jobservice.image.tag` | Tag for jobservice image | `dev` |
| `jobservice.replicas` | The replica count | `1` |
| `jobservice.maxJobWorkers` | The max job workers | `10` |
| `jobservice.jobLogger` | The logger for jobs: `file`, `database` or `stdout` | `file` |
| `jobservice.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `jobservice.nodeSelector` | Node labels for pod assignment | `{}` |
| `jobservice.tolerations` | Tolerations for pod assignment | `[]` |
| `jobservice.affinity` | Node/Pod affinities | `{}` |
| `jobservice.podAnnotations` | Annotations to add to the jobservice pod | `{}` |
| **Registry** |
| `registry.registry.image.repository` | Repository for registry image | `goharbor/registry-photon` |
| `registry.registry.image.tag` | Tag for registry image | `dev` |
| `registry.controller.image.repository` | Repository for registry controller image | `goharbor/harbor-registryctl` |
| `registry.controller.image.tag` | Tag for registry controller image | `dev` |
| `registry.replicas` | The replica count | `1` |
| `registry.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `registry.nodeSelector` | Node labels for pod assignment | `{}` |
| `registry.tolerations` | Tolerations for pod assignment | `[]` |
| `registry.affinity` | Node/Pod affinities | `{}` |
| `registry.podAnnotations` | Annotations to add to the registry pod | `{}` |
| **Chartmuseum** |
| `chartmuseum.enabled` | Enable chartmusuem to store chart | `true` |
| `chartmuseum.image.repository` | Repository for chartmuseum image | `goharbor/chartmuseum-photon` |
| `chartmuseum.image.tag` | Tag for chartmuseum image | `dev` |
| `chartmuseum.replicas` | The replica count | `1` |
| `chartmuseum.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `chartmuseum.nodeSelector` | Node labels for pod assignment | `{}` |
| `chartmuseum.tolerations` | Tolerations for pod assignment | `[]` |
| `chartmuseum.affinity` | Node/Pod affinities | `{}` |
| `chartmuseum.podAnnotations` | Annotations to add to the chart museum pod | `{}` |
| **Clair** |
| `clair.enabled` | Enable Clair | `true` |
| `clair.image.repository` | Repository for clair image | `goharbor/clair-photon` |
| `clair.image.tag` | Tag for clair image | `dev`
| `clair.replicas` | The replica count | `1` |
| `clair.httpProxy` | The HTTP proxy used to update vulnerabilities database from internet ||
| `clair.httpsProxy` | The HTTPS proxy used to update vulnerabilities database from internet ||
| `clair.updatersInterval` | The interval of clair updaters, the unit is hour, set to 0 to disable the updaters | `12` |
| `clair.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined
| `clair.nodeSelector` | Node labels for pod assignment | `{}` |
| `clair.tolerations` | Tolerations for pod assignment | `[]` |
| `clair.affinity` | Node/Pod affinities | `{}` |
| `clair.podAnnotations` | Annotations to add to the clair pod | `{}` |
| **Notary** |
| `notary.enabled` | Enable Notary? | `true` |
| `notary.server.image.repository` | Repository for notary server image | `goharbor/notary-server-photon` |
| `notary.server.image.tag` | Tag for notary server image | `dev`
| `notary.server.replicas` | The replica count | `1` |
| `notary.signer.image.repository` | Repository for notary signer image | `goharbor/notary-signer-photon` |
| `notary.signer.image.tag` | Tag for notary signer image | `dev`
| `notary.signer.replicas` | The replica count | `1` |
| `notary.nodeSelector` | Node labels for pod assignment | `{}` |
| `notary.tolerations` | Tolerations for pod assignment | `[]` |
| `notary.affinity` | Node/Pod affinities | `{}` |
| `notary.podAnnotations` | Annotations to add to the notary pod | `{}` |
| **Database** |
| `database.type` | If external database is used, set it to `external` | `internal` |
| `database.internal.image.repository` | Repository for database image | `goharbor/harbor-db` |
| `database.internal.image.tag` | Tag for database image | `dev` |
| `database.internal.password` | The password for database | `changeit` |
| `database.internal.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `database.internal.nodeSelector` | Node labels for pod assignment | `{}` |
| `database.internal.tolerations` | Tolerations for pod assignment | `[]` |
| `database.internal.affinity` | Node/Pod affinities | `{}` |
| `database.external.host` | The hostname of external database | `192.168.0.1` |
| `database.external.port` | The port of external database | `5432` |
| `database.external.username` | The username of external database | `user` |
| `database.external.password` | The password of external database | `password` |
| `database.external.coreDatabase` | The database used by core service | `registry` |
| `database.external.clairDatabase` | The database used by clair | `clair` |
| `database.external.notaryServerDatabase` | The database used by Notary server | `notary_server` |
| `database.external.notarySignerDatabase` | The database used by Notary signer | `notary_signer` |
| `database.external.sslmode` | Connection method of external database (require|prefer|disable) | `disable`|
| `database.podAnnotations` | Annotations to add to the database pod | `{}` |
| **Redis** |
| `redis.type` | If external redis is used, set it to `external` | `internal` |
| `redis.internal.image.repository` | Repository for redis image | `goharbor/redis-photon` |
| `redis.internal.image.tag` | Tag for redis image | `dev` |
| `redis.internal.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `redis.internal.nodeSelector` | Node labels for pod assignment | `{}` |
| `redis.internal.tolerations` | Tolerations for pod assignment | `[]` |
| `redis.internal.affinity` | Node/Pod affinities | `{}` |
| `redis.external.host` | The hostname of external Redis | `192.168.0.2` |
| `redis.external.port` | The port of external Redis | `6379` |
| `redis.external.coreDatabaseIndex` | The database index for core | `0` |
| `redis.external.jobserviceDatabaseIndex` | The database index for jobservice | `1` |
| `redis.external.registryDatabaseIndex` | The database index for registry | `2` |
| `redis.external.chartmuseumDatabaseIndex` | The database index for chartmuseum | `3` |
| `redis.external.password` | The password of external Redis | |
| `redis.podAnnotations` | Annotations to add to the redis pod | `{}` |
