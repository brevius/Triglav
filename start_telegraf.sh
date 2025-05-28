#!/bin/bash

# Replace variables from .env file in telegraf config
# TOML lists workaround
TEMPLATE_FILE="/etc/telegraf/telegraf.conf.template"
OUTPUT_FILE="/etc/telegraf/telegraf.conf"

cp "$TEMPLATE_FILE" "$OUTPUT_FILE"
for var in $(env | cut -d= -f1); do
    sed -i "s|\${$var}|${!var}|g" "$OUTPUT_FILE"
done

# Starte telegraf
# Modified https://github.com/influxdata/influxdata-docker/blob/master/telegraf/1.34/entrypoint.sh
set -e

# Just start telegraf
set -- telegraf "$@"

if [ $EUID -ne 0 ]; then
    exec "$@"
else
    # Allow telegraf to send ICMP packets and bind to privliged ports
    setcap cap_net_raw,cap_net_bind_service+ep /usr/bin/telegraf || echo "Failed to set additional capabilities on /usr/bin/telegraf"

    # ensure HOME is set to the telegraf user's home dir
    export HOME=$(getent passwd telegraf | cut -d : -f 6)

    # honor groups supplied via 'docker run --group-add ...' but drop 'root'
    # (also removes 'telegraf' since we unconditionally add it and don't want it listed twice)
    # see https://github.com/influxdata/influxdata-docker/issues/724
    groups="telegraf"
    extra_groups="$(id -Gn || true)"
    for group in $extra_groups; do
        case "$group" in
            root | telegraf) ;;
            *) groups="$groups,$group" ;;
        esac
    done
    exec setpriv --reuid telegraf --regid telegraf --groups "$groups" "$@"
fi