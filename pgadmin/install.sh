#/usr/bin/env sh

set -e

# /home/vcap is the home directory for the user which runs the apps
# and /home/vcap/deps/1/ is the root directory for dependnencies
# installed by the python buildpack
cp /home/vcap/app/config_local.py /home/vcap/deps/1/python/lib/python3.6/site-packages/pgadmin4/config_local.py

# generate the pg pass file
python3 /home/vcap/app/generate_pgpassfile.py > /home/vcap/app/.pgpass
chown vcap:vcap /home/vcap/app/.pgpass
chmod 0600 /home/vcap/app/.pgpass
export PGPASSFILE="/home/vcap/app/.pgpass"

# generate database bindings
python3 /home/vcap/app/generate_db_bindings.py > /home/vcap/app/db_bindings.json

# run setup.py to create the local configuration database
python3 /home/vcap/deps/1/python/lib/python3.6/site-packages/pgadmin4/setup.py \
    --load-servers /home/vcap/app/db_bindings.json \
    --user "${PGADMIN_SETUP_EMAIL}"

# make sure the vcap user can write to it
chown vcap:vcap /home/vcap/app/data/pgadmin4.db

/home/vcap/deps/1/python/bin/gunicorn \
    --bind "0.0.0.0:${PORT}" \
    --workers=1 \
    --threads=25 \
    --chdir /home/vcap/deps/1/python/lib/python3.6/site-packages/pgadmin4/ \
    pgAdmin4:app
