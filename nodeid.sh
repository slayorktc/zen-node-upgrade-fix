#!/bin/sh
sed "s/null/$(cat /mnt/zen/secnode/nodeid)/" /mnt/zen/secnode/config.json
