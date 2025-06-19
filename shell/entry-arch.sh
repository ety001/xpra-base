#!/bin/bash

sudo chgrp video /dev/dri/*
sudo chown -R lzc:lzc /home/lzc/.cache
sudo chown -R lzc:lzc /home/lzc/.ssh

sudo /usr/sbin/supervisord -n -c /etc/supervisord.conf