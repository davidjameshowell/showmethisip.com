from flask import Flask, render_template, request, jsonify
import socket 

app = Flask(__name__)

@app.route("/", methods=["GET"])
def get_my_ip():

    if request.environ.get('HTTP_CF_CONNECTING_IPV6'):
        real_ip = request.environ.get('HTTP_CF_CONNECTING_IPV6')
    else:
        real_ip = request.environ['HTTP_X_FORWARDED_FOR'].split(',')[0]

    try:
        ip_hostname = socket.gethostbyaddr(real_ip)[0]
    except:
        ip_hostname = "No reverse DNS for IP"
    return render_template(
        'ip_new.html', ip=real_ip, hostname=ip_hostname
        )

@app.route("/api", methods=["GET"])
def get_my_ip_api():
    return_data = {}
    
    if request.environ.get('HTTP_CF_CONNECTING_IPV6'):
        real_ip = request.environ.get('HTTP_CF_CONNECTING_IPV6')
    else:
        real_ip = request.environ['HTTP_X_FORWARDED_FOR'].split(',')[0]

    try:
        ip_hostname = socket.gethostbyaddr(real_ip)[0]
    except:
        ip_hostname = "no_rdns_for_ip"

    return_data['ip'] = real_ip
    return_data['hostname'] = ip_hostname
    
    try:
        if request.environ['HTTP_DNT']:
             return_data['do_not_track'] = 'true'
        else:
             return_data['do_not_track'] = 'false'
    except:
        return_data['do_not_track'] = 'unknown'
    try:
        return_data['user_agent'] = request.environ['HTTP_USER_AGENT']
    except:
        return_data['user_agent'] = "unknown"

    return jsonify(return_data),200

if __name__ == '__main__':
    app.run()
