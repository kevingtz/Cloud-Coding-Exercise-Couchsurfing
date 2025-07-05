from flask import Flask, render_template, jsonify
import mysql.connector
from mysql.connector import Error
import os
import time

app = Flask(__name__)

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'mysql'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'rootpassword'),
    'database': os.getenv('DB_NAME', 'greetings_db'),
    'charset': 'utf8mb4',
    'collation': 'utf8mb4_unicode_ci'
}

def wait_for_db():
    """Wait for the database to be ready"""
    max_retries = 30
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            connection = mysql.connector.connect(**DB_CONFIG)
            if connection.is_connected():
                connection.close()
                return True
        except Error as e:
            time.sleep(2)
            retry_count += 1
    
    return False

def get_db_connection():
    """Get database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        return None

@app.route('/')
def index():
    """Main page showing all greetings"""
    return render_template('index.html')

@app.route('/api/greetings')
def get_greetings():
    """API endpoint to get all greetings"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT id, name FROM users ORDER BY name")
        users = cursor.fetchall()
        
        greetings = []
        for user in users:
            greetings.append({
                'id': user['id'],
                'name': user['name'],
                'greeting': f"Hello, {user['name']}! Welcome to our application."
            })
        
        cursor.close()
        connection.close()
        
        return jsonify({'greetings': greetings})
        
    except Error as e:
        return jsonify({'error': 'Failed to fetch greetings'}), 500

@app.route('/api/greeting/<int:user_id>')
def get_greeting(user_id):
    """API endpoint to get a specific greeting"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT id, name FROM users WHERE id = %s", (user_id,))
        user = cursor.fetchone()
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        greeting = {
            'id': user['id'],
            'name': user['name'],
            'greeting': f"Hello, {user['name']}! Welcome to our application."
        }
        
        cursor.close()
        connection.close()
        
        return jsonify(greeting)
        
    except Error as e:
        return jsonify({'error': 'Failed to fetch greeting'}), 500

@app.route('/health')
def health_check():
    """Health check endpoint"""
    connection = get_db_connection()
    if connection:
        connection.close()
        return jsonify({'status': 'healthy', 'database': 'connected'})
    else:
        return jsonify({'status': 'unhealthy', 'database': 'disconnected'}), 500

if __name__ == '__main__':
    # Wait for database to be ready
    if wait_for_db():
        app.run(host='0.0.0.0', port=5001, debug=True)