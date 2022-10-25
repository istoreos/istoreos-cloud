#!/bin/bash

do_install() {
    rm -f /tmp/istoreos_cloud_installer.sh 2>/dev/null
    wget -O/tmp/istoreos_cloud_installer.sh https://raw.githubusercontent.com/istoreos/istoreos-cloud/main/istoreos_cloud_installer.sh || exit 1
    chmod 755 /tmp/istoreos_cloud_installer.sh || exit 1
    if [ "$USER" = "root" ]; then
        /tmp/istoreos_cloud_installer.sh
    else
        sudo /tmp/istoreos_cloud_installer.sh
    fi
}

do_install
