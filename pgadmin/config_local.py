import os

##
# config_local.py is used to override
# configuration options from config.py.
##

# PaaS apps run inside containers,
# whose default HTTP port is $PORT
DEFAULT_SERVER="127.0.0.1"
DEFAULT_SERVER_PORT=os.environ["PORT"]

# The directories that the vcap user
# (which runs the apps) has access to
# is limited, so the data directory
# must be set within that space.
# Anything that is derived from DATA_DIR
# must also be redefined
DATA_DIR="/home/vcap/app/data"
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')

# CloudFoundry reads from /dev/stdout
# for application logs, so pgadmin must
# log to there if we want to see them
LOG_FILE="/home/vcap/app/pgadmin4.log"


# PgAdmin expects to be able to find a
# couple of standard Postgres binaries.
# They live outside of the normal path
# for Ubuntu, so we have to set them.
DEFAULT_BINARY_PATHS= {
    "pg": "/home/vcap/deps/0/bin/",
    # These are left blank deliberately
    "ppas": "",
    "gpdb": ""
}
