#!/bin/bash


# Define variables
BACKUP_SRC=""  # Will be set based on user input
BACKUP_DEST=""  # User-specified backup destination
LOG_FILE="backup_log.txt"  # Log file location
TIMESTAMP=$(date +"%Y%m%d%H%M%S")  # Timestamp for unique file naming
COMPRESS_TYPE="gz"  # Default compression type, can be overridden by user

# Function to print usage information
print_usage() {
    echo "Usage: $0 -s [source directories] -d [destination directory] -c [compression type]"
    echo "Available compression types: gz, bz2, xz, zip, tar, 7z, rar, zst, lz"
    exit 1
}

# Function to check if a directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Error: Directory $1 does not exist. Please check the path." | tee -a "$LOG_FILE"
        print_usage
        exit 1
    fi
}

# Parse command-line options
while getopts s:d:c: flag 
do
    case "${flag}" in
        s) BACKUP_SRC=${OPTARG};;  # Source directory
        d) BACKUP_DEST=${OPTARG};;  # Destination directory
        c) COMPRESS_TYPE=${OPTARG};;  # Compression type
        *) print_usage;;
    esac
done

# Ensure all parameters are provided
if [ -z "$BACKUP_SRC" ] || [ -z "$BACKUP_DEST" ] || [ -z "$COMPRESS_TYPE" ]; then
    echo "Error: Missing parameters." | tee -a $LOG_FILE
    print_usage
fi

# Validate input directories
check_directory "$BACKUP_SRC"

 # Check if the destination directory exists; if not, create it
if [ ! -d "$BACKUP_DEST" ]; then
    mkdir -p "$BACKUP_DEST"
    echo "The destination backup path was not found, so it was created." | tee -a "$LOG_FILE"
fi
 
 #check_directory "$BACKUP_DEST"


# Define backup file name with the source directory name, timestamp, and compression type
BACKUP_FILE="$BACKUP_DEST/backup_$(basename $BACKUP_SRC)_$TIMESTAMP.$COMPRESS_TYPE"

# Function to perform backup
perform_backup() {
    echo "Starting backup of $BACKUP_SRC to $BACKUP_FILE" | tee -a "$LOG_FILE"

    # Choose compression command based on the user-specified compression type
    case $COMPRESS_TYPE in
        gz) tar -czf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC")" "$(basename "$BACKUP_SRC")";;
        bz2) tar -cjf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC")" "$(basename "$BACKUP_SRC")";;
        xz) tar -cJf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC")" "$(basename "$BACKUP_SRC")";;
        zip) zip -r "$BACKUP_FILE" "$BACKUP_SRC";;
        tar) tar -cf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC")" "$(basename "$BACKUP_SRC")";;
        7z) 7z a "$BACKUP_FILE" "$BACKUP_SRC";;
        rar) rar a "$BACKUP_FILE" "$BACKUP_SRC";;
        zst) tar --zstd -cf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC")" "$(basename "$BACKUP_SRC")";;
        lz) tar --lzip -cf "$BACKUP_FILE" -C "$(dirname "$BACKUP_SRC")" "$(basename "$BACKUP_SRC")";;
        *) echo "Unsupported compression type: $COMPRESS_TYPE" | tee -a "$LOG_FILE"; exit 1;;
    esac

    # Check if backup was successful
    if [ $? -eq 0 ]; then
        echo "Backup completed successfully." | tee -a "$LOG_FILE"
        local size
        size=$(du -sh "$BACKUP_FILE" | cut -f1)
        echo "Backup file size: $size" | tee -a "$LOG_FILE"
    else
        echo "Backup failed. Check log file $LOG_FILE for errors." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Perform the backup
perform_backup "$BACKUP_SRC" "$BACKUP_DEST" "$COMPRESS_TYPE"

