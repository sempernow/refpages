#!/usr/bin/env bash
################################################
# Provision CRI for K8s (idempotent)
################################################
# >>>  ALIGN apps VERSIONs with K8s version  <<<
################################################
ARCH=$(uname -m)
[[ $ARCH ]] || ARCH=amd64
[[ $ARCH = aarch64 ]] && ARCH=arm64
[[ $ARCH = x86_64  ]] && ARCH=amd64

REGISTRY="${CNCF_REGISTRY_ENDPOINT:-registry.k8s.io}"

unset _flag_configure
disableContainerd(){
    _flag_configure=1
    systemctl is-active containerd.service >/dev/null 2>&1 &&
        sudo systemctl disable --now containerd.service
}
export -f disableContainerd

ok(){
    # Install runc (containerd dependency) else fail
    # https://github.com/opencontainers/runc/releases
    # https://github.com/containerd/containerd/blob/main/docs/getting-started.md
    ver='1.2.2'
    [[ $(runc -v 2>&1 |grep $ver) ]] && return 0 
    disableContainerd
    arch=${ARCH:-amd64}
    url="https://github.com/opencontainers/runc/releases/download/v${ver}/runc.$arch"
    dst=/usr/local/sbin
    sudo curl -o $dst/runc -sSL $url &&
        sudo chmod 0755 $dst/runc ||
            return 11
    [[ $(runc -v 2>&1 |grep $ver) ]] || return 12
}
ok || exit $?

ok(){
    # Install containerd binaries else fail
    # https://github.com/containerd/containerd/blob/main/docs/getting-started.md
    # https://github.com/containerd/containerd/releases
    #ver='2.0.0' # Breaking changes : See keys & version of /etc/containerd/config.toml
    ver='1.7.24'
    arch=${ARCH:-amd64}
    tarball="containerd-${ver}-linux-${arch}.tar.gz"
    [[ $(containerd --version 2>&1 |grep v$ver) ]] && return 0
    disableContainerd
    base=https://github.com/containerd/containerd/releases/download/v$ver
    curl -sSL $base/$tarball |sudo tar -C /usr/local -xz || return 20
    [[ $(containerd --version 2>&1 |grep v$ver) ]] || return 21
}
ok || exit $?

ok(){
    # Configure containerd for K8s CRI @ /etc/containerd/config.toml
    # https://github.com/containerd/containerd/blob/main/docs/cri/config.md
    # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

    ## Local (insecure) registry perhaps :
    registry=$REGISTRY

    conf=/etc/containerd/config.toml
    [[ -f $conf ]] && return 0
    disableContainerd
    sudo mkdir -p /etc/containerd
    
    ## Select : default | minimal | custom

	default(){
        containerd config default |sudo tee $conf
    }
    #default 

    minimal(){
		cat <<-EOH |sudo tee $conf
        ## Configured for K8s : runc, systemd cgroup
		version = 2
		[plugins]
		  [plugins."io.containerd.grpc.v1.cri"]
		    sandbox_image = "registry.k8s.io/pause:3.9"
		    [plugins."io.containerd.grpc.v1.cri".containerd]
		      discard_unpacked_layers = true
		      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
		        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
		          runtime_type = "io.containerd.runc.v2"
		          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
		            SystemdCgroup = true
		EOH
    }
    minimal

    custom(){
        cat <<-EOH |sudo tee $conf
        ## Configured for K8s : runc, systemd, and local insecure registry 
        version = 2
        [plugins]
          [plugins."io.containerd.grpc.v1.cri"]
            sandbox_image = "$registry/pause:3.9"
            [plugins."io.containerd.grpc.v1.cri".containerd]
              discard_unpacked_layers = true
              [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
                [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
                  runtime_type = "io.containerd.runc.v2"
                  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
                    SystemdCgroup = true
            [plugins."io.containerd.grpc.v1.cri".registry]
              [plugins."io.containerd.grpc.v1.cri".registry.configs]
                [plugins."io.containerd.grpc.v1.cri".registry.configs."$registry"]
                  endpoint = ["http://$registry"]
                  [plugins."io.containerd.grpc.v1.cri".registry.configs."$registry".tls]
                    insecure_skip_verify = true
		EOH
    }
    #custom

    [[ $(sudo cat $conf |grep $registry) ]] || return 30
}
ok || exit $?

ok(){
    # Configure containerd as a systemd service else fail
    url=https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
    sys=/usr/lib/systemd/system
    [[ -f $sys/containerd.service ]] && return 0
    disableContainerd
    sudo mkdir -p $sys
    sudo curl -o $sys/containerd.service -sSL $url || return 40
}
ok || exit $?

ok(){
    # Enable/start containerd.service if (re)configured
    [[ $_flag_configure ]] &&
        sudo systemctl daemon-reload &&
        	sudo systemctl enable --now containerd.service
		#sudo /usr/local/bin/containerd migrate &&
    # Validate config else fail
    registry=${REGISTRY:-k8s.registry.io}
    [[ $(containerd config dump |grep $registry) ]] || return 50
	systemctl is-active containerd || return 55
}
ok || exit $?

ok(){
    # Install CRI tools (cri-tools) alse fail
    # https://github.com/kubernetes-sigs/cri-tools?tab=readme-ov-file#install 
    ver='v1.29.0'
    arch=${ARCH:-amd64}
    base="https://github.com/kubernetes-sigs/cri-tools/releases/download/$ver"
    suffix="${ver}-linux-${arch}.tar.gz"

    sbin=/usr/local/sbin
    [[ $(crictl --version 2>&1 |grep $ver) ]] ||
        curl -sSL "$base/crictl-$suffix" |sudo tar -C $sbin -xz

    [[ $(critest --version 2>&1 |grep $ver) ]] ||
        curl -sSL "$base/critest-$suffix" |sudo tar -C $sbin -xz

    bin=/usr/local/bin
    [[ $(crictl --version 2>&1 |grep $ver) ]] &&
        sudo ln -sf $sbin/crictl $bin ||
            return 60

    [[ $(critest --version 2>&1 |grep $ver) ]] &&
        sudo ln -sf $sbin/critest $bin ||
            return 61

    # Default behavior is depricated; declare endpoints
    # https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md
    conf=/etc/crictl.yaml
    [[ -f $conf ]] && return 0
	cat <<-EOH |sudo tee $conf
	runtime-endpoint: unix:///run/containerd/containerd.sock
	image-endpoint: unix:///run/containerd/containerd.sock
	timeout: 2
	debug: false
	pull-image-on-create: false
	EOH
}
ok || exit $?
