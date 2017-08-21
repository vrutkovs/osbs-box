import imp

orig_config = imp.load_source('orig_config', '/etc/odcs/config.py')

class DockerConfiguration(orig_config.BaseConfiguration):
    HOST = '0.0.0.0'
    PORT = 5005

    SQLALCHEMY_DATABASE_URI = 'postgresql://koji@koji-db/odcs'

    DEBUG = True
    LOG_BACKEND = 'console'
    LOG_LEVEL = 'debug'

    # Global network-related values, in seconds
    NET_TIMEOUT = 5
    NET_RETRY_INTERVAL = 1
    TARGET_DIR = '/mnt/koji/composes'
    TARGET_DIR_URL = 'http://${WORKSTATION_IP}:5005/composes'

    PDC_URL = 'http://pdc/rest_api/v1'
    PDC_INSECURE = True

    KOJI_PROFILE = 'koji'

    # Disable login_required in development environment
    LOGIN_DISABLED = True
    # Disable authorize in development environment
    AUTHORIZE_DISABLED = True

    AUTH_BACKEND = 'noauth'
    AUTH_OPENIDC_USERINFO_URI = 'https://iddev.fedorainfracloud.org/openidc/UserInfo'
