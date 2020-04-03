#!/usr/bin/env python3

from flask import Flask
import os

# setting logging to stdout
import sys
from logging.config import dictConfig
dictConfig({
    'version': 1,
    'formatters': {'default': {
        'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    }},
    'handlers': {'wsgi': {
        'class': 'logging.StreamHandler',
        'stream': 'ext://sys.stdout',
        'formatter': 'default'
    }},
    'root': {
        'level': 'INFO',
        'handlers': ['wsgi']
    }
})

app = Flask(__name__)

@app.route("/")
def index():
    app.logger.info("Index")
    return """<ul>
                 <li><a href='/hello'>/hello</a></li>
                 <li><a href='/hello/world'>/hello/world</a></li>
               </ul>"""


@app.route("/hello")
def hello():
    app.logger.info("Hello")
    return "Hello"


@app.route("/hello/<name>")
def hello_user(name):
    app.logger.info("Hello name")
    return f"Hello {name}"


if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=True)
