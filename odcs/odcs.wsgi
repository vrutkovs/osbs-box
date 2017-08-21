#-*- coding: utf-8 -*-

import logging
import os

logging.basicConfig(level='DEBUG')

os.environ['ODCS_CONFIG_FILE'] = '/etc/odcs/config_docker.py'
os.environ['ODCS_CONFIG_SECTION'] = 'DockerConfiguration'

from odcs.server import app as application
