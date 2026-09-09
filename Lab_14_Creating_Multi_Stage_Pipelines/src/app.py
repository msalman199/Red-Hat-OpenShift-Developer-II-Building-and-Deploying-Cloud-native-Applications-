from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Multi-Stage Pipeline!',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'stage': os.getenv('DEPLOYMENT_STAGE', 'development')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
