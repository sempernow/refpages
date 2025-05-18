#!/usr/bin/env bash
################################################
# Helm CLI : Install
################################################
v=v3.17.3
what=linux-amd64
url=https://get.helm.sh/helm-$v-$what.tar.gz
type -t helm > /dev/null 2>&1 &&
    helm version |grep $v > /dev/null 2>&1 || {
        echo '  INSTALLing helm'
        curl -sSfL $url |tar -xzf - &&
            sudo install $what/helm /usr/local/bin/ &&
                rm -rf $what &&
                    echo ok || echo ERR : $?
    }
