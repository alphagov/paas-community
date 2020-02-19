#!/bin/bash

# modify paths to take account of CF container filesystem
/bin/sed -i 's+/usr/local/openresty/bin/resty+/home/vcap/usr/local/openresty/bin/resty+g' /home/vcap/deps/0/apt/usr/local/bin/kong
/bin/sed -i 's+/opt/openresty/nginx/sbin+/home/vcap/deps/0/apt/usr/local/openresty/nginx/sbin/+g' /home/vcap/deps/0/apt/usr/local/share/lua/5.1/kong/cmd/utils/nginx_signals.lua
/bin/sed -i 's+/usr/local/openresty/nginx/sbin/nginx+/home/vcap/deps/0/apt/usr/local/openresty/nginx/sbin/nginx+g' /home/vcap/deps/0/apt/usr/local/openresty/bin/resty

# map directories to a more sensible location
/bin/mkdir -p /home/vcap/usr/local
/bin/ln -s /home/vcap/deps/0/apt/usr/local/openresty /home/vcap/usr/local
/bin/ln -s /home/vcap/deps/0/apt/usr/local/lib/lua/5.1/socket /home/vcap/usr/local/openresty/lualib/
/bin/ln -s /home/vcap/deps/0/apt/usr/local/lib/lua/5.1/lua_system_constants.so /home/vcap/usr/local/openresty/lualib/
/bin/ln -s /home/vcap/deps/0/apt/usr/local/openresty/luajit/lib/libluajit-5.1.so.2 /home/vcap/usr/local/openresty/lualib/

#/bin/ln -s /home/vcap/deps/0/apt/usr/local/openresty/luajit/lib/libluajit-5.1.so.2  /home/vcap/deps/0/lib/x86_64-linux-gnu


export KONG_PROXY_LISTEN=0.0.0.0:8080
#export KONG_ADMIN_LISTEN=0.0.0.0:8001
export LD_LIBRARY_PATH=/home/vcap/deps/0/apt/usr/local/lib:/home/vcap/deps/0/apt/usr/local/share/lua/5.1/:/usr/bin/:/home/vcap/deps/0/apt/usr/local/openresty/bin/:/home/vcap/deps/0/apt/usr/local/bin:/home/vcap/deps/0/apt/usr/bin:/home/vcap/deps/0/apt/usr/local/openresty/openssl/lib:/home/vcap/deps/0/apt/usr/local/openresty/luajit/lib/:$LD_LIBRARY_PATH
export LUA_PATH='/home/vcap/deps/0/apt/usr/local/share/lua/5.1/?.lua;/home/vcap/deps/0/apt/usr/local/share/lua/5.1/?/init.lua;/home/vcap/deps/0/apt/usr/local/openresty/lualib/?.lua'
export LUA_CPATH='/home/vcap/deps/0/apt/usr/local/lib/lua/5.1/?.so;/home/vcap/deps/0/apt/usr/local/lib/lua/5.1/?/?.so;/home/vcap/deps/0/apt/usr/local/openresty/luajit/lib/?.so.2;/home/vcap/deps/0/apt/usr/local/lib/lua/5.1/socket/?.so;/home/vcap/deps/0/apt/usr/local/openresty/lualib/?.so'
export PATH=/home/vcap/usr/local:/home/vcap/deps/0/apt/usr/local/openresty/bin/:/home/vcap/deps/0/apt/usr/local/bin:/home/vcap/deps/0/apt/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# configure postgres
SERVICE=postgres
URI=`/bin/echo $VCAP_SERVICES | /usr/bin/jq -r '.["'$SERVICE'"][0].credentials.uri'`
export KONG_PG_USER=`/bin/echo $URI | /usr/bin/cut -d : -f 2 | /usr/bin/tr -d '/'`
export KONG_PG_HOST=`/bin/echo $URI | /usr/bin/cut -d @ -f 2 | /usr/bin/cut -d : -f 1`
export KONG_PG_SSL=on
export KONG_PG_PORT=5432
export KONG_PG_DATABASE=`/bin/echo $URI | /usr/bin/cut -d '/' -f 4`
export KONG_PG_PASSWORD=`/bin/echo $URI | /bin/sed  "s|$KONG_PG_HOST||g" | /bin/sed  "s|$KONG_PG_USER||g" | /bin/sed  "s|$KONG_PG_PORT||g" | /bin/sed  "s|$KONG_PG_DATABASE||g" | /bin/sed "s|/||g"  | /bin/sed "s|:||g"  | /bin/sed "s|postgres||g"  | /bin/sed "s|@||g"`
export KONG_LUA_PACKAGE_PATH=$LUA_PATH
export KONG_LUA_PACKAGE_CPATH=$LUA_CPATH

# check for database migrations and run them if required
/home/vcap/deps/0/apt/usr/local/bin/kong migrations list -c /home/vcap/deps/0/apt/etc/kong/kong.conf.default

if [ $? -eq 3 ]; then
    echo "$(date -u) Starting database bootstrap"
    /home/vcap/deps/0/apt/usr/local/bin/kong migrations bootstrap -y -c /home/vcap/deps/0/apt/etc/kong/kong.conf.default
    echo "$(date -u) Finishing database bootstrap"
    exit 0
  elif [ $? -eq 4 ]; then
    echo "$(date -u) Starting database migration"
    /home/vcap/deps/0/apt/usr/local/bin/kong migrations finish -y -c /home/vcap/deps/0/apt/etc/kong/kong.conf.default
    echo "$(date -u) Finishing database migration"
    exit 0
  elif [ $? -eq 5 ]; then
    echo "$(date -u) Starting database migration"
    /home/vcap/deps/0/apt/usr/local/bin/kong migrations up -y -c /home/vcap/deps/0/apt/etc/kong/kong.conf.default && /home/vcap/deps/0/apt/usr/local/bin/kong migrations finish -y -c /home/vcap/deps/0/apt/etc/kong/kong.conf.default
    echo "$(date -u) Finishing database migration"
    exit 0
fi

# start kong
/home/vcap/deps/0/apt/usr/local/bin/kong prepare -p /home/vcap/usr/local/kong && /home/vcap/deps/0/apt/usr/local/openresty/nginx/sbin/nginx  -p /home/vcap/usr/local/kong -c nginx.conf

# keep this process alive
while true;do
	sleep 3
	nginx_count=`ps aux | grep maste[r] | wc -l`
	if [ "$nginx_count" != "1" ];then
		echo "Some process crashed"
		ps aux
		exit 1
	fi
done

