# Harbor High Availability Guide

## Goal
Deploy Harbor on K8S via helm to make it highly available, that is, if one of node that has Harbor's container running becomes un accessible. Users does not experience interrupt of service of Harbor.

## Prerequisites
- Kubernetes cluster 1.10+
- Helm 2.8.0+
- High available ingress controller (Harbor does not manage the external endpoint)
- High available PostgreSQL database (Harbor does not handle the deployment of HA of database)
- High available Redis (Harbor does not handle the deployment of HA of Redis)
- PVC that can be shared across nodes. Users can use `StorageClass` on K8S cluster for dynamically provision or use the existing PVC.
- External object storage for storing image and chart data(optional, PVC can be used for storing)

## Architecture
Most of Harbor's components are stateless now.  So we can simply increase the replica of the pods to make sure the components are distributed to multiple worker nodes, and leverage the "Service" mechanism of K8S to ensure the connectivity across pods.

As for storage layer, it is expected that the user provide high available PostgreSQL, Redis cluster for application data and object storage for storing image.

![HA](img/ha.png)

## Installation

### Download Chart
Download Harbor helm chart code.
```bash
git clone https://github.com/goharbor/harbor-helm
cd harbor-helm
```

### Configuration
Configure the followings items in `values.yaml`, you can also set them as parameters via `--set` flag during running `helm install`:
- **Ingress rule**  
   Configure the `ingree.hosts.core` and `ingree.hosts.notary`.
- **External URL**  
   Configure the `externalURL`.
- **External PostgreSQL**  
   Set the `database.type` to `external` and fill the information in `database.external` section.  
   
   Four empty databases should be created manually for `Harbor core`, `Clair`, `Notary server` and `Notary signer` and configure them in the section. Harbor will create tables automatically when starting up.
- **External Redis**  
   Set the `redis.type` to `external` and fill the information in `redis.external` section.  

   As the Redis client used by Harbor's upstream projects doesn't support `Sentinel`, Harbor can only work with a single entrypoint Redis. 
- **Storage**   
   By default, a default `StorageClass` is needed in the K8S cluster to provision PVCs to store images, charts and job logs.  

   If you want to specify the `StorageClass`, uncomment and set `registry.volumes.data.storageClass`, `chartmuseum.volumes.data.storageClass` and `jobservice.volumes.data.storageClass`.  

   You can also use the existing PVCs to store data. Uncomment and set `registry.volumes.data.existingClaim`, `chartmuseum.volumes.data.existingClaim` and `jobservice.volumes.data.existingClaim`.  

   Cloud storage also can be used to store images and charts. Set the `storage.type` to the value you want to use and fill the corresponding section. Notes: PVC is also needed to store job logs.

- **Replica**   
   Set `portal.replicas`, `adminserver.replicas`, `core.replicas`, `jobservice.replicas`, `registry.replicas`, `chartmuseum.replicas`, `clair.replicas`, `notary.server.replicas` and `notary.signer.replicas` to `n`(`n`>=2).

### Installation
Install the Harbor helm chart with a release name `my-release`:
```bash
helm install --name my-release .
```

