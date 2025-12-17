"""
Prinsip 5: Logs
Treat logs as event streams - output ke stdout, tidak ke file
Menggunakan structured logging untuk memudahkan parsing
"""
import logging
import sys
import json
from datetime import datetime
from config import Config

class StructuredLogger:
    """Custom logger yang mengoutput structured logs (JSON format)"""
    
    def __init__(self, name):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(getattr(logging, Config.LOG_LEVEL))
        
        # Handler ke stdout (bukan file!)
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(getattr(logging, Config.LOG_LEVEL))
        
        # Formatter
        formatter = logging.Formatter('%(message)s')
        handler.setFormatter(formatter)
        
        # Avoid duplicate handlers
        if not self.logger.handlers:
            self.logger.addHandler(handler)
    
    def _log(self, level, message, **kwargs):
        """Internal method untuk create structured log"""
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': level,
            'message': message,
            'app': Config.APP_NAME,
            'env': Config.APP_ENV
        }
        
        # Tambahkan extra fields
        if kwargs:
            log_entry['extra'] = kwargs
        
        self.logger.log(
            getattr(logging, level),
            json.dumps(log_entry)
        )
    
    def info(self, message, **kwargs):
        self._log('INFO', message, **kwargs)
    
    def warning(self, message, **kwargs):
        self._log('WARNING', message, **kwargs)
    
    def error(self, message, **kwargs):
        self._log('ERROR', message, **kwargs)
    
    def debug(self, message, **kwargs):
        self._log('DEBUG', message, **kwargs)

# Factory function
def get_logger(name):
    return StructuredLogger(name)
