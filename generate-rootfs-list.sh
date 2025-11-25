#!/bin/bash
# Generate rootfs file lists for analysis and comparison

set -e
#set -x

# --- Default Configuration ---
PRODUCT="unknown"                         # Product name (e.g., hornet, hornet_flexible, hornet_cooper, any...)
SCRIPT_DIR=$(dirname "$0")                # Directory where this script is located
DATETIME=$(date +%F_%H%M%S)               # Timestamp for log files (YYYY-MM-DD_HHMMSS)
GIT_HASH="unknown"                        # Git SHA-1 hash (populated later if in git repo)
ROOTFS_DIR=""                             # Target rootfs directory (set after option parsing)

# --- Functions ---

# Print formatted log output with aligned colons
# Args: $1 = label, $2 = filename
print_log() {
	local label="$1"
	local filename="$2"
	local max_label_width=10  # Length of longest label ("total_size")
	local padding=$((max_label_width - ${#label} + 1))  # +1 for minimum one space
	printf "Log (%s)%*s: %s\n" "$label" "$padding" "" "$filename"
}

# Calculate and display partition capacity analysis
# Args: $1 = rootfs_size (in bytes)
print_capacity_analysis() {
	local rootfs_size=$1
	local rootfs_size_mb=$((rootfs_size / 1024 / 1024))

	# Upper bound: 620 MB (AMBOOT_LNX_SIZE)
	local upper_bound_mb=620
	local upper_bound_bytes=$((upper_bound_mb * 1024 * 1024))
	local usage_percentage="0.00"

	if [ "$upper_bound_bytes" -gt 0 ] && [ "$rootfs_size" -gt 0 ]; then
		usage_percentage=$(awk "BEGIN {printf \"%.2f\", ($rootfs_size / $upper_bound_bytes) * 100}")
	fi

	echo ""
	echo "=== Partition Capacity Analysis ==="
	echo "Upper Bound: ${upper_bound_mb} MB (${upper_bound_bytes} bytes)"
	echo "Current Usage: ${rootfs_size_mb} MB / ${upper_bound_mb} MB"
	echo "Usage Percentage: ${usage_percentage}%"
	echo "Remaining Space: $((upper_bound_mb - rootfs_size_mb)) MB"
}

# Display usage information and help text
usage() {
	cat << EOF

Generate rootfs file lists for analysis and comparison

Usage: $0 [OPTIONS] <rootfs_directory>

OPTIONS:
    -h              Show this help message
    -p <product>    Set PRODUCT value (default: $PRODUCT)
    -o <path>       Set custom output directory for logs

ARGUMENTS:
    <rootfs_directory>  Path to the rootfs directory to scan

EXAMPLES:
    $0 /path/to/fakeroot
    $0 -p hornet_cooper /path/to/fakeroot
    $0 -o /tmp/logs /path/to/fakeroot

EOF
}

# Generate a comprehensive recursive file listing with permissions, ownership, and sizes
generate_rootfs_general() {
	local log_filename="$LOG_DIR/$PRODUCT-rootfs_general_${DATETIME}_${GIT_HASH}.txt"

	# Use ls -lR to get detailed file information, remove timestamps for consistency
	eval "ls -lR * > $log_filename"

	print_log "general" "$log_filename"
}

# Generate a sorted file list with size (bytes) and full paths, for rootfs analysis
generate_rootfs_size() {
	local log_filename="$LOG_DIR/$PRODUCT-rootfs_size_${DATETIME}_${GIT_HASH}.txt"

	# Sort by size in descending order
	# Use find to list all regular files with their sizes in bytes
	# and sort the output in descending order by size
	find . -type f -printf '%s\t%p\n' | sed 's|./|/|' | sort -n -r > "$log_filename"

	print_log "size" "$log_filename"
}

# Generate a file list with MD5 checksums and file metadata
# TODO: improve our repo with this: SOURCE_DATE_EPOCH
#       https://reproducible-builds.org/docs/source-date-epoch/
generate_rootfs_md5() {
	local log_filename="$LOG_DIR/$PRODUCT-rootfs_md5_${DATETIME}_${GIT_HASH}.txt"

	# Find all regular files in the current directory tree
	find . -type f | while read -r file; do
		# Calculate MD5 checksum for each file
		read -r md5 _ < <(md5sum "$file")
		# Extract file metadata and combine with MD5
		printf '%s %s\n' "$md5" "$file" >> "$log_filename"
	done

	print_log "md5" "$log_filename"
}

# Generate a simple sorted list of all files and directories
generate_rootfs_file() {
	local log_filename="$LOG_DIR/$PRODUCT-rootfs_file_${DATETIME}_${GIT_HASH}.txt"

	# Find all files/dirs, convert ./ to / and . to /, then sort
	find . | sed 's|^\./|/|' | sed 's|^\.$|/|' | sort > "$log_filename"

	print_log "file" "$log_filename"
}

# Generate a simple sorted list of all files, symlinks and directories
generate_rootfs_file_symlink() {
	local log_filename="$LOG_DIR/$PRODUCT-rootfs_file_symlink_${DATETIME}_${GIT_HASH}.txt"

	# Find all files/dirs, convert ./ to / and . to /, then sort and show -> when it's a symlink
	find . | while read -r path; do
		if [ -L "$path" ]; then
			target=$(readlink "$path")
			echo "$path -> $target"
		else
			echo "$path"
		fi
	done | sed -e 's|^\./|/|' -e 's|^\.$|/|' | sort > "$log_filename"

	print_log "symlink" "$log_filename"
}

# Generate rootfs total size information based on build type (flexible/cooper)
generate_rootfs_total_size() {
	local log_filename="$LOG_DIR/$PRODUCT-rootfs_total_size_${DATETIME}_${GIT_HASH}.txt"

	# Extract AMBA_SDK type from PRODUCT (format: ${CAMERA_TYPE}_${REVISION}_${AMBA_SDK})
	local amba_sdk_type=$(echo "$PRODUCT" | sed 's/.*_\([^_]*\)$/\1/')
	local camera_type=$(echo "$PRODUCT" | cut -d'_' -f1)
	local rootfs_path=""

	{
		echo "=== Rootfs Total Size Information ==="
		echo "Generated: $(date)"
		echo "Product: $PRODUCT"
		echo "Git Hash: $GIT_HASH"
		echo "Build Type: $amba_sdk_type"
		echo "Camera Type: $camera_type"
		echo ""

		# Determine rootfs path and base path based on build type
		local base_path=""
		local rootfs_subpath=""
		local build_name=""

		if [[ "$amba_sdk_type" == "flexible" ]]; then
			# For flexible builds, derive OUT_DIR from input ROOTFS_DIR
			# ROOTFS_DIR is OUT_DIR/fakeroot, where OUT_DIR = .../ambarella/out/${BOARD}
			# So ROOTFS_DIR/.. = OUT_DIR which already contains the platform path
			local out_dir=$(realpath "$ROOTFS_DIR/..")
			rootfs_path="${out_dir}/rootfs/ext4"
			build_name="Flexible Build"
		elif [[ "$amba_sdk_type" == "cooper" ]]; then
			# For Cooper builds, extract platform directory from ROOTFS_DIR path
			# ROOTFS_DIR: .../yocto_out/cv25_camera/tmp/work/cv25_camera-poky-linux/ipcam-image/1.0-r0/rootfs
			# Extract everything before /tmp/work/ to get platform directory
			local platform_dir="${ROOTFS_DIR%/tmp/work/*}"
			rootfs_path="${platform_dir}/images/rootfs.bin"
			build_name="Cooper Build"
		else
			echo "Unknown build type: $amba_sdk_type"
			return
		fi
		echo "${build_name} Rootfs Path: $rootfs_path"

		# Handle file or symlink
		local actual_file="$rootfs_path"
		if [ -L "$rootfs_path" ]; then
			# Follow symlink to get actual file
			actual_file=$(readlink -f "$rootfs_path")
			echo "Symlink: $rootfs_path -> $actual_file"
		fi

		if [ -f "$actual_file" ]; then
			rootfs_size=$(stat -c%s "$actual_file" 2>/dev/null || echo "0")
			rootfs_size_mb=$((rootfs_size / 1024 / 1024))
			echo "Binary Size: $rootfs_size bytes (${rootfs_size_mb} MB)"
			print_capacity_analysis "$rootfs_size"
		else
			echo "Rootfs file not found: $rootfs_path"
		fi


	} > "$log_filename"

	print_log "total_size" "$log_filename"
}

# Generate manifest file listing all rootfs files
generate_rootfs_manifest() {
	local log_filename="$LOG_DIR/$PRODUCT-rootfs_manifest.txt"

	{
		echo "# Rootfs analysis manifest"
		echo "# Generated on: $(date)"
		echo "# Product: $PRODUCT"
		echo "# Git Hash: $GIT_HASH"
		echo "# Timestamp: $DATETIME"
		echo ""
		echo "# Filenames (relative to artifacts directory)"
		echo "file_symlink=${PRODUCT}-rootfs_file_symlink_${DATETIME}_${GIT_HASH}.txt"
		echo "file=${PRODUCT}-rootfs_file_${DATETIME}_${GIT_HASH}.txt"
		echo "size=${PRODUCT}-rootfs_size_${DATETIME}_${GIT_HASH}.txt"
		echo "total_size=${PRODUCT}-rootfs_total_size_${DATETIME}_${GIT_HASH}.txt"
		echo "general=${PRODUCT}-rootfs_general_${DATETIME}_${GIT_HASH}.txt"
		echo "md5=${PRODUCT}-rootfs_md5_${DATETIME}_${GIT_HASH}.txt"
	} > "$log_filename"

	print_log "manifest" "$log_filename"
}

# --- Main Logic ---

main() {
	# Parse command line options
	while getopts "hp:o:" OPTION
	do
		case "$OPTION" in
		h)
			usage
			exit 0
			;;
		p)
			PRODUCT="$OPTARG"  # Set custom product name
			;;
		o)
			LOG_DIR="$OPTARG"  # Set custom output directory
			;;
		*)
			echo "Error: Invalid option" >&2
			usage
			exit 2
			;;
		esac
	done
	shift $((OPTIND - 1))

	# Check if rootfs directory argument is provided
	if [ $# -ne 1 ]; then
		echo "Error: Missing rootfs directory argument." >&2
		usage
		exit 2
	fi

	ROOTFS_DIR="$1"

	# Validate that the rootfs directory exists
	if [ ! -d "$ROOTFS_DIR" ]; then
		echo "Error: Directory '$ROOTFS_DIR' not found." >&2
		exit 1
	fi

	# Set default log directory if not specified via -o option
	if [ -z "${LOG_DIR:-}" ]; then
		LOG_DIR="$(realpath "$SCRIPT_DIR")/.log/rootfs-list"
	fi

	# Create log directory if it doesn't exist
	mkdir -p "$LOG_DIR" || exit 3

	# Change to the target rootfs directory
	cd "$ROOTFS_DIR" || exit 4

	# Generate rootfs file list in general format (permissions, ownership, sizes)
	generate_rootfs_general

	# Generate a sorted file list with size (bytes) and full paths, for rootfs analysis
	generate_rootfs_size

	# Generate rootfs file list in md5sum format (checksums + metadata)
	generate_rootfs_md5

	# Generate plain rootfs file list (just file/directory paths)
	generate_rootfs_file

	# Generate plain rootfs file list (just file/symlink/directory paths)
	generate_rootfs_file_symlink

	# Generate rootfs total size information
	generate_rootfs_total_size

	# Generate manifest file with all generated filenames
	generate_rootfs_manifest
}

main "$@"

