# luci-app-autosync

A LuCI application for OpenWrt that provides real-time, one-way directory synchronization using `rsync` and `inotifywait`.

This application allows you to configure multiple synchronization tasks through a user-friendly web interface, with advanced per-task settings and robust logging.

## Features

- **Web UI**: Easy management via the LuCI interface.
- **Multiple Sync Tasks**: Configure multiple source-to-destination sync mappings.
- **Individual Control**: Enable or disable each sync task independently.
- **Per-task Configurable Delay**: Set a sync delay (in seconds) for each task to wait after a file change is detected, preventing sync storms.
- **Per-task Log Files with Rotation**: Each sync task can have its own log file, with automatic rotation (5MB limit).
- **Simplified UI**: Clean and intuitive user interface with English + Chinese field names.
- **Robust Background Service**: Each sync task runs as a separate, monitored process under `procd`, ensuring reliability and automatic restarts.

## Dependencies

Before using this application, you must install the following packages on your OpenWrt device:

- `rsync`
- `inotify-tools` (provides `inotifywait`)

You can install them using `opkg`:

```bash
opkg update
opkg install rsync inotify-tools
```

## Installation

### Method 1: Using OpenWrt Buildroot (Recommended)

1.  Copy the `luci-app-autosync` directory to the `package/` directory of your OpenWrt buildroot.
2.  Select `luci-app-autosync` in the LuCI -> Applications menu via `make menuconfig`.
3.  Build the firmware image.

### Method 2: Install via Git

This is the recommended method for devices with `git` installed.

1.  **Log into your OpenWrt device via SSH.**

2.  **Install `git` if you haven't already:**
    ```bash
    opkg update
    opkg install git git-http
    ```

3.  **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/luci-app-autosync.git /tmp/luci-app-autosync
    ```
    *(Remember to replace `YOUR_USERNAME` with your actual GitHub username)*

4.  **Run the management script:**
    ```bash
    cd /tmp/luci-app-autosync
    sh ./autosync.sh
    ```
    Follow the on-screen menu to choose between installation and uninstallation.

## Uninstallation

To remove the application from your system, run the `autosync.sh` script from the cloned repository directory and select the 'Uninstall' option:

```bash
cd /tmp/luci-app-autosync
sh ./autosync.sh
```

## Configuration

1.  Navigate to **Services -> AutoSync 自动同步** in the LuCI web interface.
2.  **Sync Mappings 同步映射**:
    - Click **Add** to create a new synchronization task.
    - **Enabled**: Check this to activate the individual sync task.
    - **Source Directory 源目录**: The absolute path of the directory to watch for changes.
    - **Destination Directory 目标目录**: The absolute path where the changes will be synced to.
    - **Sync Deletes 同步删除**
    - **Sync Delay (sec) 同步延迟（秒）**
    - **Log File Path 日志文件路径**
3.  Click **Save & Apply**.

## Command-Line Usage

You can manage the service from the command line:

- **Start the service**:
  ```bash
  /etc/init.d/autosync start
  ```
- **Stop the service**:
  ```bash
  /etc/init.d/autosync stop
  ```
- **Restart the service**:
  ```bash
  /etc/init.d/autosync restart
  ```
- **Enable service on boot**:
  ```bash
  /etc/init.d/autosync enable
  ```
- **Disable service on boot**:
  ```bash
  /etc/init.d/autosync disable
  ```

## Troubleshooting

Check the log file (default: `/var/log/autosync.log`) for detailed activity, status messages, and errors.

## License

This project is licensed under the MIT License.
