# SHWriteJson

**Structured JSON Logger for Bash Scripts**

`SHWriteJson` is a lightweight shell-based logging utility that emits structured JSON logs directly to `journald` using `systemd-cat`. It's built for system administrators, operations teams, and automation engineers who demand consistent, machine-readable logs from scripts and system tasks.

---

## 📦 Features

- ✅ JSON-formatted output
- 📄 Integrates with `systemd-journald`
- 🏷️ Custom log tag and event type
- 💬 Flexible message field
- 🔁 Supports external log forwarding via rsyslog
- 📊 Designed for CI, cron jobs, patch pipelines & backups
- 🛠️ Pure Bash – no external dependencies

---

## 🚀 Usage

```bash
SHWriteJson [server] [action] [result] [message] [service] [tag] [event_type]
````

### Example

```bash
SHWriteJson "$(hostname)" "rotate" "success" "Backup rotated" \
  "backup-job" "log-backup" "maintenance"
```

This logs a structured message to `journald` tagged as `log-backup`.

---

## 🧾 Parameters

| Parameter    | Description                                            | Default             |
| ------------ | ------------------------------------------------------ | ------------------- |
| `server`     | Hostname or system name                                | `$(hostname)`       |
| `action`     | Operation performed (e.g. `install`, `restart`)        | `"unspecified"`     |
| `result`     | Result of the action (`success`, `failure`, etc.)      | `"undefined"`       |
| `message`    | Human-readable description                             | `"generic event"`   |
| `service`    | Component/script/service identifier                    | `"generic-service"` |
| `tag`        | systemd-cat tag (used for journald/syslog routing)     | `"generic-logger"`  |
| `event_type` | Logical classification of the event (`sync`, `deploy`) | `"generic-event"`   |

---

## 📤 Output Format

The function writes the following JSON structure:

```json
{
  "timestamp": "2025-07-20T13:37:00+02:00",
  "event_type": "sync",
  "service": "rsync",
  "server": "alpha-node01",
  "action": "push",
  "result": "success",
  "message": "Sync job to backup target completed",
  "script_version": "v1.1"
}
```

---

## 🧩 Customization

### Script Version Tagging

Export `SCRIPT_VERSION` to include script version in logs:

```bash
export SCRIPT_VERSION="v2.1"
```

### Modify Output

To include fields like `user`, `pid`, or `exit_code`, edit the function:

```bash
local user="${USER:-unknown}"
local pid="$$"
```

And add to the JSON payload:

```bash
"user":"$user","pid":"$pid"
```

---

## 🔁 Forwarding to Remote Syslog Server (via rsyslogd)

You can forward all or filtered `SHWriteJson` logs to a central syslog server.

### 1. Enable journald → rsyslog forwarding

Edit `/etc/systemd/journald.conf`:

```ini
ForwardToSyslog=yes
```

Restart journald:

```bash
sudo systemctl restart systemd-journald
```

### 2. Configure rsyslog

Edit `/etc/rsyslog.d/90-remote.conf`:

```bash
# Forward all logs to remote server via TCP (recommended)
*.* @@syslog.example.com:514
```

```

Replace `syslog.example.com` with your remote log receiver.

### 3. Restart rsyslog

```bash
sudo systemctl restart rsyslog
```

### 4. Test It

```bash
SHWriteJson "$(hostname)" "test" "success" "Syslog test" "syslog-test" "log-backup" "test-event"
```

Check the remote log server for incoming entries.

---

## 🔍 View Logs

Use `journalctl` for inspection:

```bash
journalctl -t log-backup -o json-pretty
```

Filter by time:

```bash
journalctl -t log-backup --since "1 hour ago"
```

Filter failures:

```bash
journalctl -t log-backup | jq 'select(.result != "success")'
```

---

## 📥 Installation

Add to your script directly or source it:

```bash
source ./SHWriteJson.sh
```

Or install globally (e.g., `/usr/local/bin/SHWriteJson.sh` and source it from `/etc/profile.d/`).

---

## ✅ Requirements

* Bash 4+
* `systemd-cat` (included in `systemd`)
* journald & optionally rsyslogd
* Linux (Debian, RHEL, Ubuntu, Arch, etc.)
