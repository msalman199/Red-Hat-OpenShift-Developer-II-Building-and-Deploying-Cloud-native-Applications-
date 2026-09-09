from flask import Flask, jsonify
import os

app = Flask(__name__)

VERSION = os.getenv('APP_VERSION', '1.0.0')
FAIL_HEALTH = os.getenv('FAIL_HEALTH', 'false').lower() == 'true'

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from Pipeline Rollback Lab',
        'version': VERSION
    })

@app.route('/health')
def health():
    if FAIL_HEALTH:
        return jsonify({'status': 'unhealthy', 'version': VERSION}), 500
    return jsonify({'status': 'healthy', 'version': VERSION})

@app.route('/version')
def version():
    return jsonify({'version': VERSION})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
