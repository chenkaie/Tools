#!/usr/bin/env bash
# Mirror SOURCE -> DEST
# - If DEST is a local path: use rsync (FULL clone with --delete)
# - If DEST starts with gs:// : use gsutil rsync (FULL clone with -d)
# Usage:
#   rsync-backup.sh <SOURCE> <DEST> [--dry-run]
# Examples:
#   rsync-backup.sh /data/projects /mnt/backup/projects
#   rsync-backup.sh /data/projects gs://team-taiwan-shared/backup/kent
#   rsync-backup.sh /data/projects gs://bucket/path --dry-run

set -Eeuo pipefail

# ===== Args =====
if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <SOURCE> <DEST> [--dry-run]"
  exit 1
fi

SOURCE="$1"
DEST="$2"
THIRD_ARG="${3:-}"

# ===== Settings =====
LOG_DIR="/var/log/rsync-backup"
RUN_NICE=10
RUN_IONICE_CLASS=2
RUN_IONICE_PRIO=7
EXCLUDES_FILE=""   # optional: e.g. /etc/rsync-backup.exclude (one pattern per line)

# ===== Derived =====
TS="$(date +'%Y%m%d-%H%M%S')"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/rsync-backup_${TS}.log"

LOCK_DIR="/var/lock"
mkdir -p "$LOCK_DIR"
LOCK_FILE="${LOCK_DIR}/rsync-backup.lock"

DRYRUN=0
if [[ "$THIRD_ARG" == "--dry-run" || "${DRY_RUN:-0}" == "1" ]]; then
  DRYRUN=1
fi

# ===== Helpers =====
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE" ; }
die() { log "ERROR: $*"; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

# ===== Safety checks =====
[[ -d "$SOURCE" ]] || die "SOURCE does not exist or is not a directory: $SOURCE"
SOURCE_WITH_SLASH="${SOURCE%/}/"

is_gs_dest=0
if [[ "$DEST" =~ ^gs:// ]]; then
  is_gs_dest=1
  require_cmd gsutil
else
  # Local path destination safety
  [[ -e "$DEST" ]] || mkdir -p "$DEST"
  [[ -d "$DEST" ]] || die "DEST is not a directory: $DEST"
  [[ "$DEST" != "/" && -n "$DEST" ]] || die "Refusing to sync to '/' or empty DEST"
  require_cmd rsync
fi

# ===== Optional excludes =====
RSYNC_EXCLUDES=()
GSUTIL_EXCLUDE_REGEX=""
if [[ -n "$EXCLUDES_FILE" ]]; then
  [[ -f "$EXCLUDES_FILE" ]] || die "EXCLUDES_FILE not found: $EXCLUDES_FILE"
  # For rsync: --exclude-from works directly.
  RSYNC_EXCLUDES=( --exclude-from="$EXCLUDES_FILE" --delete-excluded )

  # For gsutil: build a single regex for -x. It matches any path containing one of the patterns.
  # Note: patterns are treated as regex, not rsync globs. Keep them simple (e.g., ^\.cache/|\.DS_Store$).
  # Convert each non-empty, non-comment line into an alternation; escape slashes.
  mapfile -t _lines < <(sed -E '/^\s*($|#)/d' "$EXCLUDES_FILE")
  if ((${#_lines[@]})); then
    _escaped=()
    for l in "${!_lines[@]}"; do
      pat="${_lines[$l]}"
      pat="${pat//\//\/}"   # minimal escaping; user should supply regex-ready patterns
      _escaped+=( "$pat" )
    done
    GSUTIL_EXCLUDE_REGEX="$(IFS='|'; echo "${_escaped[*]}")"
  fi
fi

# ===== Workers =====
do_local_rsync() {
  local -a opts=(
    --archive
    --delete
    --delete-after
    --numeric-ids
    --hard-links
    --xattrs
    --acls
    --human-readable
    --itemize-changes
    --partial
    --inplace
    --prune-empty-dirs
    --exclude='.DS_Store'
  )
  if ((DRYRUN)); then
    opts+=( --dry-run )
    log "Running LOCAL rsync in DRY RUN mode."
  fi
  if ((${#RSYNC_EXCLUDES[@]})); then
    opts+=( "${RSYNC_EXCLUDES[@]}" )
  fi

  log "Starting rsync: ${SOURCE_WITH_SLASH} -> ${DEST}"
  log "Options: ${opts[*]}"

  ionice -c "$RUN_IONICE_CLASS" -n "$RUN_IONICE_PRIO" \
    nice -n "$RUN_NICE" \
    rsync "${opts[@]}" "$SOURCE_WITH_SLASH" "$DEST" | tee -a "$LOG_FILE"

  local rc=${PIPESTATUS[2]}
  if [[ $rc -eq 0 || $rc -eq 24 ]]; then
    log "Local rsync finished with exit code $rc."
  else
    die "Local rsync failed with exit code $rc. See log: $LOG_FILE"
  fi
}

do_gsutil_rsync() {
  # -m: parallel; -r: recursive; -d: delete; -e: **exclude symlinks** (skip, don’t abort)
  local -a opts=( -m rsync -r -d -e )
  ((DRYRUN)) && opts+=( -n )
  [[ -n "$GSUTIL_EXCLUDE_REGEX" ]] && opts+=( -x "$GSUTIL_EXCLUDE_REGEX" )

  log "Starting gsutil rsync: ${SOURCE_WITH_SLASH} -> ${DEST}"
  log "Options: ${opts[*]}"

  ionice -c "$RUN_IONICE_CLASS" -n "$RUN_IONICE_PRIO" \
    nice -n "$RUN_NICE" \
    gsutil "${opts[@]}" "$SOURCE_WITH_SLASH" "$DEST" | tee -a "$LOG_FILE"

  local rc=${PIPESTATUS[2]}
  [[ $rc -eq 0 ]] || die "gsutil rsync failed with exit code $rc. See log: $LOG_FILE"
  log "gsutil rsync finished with exit code $rc."
}

# ===== Run with lock =====
{
  flock -n 200 || die "Another backup is running (lock: $LOCK_FILE)."
  log "Log file: $LOG_FILE"
  if (( is_gs_dest )); then
    do_gsutil_rsync
  else
    do_local_rsync
  fi
} 200>"$LOCK_FILE"
