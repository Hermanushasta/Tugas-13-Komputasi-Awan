"""
Prinsip 3: Config
Semua konfigurasi diambil dari environment variables
"""
import os
from dotenv import load_dotenv

# Load environment variables dari .env file
load_dotenv()

class Config:
    """Configuration class untuk aplikasi"""
    
    # Application settings
    APP_NAME = os.getenv('APP_NAME', 'SimpleTaskManager')
    APP_ENV = os.getenv('APP_ENV', 'development')
    APP_HOST = os.getenv('APP_HOST', '0.0.0.0')
    APP_PORT = int(os.getenv('APP_PORT', 5000))
    
    # Logging settings
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    
    # Concurrency settings
    MAX_WORKERS = int(os.getenv('MAX_WORKERS', 4))
    
    @staticmethod
    def is_development():
        return Config.APP_ENV == 'development'
    
    @staticmethod
    def is_production():
        return Config.APP_ENV == 'production'
