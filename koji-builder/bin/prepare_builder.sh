#!/bin/bash
set -xeuo pipefail

sleep 5
koji add-host kojibuilder x86_64
koji add-host-to-channel kojibuilder container --new
