#!/usr/bin/env bash
# Tests for bin/docker-cleanup using a fake docker (test/bin/docker). Never touches real Docker.

root=$(cd "$(dirname "$0")/.." && pwd)
script="$root/bin/docker-cleanup"
export PATH="$root/test/bin:$PATH"
export DOCKER_LOG=$(mktemp)
trap 'rm -f "$DOCKER_LOG"' EXIT

passed=0
failed=0
out=""
status=0

# run <stdin> <args...>: runs the script with a clean log, captures output and exit status
run() {
  local input=$1; shift
  : > "$DOCKER_LOG"
  out=$(printf '%s' "$input" | "$script" "$@" 2>&1)
  status=$?
}

check() {
  local name=$1; shift
  if "$@"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    echo "FAIL: $name"
    echo "  status=$status"
    echo "  output: $out"
    echo "  calls: $(tr '\n' ';' < "$DOCKER_LOG")"
  fi
}

called()     { grep -qE -- "$1" "$DOCKER_LOG"; }
not_called() { ! called "$1"; }
not_say()    { [[ "$out" != *"$1"* ]]; }
after_lacks() { [[ "${out#*After:}" != *"$1"* ]]; }
says()       { [[ "$out" == *"$1"* ]]; }
exits()      { [[ "$status" -eq "$1" ]]; }

reset_stub() {
  unset STUB_DOWN STUB_EXITED STUB_CONTAINERS STUB_USED_IMAGES STUB_DANGLING \
        STUB_IMAGES STUB_VOLUMES STUB_VOLUME_LABELS STUB_VOLUME_SIZES STUB_FAIL STUB_NETWORKS_PRUNED STUB_CACHE_TOTAL \
        STUB_DF STUB_DF_IMAGES STUB_DF_VOLUMES STUB_CACHE_RECLAIMABLE STUB_EXITED_SIZES STUB_DANGLING_IDS STUB_NETWORKS STUB_USED_NETWORKS
}

# --- basics -----------------------------------------------------------------

reset_stub
run "" -h
check "help exits 0" exits 0
check "help shows usage" says "Usage: docker-cleanup"

run "" --nope
check "unknown option exits 1" exits 1
check "unknown option is reported" says "Unknown option: --nope"

STUB_DOWN=1 run "" -y
check "daemon down exits 1" exits 1
check "daemon down is reported" says "Docker daemon is not running"
reset_stub

run "" docker-cli-plugin-metadata
check "plugin metadata exits 0" exits 0
check "plugin metadata is json" says '"SchemaVersion"'

run "" cleanup -n
check "plugin subcommand name is ignored" exits 0

# --- default (safe) mode ----------------------------------------------------

export STUB_EXITED=$'c1\nc2\n' STUB_DANGLING=$'i1\n' STUB_VOLUMES=$'v1\nv2\n'
run "" -y
check "default removes exited containers" called "^rm c1"
check "default removes dangling images" called "^rmi i1"
check "default prunes networks" called "^network prune"
check "default prunes only old build cache" called "^builder prune -f --filter until=168h"
check "default never removes volumes" not_called "^volume rm"
check "default reports kept volumes" says "Kept: 2 unused volumes"
check "default counts removed items" says "Removed 3 items, 0 could not be removed"

# --- one-step prune results -------------------------------------------------

run "" -y
check "networks: nothing removed is reported" says "Networks        : nothing to remove"
check "cache: nothing reclaimed is reported" says "Build cache     : nothing to remove"

export STUB_NETWORKS_PRUNED=$'Deleted Networks:\nnet1\nnet2\n' STUB_CACHE_TOTAL=1.5GB
run "" -y
check "networks: removed count is reported" says "Networks        : 2 removed"
check "networks: removed count is added to total" says "Removed 5 items"
check "cache: reclaimed size is reported" says "Build cache     : reclaimed 1.5GB"
unset STUB_NETWORKS_PRUNED STUB_CACHE_TOTAL

# --- nothing to do ----------------------------------------------------------

reset_stub
export STUB_VOLUMES=$'v1\n' STUB_IMAGES=$'sha256:free1\n'
run ""
check "nothing to clean exits 0" exits 0
check "nothing to clean is reported" says "Nothing to clean up with these options."
check "nothing to clean does not ask" not_say "[y/N]"
check "nothing to clean removes nothing" not_called "^(rm|rmi|network prune|builder prune)"
check "nothing to clean still reports kept items" says "Kept: 1 unused volumes"

run "" -a -y
check "-a finds unused images to clean" called "^rmi -f sha256:free1"

run "" --volumes -y
check "--volumes finds volumes to clean" called "^volume rm v1"

export STUB_CONTAINERS=$'c9\n' STUB_NETWORKS=$'net1\nnet2\n' STUB_USED_NETWORKS=$'net1\n'
run "" -y
check "unused network counts as work" called "^network prune"
export STUB_USED_NETWORKS=$'net1\nnet2\n'
run "" -y
check "networks in use are not work" says "Nothing to clean up"
reset_stub

export STUB_EXITED=$'c1\nc2\n' STUB_DANGLING=$'i1\n' STUB_VOLUMES=$'v1\nv2\n'
export STUB_IMAGES=$'sha256:used\nsha256:free1\nsha256:free2\n' STUB_USED_IMAGES=$'sha256:used\n' STUB_CONTAINERS=$'c9\n'

# --- confirmation -----------------------------------------------------------

run "n" 
check "declining aborts cleanly" exits 0
check "declining removes nothing" not_called "^(rm|rmi|network prune|builder prune)"

run "y"
check "answering y proceeds" called "^rm c1"

run "" -y
check "-y skips the prompt" called "^rm c1"

# --- dry run ----------------------------------------------------------------

run "" -n
check "dry run exits 0" exits 0
check "dry run reports counts" says "Containers      : 2 would be removed"
check "dry run changes nothing" not_called "^(rm|rmi|volume rm|network prune|builder prune)"

# --- failures are counted ---------------------------------------------------

STUB_FAIL="c2" run "" -y
check "failed removals are counted" says "Removed 2 items, 1 could not be removed"
unset STUB_FAIL

# --- --all ------------------------------------------------------------------

export STUB_IMAGES=$'sha256:used\nsha256:free1\nsha256:free2\n' STUB_USED_IMAGES=$'sha256:used\n' STUB_CONTAINERS=$'c9\n'
run "" -a -y
check "-a force-removes unused images" called "^rmi -f sha256:free1"
check "-a keeps images used by containers" not_called "sha256:used"
check "-a prunes all build cache" called "^builder prune -a -f"
check "-a still keeps volumes" not_called "^volume rm"
check "-a does not report kept images" not_say "unused images, use -a"

run "" -ay
check "combined short flags work" called "^rmi -f sha256:free1"

run "" -y
check "default reports kept images" says "Kept: 2 unused images, use -a"

# --- reclaimable column depends on the mode ---------------------------------

export STUB_DF=$'Images|3|1|500MB\nContainers|2|1|10kB\nLocal Volumes|2|0|2GB\nBuild Cache|4|0|1GB\n'
export STUB_DF_IMAGES=$'sha256:used|300MB\nsha256:free1|100MB\nsha256:free2|50MB\n'
export STUB_DF_VOLUMES=$'1GB|0\n1GB|0\n'
export STUB_EXITED_SIZES=$'5kB (virtual 100MB)\n'
export STUB_DANGLING_IDS=$'sha256:free1\n'
export STUB_CACHE_RECLAIMABLE=700MB

run "" -n
check "table has reclaimable header" says "RECLAIMABLE"
check "default: only containers and cache are reclaimable" says "Containers      2         1         10kB     "
check "default: only dangling images are reclaimable" says "Images          3         1         500MB     100MB (20%)"
check "default: volumes reclaim nothing" says "Local Volumes   2         0         2GB       0B (0%)"
run "" -a -n
check "-a: unused images are reclaimable" says "Images          3         1         500MB     150MB (30%)"
check "-a: volumes still reclaim nothing" says "Local Volumes   2         0         2GB       0B (0%)"
run "" -a --volumes -n
check "--volumes: volumes are reclaimable" says "Local Volumes   2         0         2GB       2GB (100%)"
run "" -y
check "After table has no reclaimable" after_lacks "RECLAIMABLE"
unset STUB_DF STUB_DF_IMAGES STUB_DF_VOLUMES STUB_EXITED_SIZES STUB_DANGLING_IDS STUB_CACHE_RECLAIMABLE

# --- --volumes --------------------------------------------------------------

run "" --volumes -y
check "--volumes removes dangling volumes" called "^volume rm v1"
check "--volumes lists volumes first" says "Unused volumes"

run yn --volumes
check "volume confirmation can be declined" not_called "^volume rm"
check "declining volumes still cleans the rest" called "^rm c1"

run yy --volumes
check "volume confirmation can be accepted" called "^volume rm v2"

echo
echo "$passed passed, $failed failed"
[[ $failed -eq 0 ]]
