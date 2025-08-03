#!/bin/bash
if useradd --help 2>&1 | grep -q -- --badnames; then
    useradd --badnames TKT
else
    useradd TKT
fi
mkdir -p /home/TKT/.config
chown -R TKT:TKT /home/TKT
