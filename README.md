System Health Check Script

Overview

This Bash script performs a system health check, examining critical parameters such as disk space usage, memory usage, running services, and recent system updates. The results are logged to a file, and recommendations are provided based on the check results.

Features

- Check and display disk space usage.
- Display memory usage in a human-readable format.
- List running services, accommodating both systemd and older systems.
- Check for recent system updates and report the last update timestamp.
- Provide custom recommendations based on the health check results.

Getting Started

Prerequisites

- This script is intended for use on Unix-like operating systems (Linux).
- Ensure that the required commands (`df`, `free`, `systemctl`, `service`, `grep`, `tail`, `awk`) are available on your system.

Usage

1. Clone the repository or download the script to your local machine.

    ```bash
    $ git clone https://github.com/your-username/system-health-check.git
    $ cd system-health-check
    ```

2. Make the script executable.

    ```bash
    $ chmod +x system_health_check.sh
    ```

3. Run the script.

    ```bash
    $ ./system_health_check.sh
    ```

Configuration

Customize the script by adjusting the values of `DISK_THRESHOLD` and `MEMORY_THRESHOLD` to set the critical thresholds for disk and memory usage.

*******************************************************************************************************************************************************************
Backup Script

Overview

This script is designed to backup user-specified directories with various compression options.

Usage

```bash
./backup_script.sh -s [source directories] -d [destination directory] -c [compression type]
```

- `-s`: Source directory (multiple directories can be specified).
- `-d`: Destination directory for the backup.
- `-c`: Compression type (options: gz, bz2, xz, zip, tar, 7z, rar, zst, lz).

Example

```bash
./backup_script.sh -s /path/to/source -d /path/to/destination -c gz
```

Options

- Source Directory (`-s`):
  - Specify the source directory or directories to be backed up.

- Destination Directory (`-d`):
  - Specify the destination directory where the backup will be stored.

- Compression Type (`-c`):
  - Choose the compression type for the backup file. Supported options: gz, bz2, xz, zip, tar, 7z, rar, zst, lz.

Log File

The script generates a log file named `backup_log.txt` to record information about the backup process.

Important Note

Ensure that you have the necessary permissions to read from the source directories and write to the destination directory.

Author
Rashed Al-Qatarneh
