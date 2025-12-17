"""
Prinsip 4: Concurrency
Service untuk task management - bisa di-scale independently
"""
from logger import get_logger

logger = get_logger(__name__)

class TaskService:
    """Service untuk mengelola tasks"""
    
    def __init__(self):
        self.tasks = []
        self.task_id_counter = 1
        logger.info("TaskService initialized")
    
    def create_task(self, title, description):
        """Create new task"""
        task = {
            'id': self.task_id_counter,
            'title': title,
            'description': description,
            'status': 'pending'
        }
        self.tasks.append(task)
        self.task_id_counter += 1
        
        logger.info("Task created", task_id=task['id'], title=title)
        return task
    
    def get_all_tasks(self):
        """Get all tasks"""
        logger.info("Retrieving all tasks", count=len(self.tasks))
        return self.tasks
    
    def get_task(self, task_id):
        """Get specific task by ID"""
        for task in self.tasks:
            if task['id'] == task_id:
                logger.info("Task retrieved", task_id=task_id)
                return task
        
        logger.warning("Task not found", task_id=task_id)
        return None
    
    def update_task_status(self, task_id, status):
        """Update task status"""
        task = self.get_task(task_id)
        if task:
            task['status'] = status
            logger.info("Task status updated", task_id=task_id, status=status)
            return task
        return None
    
    def delete_task(self, task_id):
        """Delete task"""
        task = self.get_task(task_id)
        if task:
            self.tasks.remove(task)
            logger.info("Task deleted", task_id=task_id)
            return True
        return False
