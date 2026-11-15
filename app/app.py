from flask import Flask , request
import socket

app = Flask(__name__)

STUDENTS={
    "001": {"name":"rahul" , "dob":"2001-05-04", "marks":{"python":84,"cloud":76}},

    "002": {"name":"nazim","dob":"2002-01-31", "marks":{"python":89,"cloud":97}},

    "003": {"name":"yusra","dob":"2002-04-03", "marks":{"python":76,"cloud":86}},
    }

@app.route("/")
def home():
    return "form version of app" + socket.gethostname()

@app.route("/burn")
def burn():
    total=0
    for i in range (2000000):
        total=(total+i*i)%1000003
    return f"burned CPU on container {socket.gethostname()}"

@app.route("/result",methods =["GET","POST"])
def result():
    message = ""
    if request.method== "POST":
        roll=request.form["roll"]
        dob=request.form["dob"]
        student=STUDENTS.get(roll)
        if student is None or student["dob"]!= dob:
            message = "incorrect details , please try again"
        else:
            message= "name:" + student["name"]
            for subject , score in student["marks"].items():
                message= message + "<br>" + subject + ":" +str(score)
    return """
    <h2>Student Result Portal</h2>
    <form method="POST">
      Roll Number: <input name ="roll" placeholder= "enter your roll number"><br>
      Date of Birth: <input name="dob" placeholder= "enter your date of birth" type ="date"><br>
      <button type = "submit">search</button>
    </form>
    """ + message

app.run(host="0.0.0.0", port=5000)
