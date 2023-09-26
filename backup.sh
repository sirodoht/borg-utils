#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./backup.sh

Backup home using borg.'
    exit
fi

export BORG_REPO='sirodoht@rsync.net:borg-repo'
export BORG_PASSPHRASE='passphrase'
export BORG_RSH='ssh -i /Users/sirodoht/.ssh/id_rsa'

# start -x after exporting secrets
set -x

cd "$(dirname "$0")"

main() {
    # signal healthchecks.io
    curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/xxx/start

    # backup latest data
    borg create \
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
        --exclude '*.mdb' \
        --exclude '/Applications/League of Legends.app' \
        --exclude '/Users/sirodoht/src/*/node_modules' \
        --exclude '/Users/sirodoht/src/*/venv' \
        --exclude '/Users/sirodoht/src/*/.venv' \
        --exclude '/Users/sirodoht/src/*/.pyenv' \
        --exclude '/Users/sirodoht/src/*/.direnv' \
        --exclude '/Users/sirodoht/src/*/.bundle' \
        --exclude '/Users/sirodoht/src/einanao-stable-diffusion' \
        --exclude '/Users/sirodoht/src/hlky-stable-diffusion' \
        --exclude '/Users/sirodoht/src/stablelm-base-alpha-3b' \
        --exclude '/Users/sirodoht/src/stablelm-base-alpha-7b' \
        --exclude '/Users/sirodoht/src/stablelm-tuned-alpha-3b' \
        --exclude '/Users/sirodoht/src/stablelm-tuned-alpha-7b' \
        --exclude '/Users/sirodoht/src/stable-diffusion-webui' \
        --exclude '/Users/sirodoht/src/kaggle-ecommerce' \
        --exclude '/Users/sirodoht/src/facebookresearch-llama' \
        --exclude '/Users/sirodoht/src/llama-model' \
        --exclude '/Users/sirodoht/src/llama.cpp/models' \
        --exclude '/Users/sirodoht/src/Llama-2-7b-chat-hf' \
        --exclude '/Users/sirodoht/src/alpaca.cpp' \
        --exclude '/Users/sirodoht/src/psychic-barnacle/data_zookeeper' \
        --exclude '/Users/sirodoht/go' \
        --exclude '/Users/sirodoht/monero-blockchain' \
        --exclude '/Users/sirodoht/opt/anaconda3' \
        --exclude '/Users/sirodoht/.Trash' \
        --exclude '/Users/sirodoht/.bitmonero' \
        --exclude '/Users/sirodoht/.android' \
        --exclude '/Users/sirodoht/.cache' \
        --exclude '/Users/sirodoht/.cargo' \
        --exclude '/Users/sirodoht/.diffusionbee' \
        --exclude '/Users/sirodoht/.docker' \
        --exclude '/Users/sirodoht/.gem' \
        --exclude '/Users/sirodoht/.gradle' \
        --exclude '/Users/sirodoht/.go' \
        --exclude '/Users/sirodoht/.influxdbv2' \
        --exclude '/Users/sirodoht/.ipfs' \
        --exclude '/Users/sirodoht/.m2' \
        --exclude '/Users/sirodoht/.nix-defexpr' \
        --exclude '/Users/sirodoht/.nix-profile' \
        --exclude '/Users/sirodoht/.npm' \
        --exclude '/Users/sirodoht/.ollama' \
        --exclude '/Users/sirodoht/.orbstack' \
        --exclude '/Users/sirodoht/.rbenv' \
        --exclude '/Users/sirodoht/.rustup' \
        --exclude '/Users/sirodoht/.ssb' \
        --exclude '/Users/sirodoht/.vagrant.d' \
        --exclude '/Users/sirodoht/.vscode' \
        --exclude '/Users/sirodoht/.walletwasabi' \
        --exclude '/Users/sirodoht/zim-library' \
        --exclude '/Users/sirodoht/Pictures/Photos Library.photoslibrary' \
        --exclude '/Users/sirodoht/VirtualBox VMs' \
        --exclude '/Users/sirodoht/Library' \
        --exclude '/Users/sirodoht/Desktop' \
        --exclude '/Users/sirodoht/Downloads' \
        --exclude '/Users/sirodoht/Movies' \
        --exclude '/Users/sirodoht/Music/Music' \
        ::'{hostname}-{now}' \
        /Users/sirodoht

    # delete old backups
    borg prune \
        --remote-path=borg1 \
        --list \
        --glob-archives '{hostname}-*'  \
        --show-rc \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 6

    # data integrity check
    borg check \
        --remote-path=borg1 \
        --verbose \
        --show-rc

    # signal healthchecks.io
    curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/xxx

    # pop macOS alert
    osascript -e "display notification with title \"Borg backup done\""
}

main "$@"
