#!/bin/sh
sed -i "s/null/$(cat /mnt/zen/secnode/nodeid)/" /mnt/zen/secnode/config.json
