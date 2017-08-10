#!/bin/bash
set -eux

rc=1
while [ $rc -ne 0 ]; do
timeout --signal=9 5 koji add-host kojibuilder x86_64; rc=$?
done
rc=1
while [ $rc -ne 0 ]; do
timeout --signal=9 5 koji add-host-to-channel kojibuilder container --new; rc=$?
done
