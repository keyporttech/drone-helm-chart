# Drone.io

[Drone](http://readme.drone.io/) is a Continuous Integration platform built on container technology.

This is a rework of the official [https://github.com/helm/charts/tree/master/stable/drone](https://github.com/helm/charts/tree/master/stable/drone) chart to support drone 1.0.  This was necessary, because changes 1.0 changes made it incompatible with the current chart.  THIS IS USING an PRERELEASE version (like much of kubernetes) so use at your own risk.

## TL;DR;

```console
$ helm install jfelten/drone
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/drone
```

local install

## Customizing the chart example

Use a custom values file:
```console
$ helm install --name my-release stable/drone --values customValues.yaml
```
customValues.yaml:
```yaml
images:
  server:
    tag: 1.0.0-rc.3
  agent:
    tag: 1.0.0-rc.3

server:
  host: "https://drone.lab2.keyporttech.com:8243"
  env:
    DRONE_KUBERNETES_NAMESPACE: drone
    DRONE_GITHUB_SERVER: https://github.com
    #DRONE_SERVER_HOST: drone.lab2.keyporttech.com:8243
    DRONE_SERVER_PROTO: http
    DRONE_DATABASE_DRIVER: postgres
  envSecrets:
    DRONE_DATABASE_DATASOURCE: postgres://postgres:password@host:5432/postgres?sslmode=disable
    DRONE_GITHUB_CLIENT_ID: abcdefghijklmnopqrstuvwxyz
    DRONE_GITHUB_CLIENT_SECRET: abcdefghijklmnopqrstuvwxyz
    DRONE_RPC_SECRET: 1234567890abcdefg

ingress:
  enabled: true

  ## annotations used by the ingress - ex for k8s nginx ingress controller:
  hosts:
    - drone.example.com
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/ingress.allow-http: "false"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required - foo"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  tls:
    - secretName: tls-drone
      hosts:
        - 'drone.example.com'

  # TODO:// create a permanent volume for this
persistence:
  enabled: true
  storageClass: myStorageClass
```
## Persistent storage

Persistent Storage works similar to other charts where if a storage class is specified it generates a pvc. The chart can also use an existing claim created outside of the chart via persistence.existingClaim.

For bare metal environments it may be preferable to attach directly to a storage volume. This can be done via persistence.directVolumeMount. Example:

```yaml
persistence:
  enabled: true
  directVolumeMount: |-
    glusterfs:
      endpoints: glusterfs
      path: drone
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes nearly all the Kubernetes components associated with the
chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the drone charts and their default values.

| Parameter                   | Description                                                                                   | Default                     |
|-----------------------------|-----------------------------------------------------------------------------------------------|-----------------------------|
| `images.server.repository`  | Drone **server** image                                                                        | `docker.io/drone/drone`     |
| `images.server.tag`         | Drone **server** image tag                                                                    | `0.8.9`                     |
| `images.server.pullPolicy`  | Drone **server** image pull policy                                                            | `IfNotPresent`              |
| `service.annotations`       | Service annotations                                                                           | `{}`                        |
| `service.httpPort`          | Drone's Web GUI HTTP port                                                                     | `80`                        |
| `service.nodePort`          | If `service.type` is `NodePort` and this is non-empty, sets the http node port of the service | `32015`                     |
| `service.type`              | Service type (ClusterIP, NodePort or LoadBalancer)                                            | `ClusterIP`                 |
| `ingress.enabled`           | Enables Ingress for Drone                                                                     | `false`                     |
| `ingress.annotations`       | Ingress annotations                                                                           | `{}`                        |
| `ingress.hosts`             | Ingress accepted hostnames                                                                    | `nil`                       |
| `ingress.tls`               | Ingress TLS configuration                                                                     | `[]`                        |
| `server.host`               | Drone **server** scheme and hostname                                                          | `(internal hostname)`       |
| `server.env`                | Drone **server** environment variables                                                        | `(default values)`          |
| `server.envSecrets`         | Drone **server** secret environment variables                                                 | `(default values)`          |
| `server.annotations`        | Drone **server** annotations                                                                  | `{}`                        |
| `server.resources`          | Drone **server** pod resource requests & limits                                               | `{}`                        |
| `server.schedulerName`      | Drone **server** alternate scheduler name                                                     | `nil`                       |
| `server.affinity`           | Drone **server** scheduling preferences                                                       | `{}`                        |
| `server.nodeSelector`       | Drone **server** node labels for pod assignment                                               | `{}`                        |
| `server.extraContainers`    | Additional sidecar containers                                                                 | `""`                        |
| `server.extraVolumes`       | Additional volumes for use in extraContainers                                                 | `""`                        |                      |
| `metrics.prometheus.enabled` | Enable Prometheus metrics endpoint                                                          | `false`                     |
| `persistence.enabled`       | Use a PVC to persist data                                                                     | `true`                      |
| `persistence.existingClaim` | Use an existing PVC to persist data                                                           | `nil`                       |
| `persistence.storageClass`  | Storage class of backing PVC                                                                  | `nil`                       |
| `persistence.accessMode`    | Use volume as ReadOnly or ReadWrite                                                           | `ReadWriteOnce`             |
| `persistence.size`          | Size of data volume                                                                           | `1Gi`                       |
| `persistence.directVolumeMount`          | yaml config to connect directly to storage instead of creating a pvc - see example volume                                                                           | `1Gi`                       |
| `rbac.create`               | Specifies whether RBAC resources should be created.                                           | `true`                      |
| `rbac.apiVersion`           | RBAC API version                                                                              | `v1`                        |
| `serviceAccount.create`     | Specifies whether a ServiceAccount should be created.                                         | `true`                      |
| `serviceAccount.name`       | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template. | `(fullname template)` |
