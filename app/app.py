from flask import Flask
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return "Third Version Hello from container  " + socket.gethostname()

@app.route("/burn")
def burn():
    total=0
    for i in range (2000000):
        total= (total+i*i)%1000003
    return f"burned CPU on container {socket.gethostname()}"

app.run(host="0.0.0.0", port=5000)
