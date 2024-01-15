#!/bin/bash

# Define variables
BACKUP_SRCS=()   # Array to store source directories
BACKUP_DEST=""   # User-specified backup destination
LOG_FILE="backup_log.txt"  # Log file location
TIMESTAMP=$(date +"%Y%m%d%H%M%S")  # Timestamp for unique file naming
COMPRESS_TYPE=""  # Default is no compression, can be overridden by user

# Function to print usage information
print_usage() {
    echo "Usage: $0 -s [source directories] -d [destination directory] [-c compression type]"
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
        s) IFS=',' read -ra BACKUP_SRCS <<< "${OPTARG}";;  # Source directories as comma-separated values
        d) BACKUP_DEST=${OPTARG};;  # Destination directory
        c) COMPRESS_TYPE=${OPTARG};;  # Compression type
        *) print_usage;;
    esac
done

# Ensure all parameters are provided
if [ -z "${BACKUP_SRCS[*]}" ] || [ -z "$BACKUP_DEST" ]; then
    echo "Error: Missing parameters." | tee -a $LOG_FILE
    print_usage
fi

# Validate input directories
for dir in "${BACKUP_SRCS[@]}"; do
    check_directory "$dir"
done

# Check if the destination directory exists; if not, create it
if [ ! -d "$BACKUP_DEST" ]; then
    mkdir -p "$BACKUP_DEST"
    echo "The destination backup path was not found, so it was created." | tee -a "$LOG_FILE"
fi

#check_directory "$BACKUP_DEST"

# Define backup file name with the source directory names, timestamp, and compression type
BACKUP_FILE="$BACKUP_DEST/backup_$(IFS=_; echo "${BACKUP_SRCS[*]}")_$TIMESTAMP"
if [ -n "$COMPRESS_TYPE" ]; then
    BACKUP_FILE="$BACKUP_FILE.$COMPRESS_TYPE"
fi

# Function to perform backup
perform_backup() {
    echo "Starting backup of ${BACKUP_SRCS[*]} to $BACKUP_FILE" | tee -a "$LOG_FILE"

    # Choose compression command based on the user-specified compression type
    if [ -n "$COMPRESS_TYPE" ]; then
        case $COMPRESS_TYPE in
            gz) tar -czf "$BACKUP_FILE.tar.gz" -C "$(dirname "${BACKUP_SRCS[0]}")" "${BACKUP_SRCS[@]##*/}";;
            bz2) tar -cjf "$BACKUP_FILE.tar.bz2" -C "$(dirname "${BACKUP_SRCS[0]}")" "${BACKUP_SRCS[@]##*/}";;
            xz) tar -cJf "$BACKUP_FILE.tar.xz" -C "$(dirname "${BACKUP_SRCS[0]}")" "${BACKUP_SRCS[@]##*/}";;
            zip) zip -r "$BACKUP_FILE.zip" "${BACKUP_SRCS[@]}";;
            tar) tar -cf "$BACKUP_FILE.tar" -C "$(dirname "${BACKUP_SRCS[0]}")" "${BACKUP_SRCS[@]##*/}";;
            7z) 7z a "$BACKUP_FILE.7z" "${BACKUP_SRCS[@]}";;
            rar) rar a "$BACKUP_FILE.rar" "${BACKUP_SRCS[@]}";;
            zst) tar --zstd -cf "$BACKUP_FILE.tar.zst" -C "$(dirname "${BACKUP_SRCS[0]}")" "${BACKUP_SRCS[@]##*/}";;
            lz) tar --lzip -cf "$BACKUP_FILE.tar.lz" -C "$(dirname "${BACKUP_SRCS[0]}")" "${BACKUP_SRCS[@]##*/}";;
            *) echo "Unsupported compression type: $COMPRESS_TYPE" | tee -a "$LOG_FILE"; exit 1;;
        esac
    else
        #tar -cf "$BACKUP_FILE.tar" -C "$(dirname "${BACKUP_SRCS[0]}")" "${BACKUP_SRCS[@]##*/}"
        cp -r "${BACKUP_SRCS[@]}" "$BACKUP_DEST"
    fi

    # Check if backup was successful

if [ $? -eq 0 ]; then
    echo "Backup completed successfully." | tee -a "$LOG_FILE"
    
    # Determine the backup file(s) for calculating size
    if [ -n "$COMPRESS_TYPE" ]; then
        backup_files=("$BACKUP_FILE"*)
    else
        backup_files=("${BACKUP_SRCS[@]##*/}")
    fi
    
    local size
    size=$(du -sh "${backup_files[@]}" | cut -f1)
    echo "Backup file size: $size"| tee -a "$LOG_FILE"
else
    echo "Backup failed. Check log file $LOG_FILE for errors." | tee -a "$LOG_FILE"
    exit 1
fi


}

# Perform the backup
perform_backup "${BACKUP_SRCS[@]}" "$BACKUP_DEST" "$COMPRESS_TYPE"

