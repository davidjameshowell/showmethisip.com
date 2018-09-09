from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

@app.route("/", methods=["GET"])
def get_my_ip():
    return render_template(
        'ip.html', ip = request.environ['REMOTE_ADDR']
        )

@app.route("/api", methods=["GET"])
def get_my_ip_api():
    return jsonify(
        {'ip': request.environ['REMOTE_ADDR']}
        ),200


if __name__ == '__main__':
    app.run()
