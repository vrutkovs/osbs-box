#!/bin/bash
django-admin migrate --settings=pdc.settings --noinput

exec httpd -DNO_DETACH -DFOREGROUND
