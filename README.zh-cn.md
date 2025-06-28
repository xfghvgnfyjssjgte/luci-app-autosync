# luci-app-autosync

一个为 OpenWrt 设计的 LuCI 应用，它使用 `rsync` 和 `inotifywait` 提供实时的、单向的目录同步功能。

本应用允许您通过一个友好的 Web 界面来配置多个同步任务，并提供高级的每个任务独立设置和强大的日志功能。

## 功能特性

- **Web UI**: 通过 LuCI 界面轻松管理。
- **多同步任务**: 可配置多个“源目录”到“目标目录”的同步映射。
- **独立控制**: 每个同步任务都可以被独立启用或禁用。
- **每个任务独立配置延迟**: 可为每个任务设置一个同步延迟（秒），在检测到文件变化后等待指定时间再开始同步，以防止“同步风暴”。
- **每个任务独立日志文件及轮替**: 每个同步任务都可以有自己的日志文件，并支持自动轮替（5MB 限制）。
- **简化界面**: 简洁直观的用户界面，字段名称采用“英文 + 中文”显示。
- **可靠的后台服务**: 每个同步任务都作为一个独立的、受 `procd` 监控的进程运行，确保了服务的可靠性和自动重启能力。

## 依赖项

在使用本应用前，您必须在您的 OpenWrt 设备上安装以下软件包：

- `rsync`
- `inotify-tools` (提供 `inotifywait` 命令)

您可以使用 `opkg` 来安装它们：

```bash
opkg update
opkg install rsync inotify-tools
```

## 安装方法

### 方法一：使用 OpenWrt 编译环境 (推荐)

1.  将 `luci-app-autosync` 目录复制到您的 OpenWrt 编译环境的 `package/` 目录下。
2.  通过 `make menuconfig` 进入配置菜单，在 `LuCI -> Applications` 中选中 `luci-app-autosync`。
3.  编译固件镜像。

### 方法二：通过 Git 安装

这是推荐的方法，适用于已安装 `git` 的设备。

1.  **通过 SSH 登录您的 OpenWrt 设备。**

2.  **如果尚未安装 `git`，请先安装：**
    ```bash
    opkg update
    opkg install git git-http
    ```

3.  **克隆仓库：**
    ```bash
    git clone https://github.com/xfghvgnfyjssjgte/luci-app-autosync.git /tmp/luci-app-autosync
    ```
    *(请将 `xfghvgnfyjssjgte` 替换为您的实际 GitHub 用户名)*

4.  **运行管理脚本：**
    ```bash
    cd /tmp/luci-app-autosync
    sh ./autosync.sh
    ```
    按照屏幕上的菜单提示选择安装或卸载。

## 卸载方法

要从您的系统中移除本应用，请在克隆的仓库目录下运行 `autosync.sh` 脚本并选择“卸载”选项：

```bash
cd /tmp/luci-app-autosync
sh ./autosync.sh
```

## 配置步骤

1.  在 LuCI 网页界面中，导航至 **服务 -> AutoSync 自动同步**。
2.  **同步映射 同步映射**:\
    - 点击 **添加** 来创建一个新的同步任务.\
    - **Enabled**: 勾选此项以激活该独立的同步任务.\
    - **Source Directory 源目录**: 需要监视变化的目录的绝对路径.\
    - **Destination Directory 目标目录**: 文件将被同步到的目标位置的绝对路径.\
    - **Sync Deletes 同步删除**\
    - **Sync Delay (sec) 同步延迟（秒）**\
    - **Log File Path 日志文件路径**\
3.  点击 **保存并应用**。

## 命令行管理

您可以通过命令行来管理此服务：

- **启动服务**:\
  ```bash
  /etc/init.d/autosync start
  ```
- **停止服务**:\
  ```bash
  /etc/init.d/autosync stop
  ```
- **重启服务**:\
  ```bash
  /etc/init.d/autosync restart
  ```
- **设置开机自启**:\
  ```bash
  /etc/init.d/autosync enable
  ```
- **禁止开机自启**:\
  ```bash
  /etc/init.d/autosync disable
  ```

## 问题排查

请检查日志文件（默认为 `/var/log/autosync.log`）以获取详细的活动记录、状态信息和错误报告。

## 许可证

本项目采用 MIT 许可证。