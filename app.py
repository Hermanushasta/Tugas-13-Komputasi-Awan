"""
Simple Task Manager Application
Mendemonstrasikan implementasi 6 Twelve-Factor App Principles

Prinsip 1: Codebase - Satu codebase dalam version control
Prinsip 2: Dependencies - Dependencies di-declare di requirements.txt
Prinsip 3: Config - Konfigurasi dari environment variables
Prinsip 4: Concurrency - Modular services yang bisa di-scale
Prinsip 5: Logs - Structured logging ke stdout
Prinsip 6: Build, Release, Run - Makefile untuk lifecycle management
"""

from flask import Flask, jsonify, request
from config import Config
from logger import get_logger
from services.task_service import TaskService
from services.notification_service import NotificationService

# Initialize logger
logger = get_logger(__name__)

# Initialize Flask app
app = Flask(__name__)

# Initialize services (Concurrency principle - modular services)
task_service = TaskService()
notification_service = NotificationService()

@app.route('/')
def index():
    """Home endpoint"""
    logger.info("Home endpoint accessed")
    return jsonify({
        'app': Config.APP_NAME,
        'environment': Config.APP_ENV,
        'message': 'Welcome to Simple Task Manager',
        'endpoints': {
            'tasks': '/api/tasks',
            'notifications': '/api/notifications',
            'health': '/health'
        }
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    logger.info("Health check accessed")
    return jsonify({
        'status': 'healthy',
        'app': Config.APP_NAME,
        'environment': Config.APP_ENV
    })

# Task endpoints
@app.route('/api/tasks', methods=['GET', 'POST'])
def tasks():
    """Get all tasks or create new task"""
    if request.method == 'GET':
        return jsonify({
            'tasks': task_service.get_all_tasks()
        })
    
    elif request.method == 'POST':
        data = request.get_json()
        
        if not data or 'title' not in data:
            logger.warning("Task creation failed - missing title")
            return jsonify({'error': 'Title is required'}), 400
        
        task = task_service.create_task(
            title=data['title'],
            description=data.get('description', '')
        )
        
        # Send notification
        notification_service.send_notification(
            message=f"New task created: {task['title']}",
            recipient='admin'
        )
        
        return jsonify(task), 201

@app.route('/api/tasks/<int:task_id>', methods=['GET', 'PUT', 'DELETE'])
def task_detail(task_id):
    """Get, update, or delete specific task"""
    if request.method == 'GET':
        task = task_service.get_task(task_id)
        if task:
            return jsonify(task)
        return jsonify({'error': 'Task not found'}), 404
    
    elif request.method == 'PUT':
        data = request.get_json()
        if not data or 'status' not in data:
            return jsonify({'error': 'Status is required'}), 400
        
        task = task_service.update_task_status(task_id, data['status'])
        if task:
            notification_service.send_notification(
                message=f"Task {task_id} updated to {data['status']}",
                recipient='admin'
            )
            return jsonify(task)
        return jsonify({'error': 'Task not found'}), 404
    
    elif request.method == 'DELETE':
        if task_service.delete_task(task_id):
            notification_service.send_notification(
                message=f"Task {task_id} deleted",
                recipient='admin'
            )
            return jsonify({'message': 'Task deleted'}), 200
        return jsonify({'error': 'Task not found'}), 404

@app.route('/api/notifications', methods=['GET'])
def notifications():
    """Get all notifications"""
    return jsonify({
        'notifications': notification_service.get_notifications()
    })

if __name__ == '__main__':
    logger.info(
        "Starting application",
        host=Config.APP_HOST,
        port=Config.APP_PORT,
        env=Config.APP_ENV
    )
    
    app.run(
        host=Config.APP_HOST,
        port=Config.APP_PORT,
        debug=Config.is_development()
    )
