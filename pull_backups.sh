#!/usr/bin/env bash

domain="lasercata.com"

rsync -rvhP "$domain":/srv/docker/backups/ backups/
