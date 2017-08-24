#!/bin/bash

until psql -h koji-db -U koji --list | grep pdc > /dev/null 2>&1 ; do
    echo 1>&2 "Waiting for database to become available"
    sleep 1
done

django-admin migrate --settings=pdc.settings --noinput

exec httpd -DNO_DETACH -DFOREGROUND
