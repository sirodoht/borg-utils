#!/bin/sh

export BORG_REPO='user@backup.sirodoht.com:borg-repo'
export BORG_PASSPHRASE='secure_passphrase'
export BORG_RSH='ssh -i /Users/sirodoht/.ssh/id_rsa'

info() {
    printf "\n%s %s\n\n" "$(date)" "$*" >> "/Users/sirodoht/borg/logs/$(date '+%Y-%m-%d-%HH')";
}
trap 'echo $(date) Backup interrupted >&2; exit 2' INT TERM

# Signal healthchecks.io check start
curl --retry 3 https://hc-ping.com/2384d09c/start

# Backup new data op
info "Starting backup"
/Users/sirodoht/bin/borg create \
    --remote-path=borg1 \
    --verbose \
    --filter AME \
    --list \
    --stats \
    --show-rc \
    --compression lz4 \
    --exclude-caches \
    --exclude '*.tmp' \
    --exclude '*.DS_Store' \
    --exclude '*.pyc' \
    --exclude '/Users/sirodoht/borg/logs' \
    --exclude '/Users/sirodoht/Projects/*/venv' \
    --exclude '/Users/sirodoht/Projects/*/node_modules' \
    --exclude '/Users/sirodoht/.rbenv' \
    --exclude '/Users/sirodoht/.gem' \
    --exclude '/Users/sirodoht/.npm' \
    --exclude '/Users/sirodoht/.vscode' \
    --exclude '/Users/sirodoht/.vim' \
    --exclude '/Users/sirodoht/.cargo' \
    --exclude '/Users/sirodoht/.zoomus' \
    --exclude '/Users/sirodoht/.cache' \
    --exclude '/Users/sirodoht/.Trash' \
    --exclude '/Users/sirodoht/Library' \
    --exclude '/Users/sirodoht/Desktop' \
    --exclude '/Users/sirodoht/Downloads' \
    --exclude '/Users/sirodoht/Movies' \
    --exclude '/Users/sirodoht/Music' \
    ::'{hostname}-{now}' \
    /Users/sirodoht 2>> "/Users/sirodoht/borg/logs/$(date '+%Y-%m-%d-%HH')"

backup_exit=$?

# Delete old data op
info "Pruning repository"
/Users/sirodoht/bin/borg prune \
    --remote-path=borg1 \
    --list \
    --prefix '{hostname}-' \
    --show-rc \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 2>> "/Users/sirodoht/borg/logs/$(date '+%Y-%m-%d-%HH')"

prune_exit=$?

# Data integrity check op
info "Check repository"
/Users/sirodoht/bin/borg check \
    --remote-path=borg1 \
    --verbose \
    --show-rc 2>> "/Users/sirodoht/borg/logs/$(date '+%Y-%m-%d-%HH')"

# Signal healthchecks.io check end
curl --retry 3 https://hc-ping.com/2384d09c

# Return with highest exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
    osascript -e "display notification \"$1\" with title \"Borg backup successful\""
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
    touch "/Users/sirodoht/borg-warning-$(date '+%Y-%m-%d-%HH')"
    osascript -e "display notification \"$1\" with title \"Borg backup finished with warnings\""
else
    info "Backup and/or Prune finished with errors"
    touch "/Users/sirodoht/error-borg-$(date '+%Y-%m-%d-%HH')"
    osascript -e "display notification \"$1\" with title \"Borg backup finished with errors\""
fi

exit ${global_exit}
