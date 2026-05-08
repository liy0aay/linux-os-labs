# Linux OS Labs

Repository with Bash scripts for Linux text processing, process management, systemd service control, and filesystem versioning.

## Repository Structure

### `01-text-processing`

- `log_analyzer.sh <syslog_file> <xorg_log_file>`
  - extracts `INFO` messages from syslog into `info.log`
  - extracts `(WW)` and `(II)` lines from Xorg log into `full.log`
- `extract_emails.sh [target_dir]`
  - recursively finds unique email addresses (default: `/etc`)
  - writes a comma-separated list to `emails.lst`
- `bash_word_freq.sh [man_page] [top_n]`
  - shows top frequent words (length >= 4) from a man page
  - defaults: `bash`, top `3`

### `02-process-management`

- `cpu_burst_analyzer.sh [output_file]`
  - reads `/proc/*/{sched,status}`
  - computes per-process average running time and per-parent aggregates
  - default output: `cpu_burst_with_avg.txt`
- `renice_long_running.sh <min_age_seconds> [nice_increment]`
  - increases nice value for processes older than threshold
  - prints oldest processes with current nice values
- `kill_short_lived.sh <max_age_seconds> [log_file]`
  - sends `SIGTERM` to processes younger than threshold
  - logs terminated PIDs (default: `killed.log`)

### `03-systemd-daemon`

- `watcher.sh`
  - FIFO-based background watcher with signal handlers (`TERM`, `INT`, `HUP`, `USR1`, `USR2`)
  - uses `/tmp/watcher_fifo`, `/tmp/watcher.log`, `/tmp/watcher.pid` by default
- `control.sh {start|stop|status}`
  - local wrapper to control `watcher.sh`
- `watcher.service`
  - sample systemd unit file
  - `ExecStart` currently points to `/opt/watcher/watcher.sh`; update the path for your system

### `04-filesystem-vcs`

- `fileversion`
  - lightweight file versioning with hard links and JSON metadata
  - commands:
    - `init <file>`
    - `commit <file> [comment]`
    - `restore <file> <version|latest>`
  - stores data in `~/.fileversions/<basename>/`


## Quick Start

```bash
chmod +x 01-text-processing/*.sh 02-process-management/*.sh 03-systemd-daemon/*.sh 04-filesystem-vcs/fileversion
```

Examples:

```bash
./01-text-processing/bash_word_freq.sh bash 10
./01-text-processing/extract_emails.sh /etc
./02-process-management/cpu_burst_analyzer.sh results.txt
./03-systemd-daemon/control.sh start
./04-filesystem-vcs/fileversion init ./README.md
```

