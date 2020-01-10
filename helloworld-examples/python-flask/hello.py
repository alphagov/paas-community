#!/usr/bin/env python3

from flask import Flask
import os


app = Flask(__name__)


@app.route("/")
def index():
    return """<ul>
                 <li><a href='/hello'>/hello</a></li>
                 <li><a href='/hello/world'>/hello/world</a></li>
               </ul>"""


@app.route("/hello")
def hello():
    return "Hello"


@app.route("/hello/<name>")
def hello_user(name):
    return f"Hello {name}"


if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=True)
