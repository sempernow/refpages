# Trivy : [Docs](https://aquasecurity.github.io/trivy/v0.52/docs/) | [Trivy image](https://hub.docker.com/r/aquasec/trivy "hub.docker.com")

## Scan a container image for CVEs

Workflow:

```bash
img='python:3.4-alpine3.9'

# Download DB
trivy image --download-db-only

# Scan a container image 
trivy image $img

```

### Other scans and commands

```bash
# Scan a container image only for CVEs (faster; does not search for secrets)
trivy image --skip-db-update --scanners vuln $img

# Scan K8s cluster (experimental)
trivy k8s --report summary

# Scan host filesystem path for secrets
trivy fs /path/to/project

# Scan a remote repo
trivy repo https://github.com/aquasecurity/trivy-ci-test

# Scan a virtual machine image
trivy vm --scanners vuln disk.vmdk

# Scan AWS machine image
trivy vm ami:$ami_id

# Scan AWS EBS snapshot
trivy vm ebs:$ebs_snapshot_id

# Remove DBs
trivy image --reset

```


## Scan a container image from a Trivy container

Use the Trivy container image instead of installing Trivy on the host:

 ```bash
trivy_image=aquasec/trivy:0.52.2
target_image=registry.local:5000/rhel:ubi9

docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /tmp/trivy:/root/.cache/ \
    $trivy_image \
        image --scanners vuln \
        $target_image \
        |& tee trivy.scan.log
```
- `--rm` : Delete container upon completion.
- `-v /var/...` : Bind mount to host's Docker-server socket.
- `-v /tmp/...` : Bind mount to an empty host store to persist Trivy's DB download(s).


### Advanced Configuration 

Wanting to run containerized Trivy scans from WSL2
by declaring Docker's listening socket instead of mounting it,
we reconfigure the Docker daemon to listen at `eth0` of WSL2 host
instead of its nominal (systemd set) configuration.

#### 1. Get address 

```bash
ip -4 -brief addr # show dev eth0

    # lo               UNKNOWN        127.0.0.1/8 10.255.255.254/32
    # eth0             UP             172.25.164.157/20
    # docker0          DOWN           172.17.0.1/16
```

#### 2. Create/mod the Docker Engine configuration:

@ `/etc/docker/daemon.json`

```json
{
  "hosts": [
    "tcp://172.25.164.157:2375",
    "unix:///var/run/docker.sock"
    ]
}
```

Verify the configuation file

```bash
sudo systemctl stop docker.service
sudo dockerd --config-file /etc/docker/daemon.json
```

#### 3. Mod its systemd service configuration via drop-in file 

This method leaves the default unit file unaltered, 
which is advised for managing systemd unit-file configurations.

>Remove the `-H fd://` flag, which is used to tell Docker to listen on a socket activated by systemd. We rather declared its listening socket by above method (`/etc/docker/daemon.json`).

```bash
# Override the default unit file by adding a drop-in file
sudo mkdir -p /etc/systemd/system/docker.service.d
cat <<-EOH |sudo tee /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock
EOH
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl status docker

``` 

Now Trivy can be run by declaring the socket instead of mounting it.

```bash
trivy_image=aquasec/trivy:0.52.2
target_image=registry.local:5000/rhel:ubi9

docker run --rm \
    -v /tmp/trivy:/root/.cache/ \
    $trivy_image image \
        --scanners vuln \
        --docker-host tcp://172.25.164.157:2375 \
        $target_image \
        |& tee trivy.scan.log
```