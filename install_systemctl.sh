#!/bin/sh

# 检查脚本是否以 root 用户身份运行
if [ $(id -u) -ne 0 ]; then
  echo "请以 root 身份运行此脚本！"
  exit 1
fi

# 更新包管理器和安装必要依赖
echo "更新包管理器并安装必要的工具..."
apk update && apk add --no-cache openrc bash

# 确保 OpenRC 正确初始化
echo "初始化 OpenRC 配置..."
rc-status
if [ $? -ne 0 ]; then
  openrc boot
fi

# 创建 systemctl 模拟脚本
echo "创建 systemctl 模拟脚本..."
cat << 'EOF' > /usr/local/bin/systemctl
#!/bin/sh

# Helper function to print usage
print_usage() {
    echo "Unsupported systemctl command: $1"
    echo "Supported commands: start, stop, restart, reload, status, enable, disable, is-enabled, is-active, show, list-units"
    exit 1
}

case "$1" in
    start)
        rc-service "$2" start
        ;;
    stop)
        rc-service "$2" stop
        ;;
    restart)
        rc-service "$2" restart
        ;;
    reload)
        rc-service "$2" reload || echo "Service $2 does not support reload; attempting restart" && rc-service "$2" restart
        ;;
    status)
        rc-service "$2" status
        ;;
    enable)
        rc-update add "$2"
        ;;
    disable)
        rc-update del "$2"
        ;;
    is-enabled)
        if rc-update show | grep -q "^$2"; then
            echo "enabled"
        else
            echo "disabled"
            exit 1
        fi
        ;;
    is-active)
        if rc-service "$2" status | grep -q "started"; then
            echo "active"
        else
            echo "inactive"
            exit 1
        fi
        ;;
    show)
        echo "OpenRC does not support 'show' directly. Check service files in /etc/init.d or /etc/conf.d."
        ;;
    list-units)
        rc-update show
        ;;
    *)
        print_usage "$1"
        ;;
esac
EOF

# 为脚本赋予执行权限
chmod +x /usr/local/bin/systemctl

echo "systemctl 模拟脚本已安装完成！"

# 测试安装结果
echo "测试 systemctl 模拟脚本功能..."
systemctl list-units
if [ $? -eq 0 ]; then
  echo "systemctl 模拟脚本安装成功！"
else
  echo "systemctl 模拟脚本安装失败，请检查环境配置！"
fi
