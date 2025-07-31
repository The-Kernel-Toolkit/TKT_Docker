#!/bin/bash
useradd -m -U -s /bin/bash TKT
mkdir -p /home/TKT/.config
chown -R TKT:TKT /home/TKT
