import logging
import os

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy

logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configure PostgreSQL connection from environment variables
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("DB_NAME", "devops_db")

postgres_url = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv("DATABASE_URL", postgres_url)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Simple Model to test data persistence
class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)

# Ensure database tables are created on startup
with app.app_context():
    try:
        db.create_all()
    except Exception:
        logger.exception("Database creation failed")
@app.route('/')
def home():
    return "Welcome to Flask with PostgreSQL and Docker Compose!"

@app.route('/health')
def health():
    try:
        # Check database connection
        db.session.execute(db.text('SELECT 1'))
        db_status = "connected"
    except Exception:
        logger.exception("Database health check failed")
        return jsonify(status="unhealthy", database="disconnected"), 500
    
    return jsonify(status="healthy", database=db_status), 200

@app.route('/items', methods=['POST', 'GET'])
def manage_items():
    if request.method == 'POST':
        data = request.json
        new_item = Item(name=data.get('name'))
        db.session.add(new_item)
        db.session.commit()
        return jsonify({"id": new_item.id, "name": new_item.name}), 201
    
    items = Item.query.all()
    return jsonify([{"id": item.id, "name": item.name} for item in items])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)