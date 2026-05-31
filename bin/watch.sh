#!/bin/sh
target="$1"
if [[ ! -f ${target} ]]; then
  echo "Target file does not exist: ${target}"
  exit 1
fi

echo "Watching [${target}] for changes ..."
inotifywait -q -m -e close_write,moved_to --format %e/%f . |
while IFS=/ read -r events file; do
    echo "file: ${file} | target: ${target}"
    if [ "${file}" = "${target}" ]; then
        python3 ${target}
    fi
done
