from cfenv import AppEnv

env = AppEnv()
for svc in env.services:
    if svc.env["label"] == "postgres":
        pg = svc.env
        print(
            "%s:%d:%s:%s:%s"
            %
            (
                pg["credentials"]["host"],
                pg["credentials"]["port"],
                "*", # Must provide wildcard for the database name because there are multiple databases on the server
                pg["credentials"]["username"],
                pg["credentials"]["password"]
            )
        )
