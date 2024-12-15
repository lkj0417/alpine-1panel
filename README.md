# 1Panel 安装指南（适用于 Alpine 系统）

本项目提供了一套完整的脚本和步骤，用于在 Alpine 系统中安装和配置 1Panel 面板。

---

## 功能简介

1Panel 是一个功能强大的服务器管理面板。本项目解决了 Alpine 系统安装 1Panel 的相关兼容性问题，包括：

- IPv6-only 环境添加 IPv4 出口。
- 配置 Docker 环境。
- 将 OpenRC 转译为 systemctl。
- 配置 1Panel 启动脚本，确保服务运行稳定。

---

## 使用方法

### 1. 更新系统和安装必要工具

首先，更新 Alpine 系统的软件并安装 `curl` 工具和 `findutils`：

```sh
apk update && apk add curl && apk add findutils
```

### 2. 纯 IPv6 环境先配置 IPv4 出口

在纯 IPv6 环境下，使用项目中的 `menu.sh` 脚本添加 IPv4 出口：

```sh
curl -o menu.sh https://raw.githubusercontent.com/lkj0417/alpine-1panel/main/menu.sh # ipv6可能无法使用，可以自行下载menu.sh上传到服务器
bash menu.sh
```

> **注意：** 确保 `menu.sh` 已在当前目录中。

### 3. 安装 Docker 环境

下载项目中的 `kejilion.sh` 脚本并赋予执行权限，按提示完成 Docker 安装：

```sh
curl -o kejilion.sh https://raw.githubusercontent.com/lkj0417/alpine-1panel/main/kejilion.sh && chmod +x kejilion.sh && bash kejilion.sh
```

### 4. 转译 systemctl 为 OpenRC

下载 `install_systemctl.sh` 脚本并执行，将 systemctl 转译为 OpenRC：

```sh
curl -o install_systemctl.sh https://raw.githubusercontent.com/lkj0417/alpine-1panel/main/install_systemctl.sh && chmod +x install_systemctl.sh && bash install_systemctl.sh
```

### 5. 按照 1Panel 官方方式安装

访问 [1Panel 官方文档](https://www.1panel.cn) 并按照在线安装指南进行操作。

在安装完成后，会发生服务启动失败，请继续以下步骤。

---

## 配置 1Panel 启动脚本

1. **找到 1Panel 主程序路径**

进入 1Panel 解压目录，找到 `1panel` 主程序文件路径。例如：

```sh
/usr/local/1panel/1panel
```

2. **创建 OpenRC 服务脚本**

使用 `vi` 或其他文本编辑工具创建服务脚本：

```sh
vi /etc/init.d/1panel
```

粘贴以下内容：

```sh
#!/sbin/openrc-run

description="1Panel Service"

command="/usr/local/1panel/1panel"  # 根据解压目录1panel文件实际路径调整
command_background="yes"

pidfile="/run/1panel.pid"
```

保存并退出后，为脚本赋予执行权限：

```sh
chmod +x /etc/init.d/1panel
```

3. **添加服务到默认启动项**

运行以下命令将 1Panel 服务添加到 OpenRC 的默认启动项：

```sh
rc-update add 1panel default
```

4. **启动服务**

启动 1Panel 服务：

```sh
rc-service 1panel start
```

5. **验证服务状态**

检查服务是否正常运行：

```sh
rc-service 1panel status
```

如果一切正常，你会看到类似以下输出：

```sh
 * status: started
```

如果顺利可以通过之前安装设置的  ip:端口号/安全路径  登陆1panel面板


如果是纯ipv6环境请使用以下命令打开1panel面板的ipv6监听

```sh
1panel listen-ip ipv6 # 开启面板ipv6监听
rc-service 1panel restart #重启1panel服务
```

---


