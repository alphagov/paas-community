from cfenv import AppEnv
import json

env = AppEnv()

servers = { "Servers": {}}

i = 0
for svc in env.services:
    if svc.env["label"] == "postgres":
        i += 1
        pg = svc.env
        servers["Servers"][str(i)] = {
            "Name": pg["name"],
            "Group": "Servers",
            "Host": pg["credentials"]["host"],
            "Port": pg["credentials"]["port"],
            "MaintenanceDB": "postgres",
            "Username": pg["credentials"]["username"],
            "SSLMode": "require",
            "PassFile": "/home/vcap/app/.pgpass",
            "DBRestriction": pg["credentials"]["name"]
        }

print(json.dumps(servers))
