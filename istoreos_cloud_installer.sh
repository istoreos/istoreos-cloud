#!/bin/bash

IMAGE=/boot/istoreos.img.gz
GRUB_FILES="/boot/grub/grub.cfg /boot/grub2/grub.cfg /boot/boot/grub.cfg /boot/grub.cfg"

download() {
    [ -f $IMAGE -a -f /boot/istoreos_stage2.sh ] && return 0
    local img=`wget -O- https://fw.koolcenter.com/iStoreOS/x86_64/version.latest | head -1 | sed -E 's/.*\((.+)\).*/\1/'`
    [ -z "$img" ] && exit 1
    wget -O $IMAGE "https://fw.koolcenter.com/iStoreOS/x86_64/$img" || exit 1
}

create_stage2() {
    cat <<-EOF >/boot/istoreos_stage2.sh
#!/bin/bash

IMAGE=$IMAGE

main() {
    mkdir -p /run/tmp
    mount -o remount,ro /
    mount -t tmpfs -o size=256M tmpfs /run/tmp || return 1
    cp -a $IMAGE /run/tmp/istoreos.img.gz || return 1
    zcat /run/tmp/istoreos.img.gz | dd of=/dev/vda bs=1M
    echo
    echo
    echo
    echo "install success, rebooting..."
    echo
    echo
    return 0
}

main && exit 0

echo "install failed!" >&2

exec /bin/bash -i

EOF
    chmod 755 /boot/istoreos_stage2.sh || exit 1
}

modify_grub() {
    grep -sFq 'init=/boot/istoreos_stage2.sh' $GRUB_FILES && return 0
    chmod 644 $GRUB_FILES 2>/dev/null
    sed -s -i -Ee 's,^([ \t]*linux[ \t]+.*$),\1 init=/boot/istoreos_stage2.sh,g' $GRUB_FILES
    if ! grep -qF istoreos_stage2 $GRUB_FILES; then
        echo "不支持的操作系统，请先将系统换成 Debian 或者 Ubuntu 再试." >&2
        echo "Unsupported operating system, please install Debian or Ubuntu first." >&2
        exit 1
    fi
    return 0
}

success() {
    echo -e "\033[92m iStoreOS 安装环境已经准备好! \033[0m"
    echo -e "\033[92m iStoreOS install environment ready! \033[0m"
    echo "你可以打开 VNC 观看安装过程."
    echo "Go VNC to monitor install process."
    echo "将在10秒后自动重启到安装流程，几分钟后 iStoreOS 就会上线."
    echo "We will auto reboot to install process in 10 seconds, iStoreOS will online in few minutes..."
    echo -n "(Press CTRL+C to abort, so you can reboot manually) "

    sleep 10

    echo
    echo -n "rebooting..."
    reboot
    exec sleep 30
}

download && create_stage2 || exit 1

modify_grub

success
