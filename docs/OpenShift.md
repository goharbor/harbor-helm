---
title: Harbor on OpenShift Guide
---

## Overview

This guide provides instructions for deploying Harbor on OpenShift Container Platform (OCP) and OKD. While Harbor's Helm chart is designed to work with standard Kubernetes clusters, OpenShift has some specific requirements and configurations that need to be addressed for a successful deployment.

## Prerequisites

- OpenShift Container Platform 4.10+ or OKD
- Helm v3.2.0+
- Cluster admin permissions (for configuring Security Context Constraints)
- A StorageClass for persistent volumes

## Key Differences from Standard Kubernetes

OpenShift has several differences from standard Kubernetes that affect Harbor deployment:

1. **Security Context Constraints (SCC)**: OpenShift enforces stricter pod security policies
2. **Routes vs Ingress**: OpenShift uses Routes natively, though it also supports Ingress resources
3. **Default TLS Termination**: OpenShift Routes can provide automatic TLS termination
4. **Pod Security Standards**: Newer OpenShift versions enforce restricted pod security standards

## Installation

### Step 1: Add Harbor Helm Repository

```bash
helm repo add harbor https://helm.goharbor.io
helm repo update
```

### Step 2: Configure Security Context Constraints

Harbor requires elevated privileges for some operations. You need to configure appropriate Security Context Constraints.

#### For OpenShift 4.10-4.13:

```bash
oc adm policy add-scc-to-user anyuid -z default -n <harbor-namespace>
```

#### For OpenShift 4.14+ (with seccomp profiles):

OpenShift 4.14 and later enforce seccomp profiles. You need to create a custom SCC or use the following commands:

```bash
# Create a custom SCC with seccomp support
oc get scc anyuid -o yaml | sed 's/anyuid/anyuid-seccomp/g;/uid:/d;/creationTimestamp/d;/generation/d;/resourceVersion/d' | oc create -f -

# Add seccomp profile
oc patch scc anyuid-seccomp --type=merge -p '{"seccompProfiles":["runtime/default"]}'

# Assign the SCC to the default service account
oc adm policy add-scc-to-user anyuid-seccomp -z default -n <harbor-namespace>
```

**Note**: The above configuration uses `anyuid` SCC. For production environments, review your security requirements and potentially create a more restrictive custom SCC based on Harbor's specific needs.

Source: [Red Hat Solution 7064000](https://access.redhat.com/solutions/7064000)

### Step 3: Create a values.yaml File

Create a `values.yaml` file with OpenShift-specific configurations. Choose one of the following exposure methods:

#### Option A: Using Ingress (Recommended)

OpenShift automatically creates Routes from Ingress resources. This is the recommended approach as it's more portable across Kubernetes distributions.

**With OpenShift Default TLS Certificate:**

```yaml
expose:
  type: ingress
  tls:
    enabled: false  # Disable Harbor's TLS, rely on OpenShift Route TLS
  ingress:
    hosts:
      core: harbor.your-domain.com
    annotations:
      route.openshift.io/termination: "edge"  # Edge termination at the route

externalURL: https://harbor.your-domain.com
```

**With Custom TLS Certificate (via Secret):**

```yaml
expose:
  type: ingress
  tls:
    enabled: true
    certSource: secret
    secret:
      secretName: harbor-tls-secret  # Your TLS secret
  ingress:
    hosts:
      core: harbor.your-domain.com

externalURL: https://harbor.your-domain.com
```

**With Internal TLS and Re-encryption:**

If you're using Harbor's internal TLS, use re-encryption:

```yaml
expose:
  type: ingress
  tls:
    enabled: true
    certSource: secret
    secret:
      secretName: harbor-tls-secret
  ingress:
    hosts:
      core: harbor.your-domain.com
    annotations:
      route.openshift.io/termination: "reencrypt"
      # Optional: specify destination CA if needed
      # route.openshift.io/destination-ca-certificate-secret: "harbor-internal-ca"

internalTLS:
  enabled: true
  certSource: auto  # or secret

externalURL: https://harbor.your-domain.com
```

#### Option B: Using LoadBalancer

```yaml
expose:
  type: loadBalancer
  tls:
    enabled: true
    certSource: auto
  loadBalancer:
    name: harbor

externalURL: https://harbor.your-domain.com
```

### Step 4: Configure Storage

Configure persistent storage for Harbor components:

```yaml
persistence:
  persistentVolumeClaim:
    registry:
      storageClass: "<your-storage-class>"
      size: 100Gi
    database:
      storageClass: "<your-storage-class>"
      size: 10Gi
    redis:
      storageClass: "<your-storage-class>"
      size: 5Gi
    trivy:
      storageClass: "<your-storage-class>"
      size: 5Gi
```

Alternatively, use external storage (S3-compatible, Azure, GCS) for the registry:

```yaml
persistence:
  imageChartStorage:
    type: s3
    s3:
      region: us-east-1
      bucket: harbor-images
      # ... other S3 configuration
```

### Step 5: Install Harbor

Create a namespace and install Harbor:

```bash
# Create namespace
oc new-project harbor

# Install Harbor
helm install harbor harbor/harbor -f values.yaml -n harbor
```

## Common Issues and Troubleshooting

### Issue 1: Pod Security Violations

**Symptoms:**
```
would violate PodSecurity "restricted:v1.24": allowPrivilegeEscalation != false, 
unrestricted capabilities, runAsNonRoot != true, seccompProfile
```

**Solution:**
Apply the appropriate Security Context Constraint as described in Step 2 above. For OpenShift 4.14+, ensure you're using the `anyuid-seccomp` SCC.

### Issue 2: Routes Not Created

**Symptoms:**
When using `expose.type: ingress`, no OpenShift Routes are automatically created.

**Solution:**
OpenShift should automatically create Routes from Ingress resources. Verify:
- The Ingress resources are created: `oc get ingress -n harbor`
- Check OpenShift router logs if Routes aren't created
- Ensure your `externalURL` matches the `expose.ingress.hosts.core` value

### Issue 3: Database Goes into Recovery Mode

**Symptoms:**
PostgreSQL pod shows "database system is in recovery mode" when pushing large images.

**Solutions:**
1. **Increase database resources:**
   ```yaml
   database:
     internal:
       resources:
         requests:
           memory: 2Gi
           cpu: 1000m
         limits:
           memory: 4Gi
           cpu: 2000m
   ```

2. **Use external PostgreSQL database** (recommended for production):
   ```yaml
   database:
     type: external
     external:
       host: postgres.example.com
       port: 5432
       username: harbor
       password: <password>
       coreDatabase: registry
       notaryServerDatabase: notary_server
       notarySignerDatabase: notary_signer
   ```

3. **Ensure adequate storage I/O performance** - Use a high-performance StorageClass

### Issue 4: Image Push Fails with "unknown blob" Error

**Symptoms:**
`docker push` completes but returns "unknown blob" error.

**Possible Causes and Solutions:**
1. **Storage backend issues**: Check registry storage configuration and connectivity
2. **Network policies**: Ensure pods can communicate with the registry backend
3. **Registry storage permissions**: Verify the registry pod has write permissions to storage

### Issue 5: Certificate Issues

**Symptoms:**
- "x509: certificate signed by unknown authority"
- SSL/TLS errors when pushing/pulling images

**Solutions:**
1. **Add Harbor's CA certificate to trusted certificates on client machines**
2. **For self-signed certificates**, configure Docker daemon to trust Harbor's certificate:
   ```bash
   # On the client machine
   mkdir -p /etc/docker/certs.d/harbor.your-domain.com
   cp ca.crt /etc/docker/certs.d/harbor.your-domain.com/
   ```
3. **For S3 storage with self-signed certs**, ensure the registry pod trusts the S3 endpoint certificate

## Production Considerations

### High Availability

For production deployments on OpenShift, consider:

1. **External Database**: Use a managed PostgreSQL service or deploy PostgreSQL with replication
2. **External Redis**: Use Redis Sentinel or a managed Redis service
3. **External Storage**: Use S3-compatible storage, Azure Blob, or GCS instead of PVCs
4. **Multiple Replicas**: Scale Harbor components:
   ```yaml
   portal:
     replicas: 3
   core:
     replicas: 3
   jobservice:
     replicas: 3
   registry:
     replicas: 3
   ```

Refer to the [High Availability Guide](High%20Availability.md) for detailed HA configuration.

### Resource Limits

Set appropriate resource limits based on your workload:

```yaml
# Example resource configuration
core:
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits:
      memory: 512Mi
      cpu: 500m

registry:
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits:
      memory: 512Mi
      cpu: 500m
```

### Monitoring

OpenShift provides built-in monitoring with Prometheus. Harbor exposes metrics that can be scraped:

```yaml
metrics:
  enabled: true
  core:
    path: /metrics
    port: 8001
  registry:
    path: /metrics
    port: 8001
```

## Upgrading Harbor on OpenShift

When upgrading Harbor on OpenShift:

1. **Backup your data**: Back up the database and registry storage
2. **Review release notes**: Check for OpenShift-specific changes
3. **Test in non-production**: Validate the upgrade in a test environment
4. **Use Helm upgrade**:
   ```bash
   helm repo update
   helm upgrade harbor harbor/harbor -f values.yaml -n harbor
   ```

Refer to the [Upgrade Guide](Upgrade.md) for detailed upgrade instructions.

## Additional Resources

- [Harbor Documentation](https://goharbor.io/docs)
- [OpenShift Documentation](https://docs.openshift.com/)
- [Harbor Helm Chart Issues](https://github.com/goharbor/harbor-helm/issues?q=is%3Aissue+label%3Aenv%2Fopenshift)

## Related GitHub Issues

For community discussions and solutions specific to OpenShift deployments, see:
- [Feature Request: Include OCP route as way to expose (#2264)](https://github.com/goharbor/harbor-helm/issues/2264)
- [Harbor Installation: Pod Security issue in OpenShift 4.15 (#1757)](https://github.com/goharbor/harbor-helm/issues/1757)
- [Deploy Harbor on OpenShift (#1253)](https://github.com/goharbor/harbor-helm/issues/1253)

## Community Contributions

This guide is based on community experiences and contributions. If you encounter issues or have solutions not covered here, please contribute by:
- Opening an issue in the [harbor-helm repository](https://github.com/goharbor/harbor-helm/issues)
- Submitting a pull request to improve this documentation
