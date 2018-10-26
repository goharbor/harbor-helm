# Helm Chart for Harbor

**Notes:** The master branch is in heavy development, please use the codes on other branch instead.

## Introduction

This [Helm](https://github.com/kubernetes/helm) chart installs [Harbor](https://github.com/goharbor/harbor) in a Kubernetes cluster. Welcome to [contribute](CONTRIBUTING.md) to Helm Chart for Harbor.

## Prerequisites

- Kubernetes cluster 1.10+ with Beta APIs enabled
- Kubernetes Ingress Controller is enabled
- Helm 2.8.0+

## Installing the Chart

Download Harbor helm chart code.
```bash
git clone https://github.com/goharbor/harbor-helm
```
Checkout the branch.
```bash
cd harbor-helm
git checkout branch_name
```
Install the Harbor helm chart with a release name `my-release`:
```bash
helm install --name my-release .
```

The command deploys Harbor on the Kubernetes cluster with the default configuration.
The [configuration](#configuration) section lists the parameters that can be configured in values.yaml or via `--set` flag during installation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the Harbor chart and the default values.

| Parameter                  | Description                        | Default                 |
| -----------------------    | ---------------------------------- | ----------------------- |
| **Harbor** |
| `persistence.enabled`     | Persistent data | `true` |
| `persistence.resourcePolicy`     | Setting it to "keep" to avoid removing PVCs during a helm delete operation. Leaving it empty will delete PVCs after the chart deleted | `keep` |
| `externalURL`       | Ther external URL for Harbor core service | `https://core.harbor.domain` |
| `harborAdminPassword`  | The password of system admin | `Harbor12345` |
| `secretkey` | The key used for encryption. Must be a string of 16 chars | `not-a-secure-key` |
| `imagePullPolicy` | The image pull policy | `IfNotPresent` |
| **Ingress** |
| `ingress.enabled` | Enable ingress objects | `true` |
| `ingress.hosts.core` | The host of Harbor core service in ingress rule | `core.harbor.domain` |
| `ingress.hosts.notary` | The host of Harbor notary service in ingress rule | `notary.harbor.domain` |
| `ingress.annotations` | The annotations used in ingress | `true` |
| `ingress.labels` | The custom labels to use in ingress | `true` |
| `ingress.tls.enabled` | Enable TLS | `true` |
| `ingress.tls.secretName` | Fill the secretName if you want to use the certificate of yourself when Harbor serves with HTTPS. A certificate will be generated automatically by the chart if leave it empty |
| `ingress.tls.notarySecretName` | Fill the notarySecretName if you want to use the certificate of yourself when Notary serves with HTTPS. if left empty, it uses the `ingress.tls.secretName` value |
| **Portal** |
| `portal.image.repository` | Repository for portal image | `goharbor/harbor-portal` |
| `portal.image.tag` | Tag for portal image | `dev` |
| `portal.replicas` | The replica count | `1` |
| `portal.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `portal.nodeSelector` | Node labels for pod assignment | `{}` |
| `portal.tolerations` | Tolerations for pod assignment | `[]` |
| `portal.affinity` | Node/Pod affinities | `{}` |
| **Authentication** |
| `auth.mode` | The type of authentication that is used | `db_auth` |
| `auth.self_registration` | Enable / Disable the ability for a user to register himself/herself. When disabled, new users can only be created by the Admin user. When auth.mode is set to ldap_auth, self-registration feature is always disabled, and this flag is ignored | `off` |
| `auth.ldap.url` | The LDAP endpoint URL | `ldaps://ldap.domain` |
| `auth.ldap.searchDn` | The DN of a user who has the permission to search an LDAP/AD server | `uid=admin,ou=people,dc=mydomain,dc=com` |
| `auth.ldap.searchPassword` | The password of the user specified by ldap.search_dn | `search_password` |
| `auth.ldap.baseDn` | The base DN to look up a user | `ou=people,dc=mydomain,dc=com` |
| `auth.ldap.filter` | The search filter for looking up a user | `objectClass=person` |
| `auth.ldap.userUid` | The attribute used to match a user during a LDAP search | `sAMAccountName` |
| `auth.ldap.searchScope` | The scope to search for a user, 0-LDAP_SCOPE_BASE, 1-LDAP_SCOPE_ONELEVEL, 2-LDAP_SCOPE_SUBTREE | `2` |
| `auth.ldap.timeout` | The timeout limit when requesting the LDAP | `5` |
| `auth.ldap.verifyCert` | Whether the LDAP certificate should be verified or not| `true` |
 **Email** |
| `email.host` | The hostname of email server | `smtp.mydomain.com` |
| `email.port` | The port of email server | `25` |
| `email.username` | The username of email server | `sample_admin@mydomain.com` |
| `email.password` | The password for email server | `unsecure_password` |
| `email.ssl` | Whether use TLS | `false` |
| `email.from` | The from address shown when send email| `admin <sample_admin@mydomain.com>` |
| `email.identity` | | |
| `email.insecure` | Whether the connection with email server is insecure | `false` |
| **Adminserver** |
| `adminserver.image.repository` | Repository for adminserver image | `goharbor/harbor-adminserver` |
| `adminserver.image.tag` | Tag for adminserver image | `dev` |
| `adminserver.replicas` | The replica count | `1` |
| `adminserver.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `adminserver.nodeSelector` | Node labels for pod assignment | `{}` |
| `adminserver.tolerations` | Tolerations for pod assignment | `[]` |
| `adminserver.affinity` | Node/Pod affinities | `{}` |
| **Jobservice** |
| `jobservice.image.repository` | Repository for jobservice image | `goharbor/harbor-jobservice` |
| `jobservice.image.tag` | Tag for jobservice image | `dev` |
| `jobservice.replicas` | The replica count | `1` |
| `jobservice.volumes` | The volume used to store data if persistence is enabled | |
| `jobservice.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `jobservice.nodeSelector` | Node labels for pod assignment | `{}` |
| `jobservice.tolerations` | Tolerations for pod assignment | `[]` |
| `jobservice.affinity` | Node/Pod affinities | `{}` |
| **Core** |
| `core.image.repository` | Repository for Harbor core image | `goharbor/harbor-core` |
| `core.image.tag` | Tag for Harbor core image | `dev` |
| `core.replicas` | The replica count | `1` |
| `core.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `core.nodeSelector` | Node labels for pod assignment | `{}` |
| `core.tolerations` | Tolerations for pod assignment | `[]` |
| `core.affinity` | Node/Pod affinities | `{}` |
| **Database** |
| `database.type` | If external database is used, set it to `external` | `internal` |
| `database.internal.image.repository` | Repository for database image | `goharbor/harbor-db` |
| `database.internal.image.tag` | Tag for database image | `dev` |
| `database.internal.password` | The password for database | `changeit` |
| `database.internal.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `database.internal.volumes` | The volume used to persistent data |
| `database.internal.nodeSelector` | Node labels for pod assignment | `{}` |
| `database.internal.tolerations` | Tolerations for pod assignment | `[]` |
| `database.internal.affinity` | Node/Pod affinities | `{}` |
| `database.external.host` | The hostname of external database | `192.168.0.1` |
| `database.external.port` | The port of external database | `5432` |
| `database.external.username` | The username of external database | `user` |
| `database.external.password` | The password of external database | `password` |
| `database.external.coreDatabase` | The database used by core service | `registry` |
| `database.external.sslmode` | Connection method of external database (require|prefer|disable) | `disable`|
| `database.external.clairDatabase` | The database used by clair | `clair` |
| `database.external.notaryServerDatabase` | The database used by Notary server | `notary_server` |
| `database.external.notarySignerDatabase` | The database used by Notary signer | `notary_signer` |
| **Registry** |
| `registry.registry.image.repository` | Repository for registry image | `goharbor/registry-photon` |
| `registry.registry.image.tag` | Tag for registry image | `dev` |
| `registry.registry.logLevel` | The log level | `info` |
| `registry.controller.image.repository` | Repository for registry controller image | `goharbor/harbor-registryctl` |
| `registry.controller.image.tag` | Tag for registry controller image | `dev` |
| `registry.replicas` | The replica count | `1` |
| `registry.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `registry.volumes` | used to create PVCs if persistence is enabled (see instructions in values.yaml) | see values.yaml |
| `registry.nodeSelector` | Node labels for pod assignment | `{}` |
| `registry.tolerations` | Tolerations for pod assignment | `[]` |
| `registry.affinity` | Node/Pod affinities | `{}` |
| **Chartmuseum** |
| `chartmuseum.enabled` | Enable chartmusuem to store chart | `true` |
| `chartmuseum.image.repository` | Repository for chartmuseum image | `goharbor/chartmuseum-photon` |
| `chartmuseum.image.tag` | Tag for chartmuseum image | `dev` |
| `chartmuseum.replicas` | The replica count | `1` |
| `chartmuseum.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `chartmuseum.volumes` | used to create PVCs if persistence is enabled (see instructions in values.yaml) | see values.yaml |
| `chartmuseum.nodeSelector` | Node labels for pod assignment | `{}` |
| `chartmuseum.tolerations` | Tolerations for pod assignment | `[]` |
| `chartmuseum.affinity` | Node/Pod affinities | `{}` |
| **Storage For Registry And Chartmuseum** |
| `storage.type` | The storage backend used for registry and chartmuseum: `filesystem`, `azure`, `gcs`, `s3`, `swift`, `oss` | `filesystem` |
| `other values` | The other values please refer to https://github.com/docker/distribution/blob/master/docs/configuration.md#storage |  |
| **Clair** |
| `clair.enabled` | Enable Clair? | `true` |
| `clair.image.repository` | Repository for clair image | `goharbor/clair-photon` |
| `clair.image.tag` | Tag for clair image | `dev`
| `clair.replicas` | The replica count | `1` |
| `clair.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined
| `clair.nodeSelector` | Node labels for pod assignment | `{}` |
| `clair.tolerations` | Tolerations for pod assignment | `[]` |
| `clair.affinity` | Node/Pod affinities | `{}` |
| **Redis** |
| `redis.type` | If external redis is used, set it to `external` | `internal` |
| `redis.internal.image.repository` | Repository for redis image | `goharbor/redis-photon` |
| `redis.internal.image.tag` | Tag for redis image | `dev` |
| `redis.internal.resources` | [resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to allocate for container   | undefined |
| `redis.internal.volumes` | The volume used to persistent data |
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

## Persistence

By default, the Harbor persistents the data in a few of persistent volumes. The volumes are created using dynamic volume provisioning. If you want to use the existing persistent volume claims, specify them during installation.

When running a cluster without persistence, set the  `persistence.enabled` as `false`. Data does not survive the termination of a pod.
