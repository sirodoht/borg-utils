# Borg backup utils

## Test host

```sh
ssh -i ~/.ssh/id_rsa user@sirodoht.rsync.net ls -la
ssh -i ~/.ssh/id_rsa user@sirodoht.rsync.net borg1 list borg-repo/
borg list user@sirodoht.rsync.net:borg-repo
```

## Change password

```sh
ssh -t -i ~/.ssh/id_rsa user@sirodoht.rsync.net passwd
```

## Mount remote borg repository

```sh
mkdir ~/Downloads/mountpoint
borg mount user@sirodoht.rsync.net:borg-repo::luminol-2019-05-31T20:00:01 /Users/sirodoht/Downloads/mountpoint
borg mount user@sirodoht.rsync.net:borg-repo /Users/sirodoht/Downloads/mountpoint
borg umount /Users/sirodoht/Downloads/mountpoint
```

## Init repo

```sh
borg init --encryption=repokey new-repo/
```

## Create archive

```sh
borg create \
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
    --exclude '/Users/sirodoht/.rustup' \
    --exclude '/Users/sirodoht/.cargo' \
    --exclude '/Users/sirodoht/.vagrant.d' \
    --exclude '/Users/sirodoht/.zoomus' \
    --exclude '/Users/sirodoht/.cache' \
    --exclude '/Users/sirodoht/.Trash' \
    --exclude '/Users/sirodoht/VirtualBox VMs' \
    --exclude '/Users/sirodoht/Library' \
    --exclude '/Users/sirodoht/Desktop' \
    --exclude '/Users/sirodoht/Downloads' \
    --exclude '/Users/sirodoht/Movies' \
    --exclude '/Users/sirodoht/Music' \
    --exclude '/Users/sirodoht/borg/borg-repo' \
    /Users/sirodoht/borg/new-repo::'{hostname}-{now}' \
    /Users/sirodoht
```

## Troubleshoot db lock

```sh
ssh -i ~/.ssh/id_rsa user@sirodoht.rsync.net borg1 break-lock borg-repo
```
