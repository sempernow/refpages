#!/usr/bin/env bash
# etcd, etcdctl, etcdutl : https://github.com/etcd-io/etcd 
# Install all 3 binaries of a release 
# Releases : https://github.com/etcd-io/etcd/releases/

## Prep

# @ https://github.com/etcd-io/etcd/releases/tag/v3.5.9
ETCD_VER=v3.5.9

### Choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GITHUB_URL}

tmpdir=/tmp/etcd-io
rm -rf $tmpdir
mkdir $tmpdir

## Download and extract to $tmpdir

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz \
    -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz \
    && tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C $tmpdir --strip-components=1 

## Install from $tmpdir to /usr/bin/

printf "%s\n" etcd etcdctl etcdutl |xargs -IX /bin/bash -c \
    '
        [[ -f $0/$1 ]] && sudo mv $0/$1 /usr/bin/$1 \
            && sudo chown root:root /usr/bin/$1
    ' $tmpdir X

## Verify

ls -Ahl /usr/bin/etc*

etcd --version
etcdctl version
etcdutl version

## Exit

exit
## Server/Client (etcd/etcdctl) USAGE:

### Start a local etcd server
etcd # Toggle: CTRL-z / fg
### Write, read to etcd
etcdctl --endpoints=localhost:2379 put foo bar
etcdctl --endpoints=localhost:2379 get foo