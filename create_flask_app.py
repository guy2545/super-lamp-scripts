#!/usr/bin/env python3

import os
import sys

def create_flask_project(project_name):
    """
    Creates a basic Flask project directory structure and initial files.

    Args:
        project_name (str): The name of the project directory to create.
    """
    if not project_name:
        print("Usage: python create_flask_app.py <project_directory_name>")
        sys.exit(1)

    # Check if the directory already exists
    if os.path.exists(project_name):
        print(f"Error: Directory '{project_name}' already exists.")
        sys.exit(1)

    print(f"Creating Flask project structure in '{project_name}'...")

    # Create the root project directory
    try:
        os.makedirs(project_name)
        os.chdir(project_name)
    except OSError as e:
        print(f"Error creating or changing directory: {e}")
        sys.exit(1)

    # Define the directory structure to create
    dirs_to_create = [
        'app/static/css',
        'app/static/js',
        'app/static/images',
        'app/templates'
    ]

    # Create main application package directory and subdirectories
    for dir_path in dirs_to_create:
        try:
            os.makedirs(dir_path, exist_ok=True)
        except OSError as e:
            print(f"Error creating directory '{dir_path}': {e}")
            sys.exit(1)

    # Define the content for each file
    file_contents = {
        'app/__init__.py': """from flask import Flask
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

# Import routes after app is created to avoid circular imports
from app import routes #, models
""",

        'app/routes.py': """from flask import render_template
from app import app

@app.route('/')
@app.route('/index')
def index():
    user = {'username': 'Flask User'}
    return render_template('index.html', title='Home', user=user)
""",

        'app/models.py': """# Optional: Add database models here, e.g.:
# from app import db
#
# class User(db.Model):
#     id = db.Column(db.Integer, primary_key=True)
#     username = db.Column(db.String(64), index=True, unique=True)
#     email = db.Column(db.String(120), index=True, unique=True)
#     password_hash = db.Column(db.String(128))
#
#     def __repr__(self):
#         return '<User {}>'.format(self.username)
""", # Keep models.py content simple initially, or empty

        'config.py': """import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    # Add other configuration variables like database URI etc.
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \\
    #     'sqlite:///' + os.path.join(os.path.abspath(os.path.dirname(__file__)), 'app.db')
    # SQLALCHEMY_TRACK_MODIFICATIONS = False
""",

        'run.py': """from app import app

if __name__ == '__main__':
    # Set debug=True for development environment
    # Host='0.0.0.0' makes it accessible on the network
    # Use `flask run` command in production or with gunicorn/wsgi server
    app.run(host='0.0.0.0', port=5000, debug=True)
""",

        'requirements.txt': """Flask
# Add other dependencies here, e.g.:
# Flask-SQLAlchemy
# Flask-Migrate
# python-dotenv
""",

        '.gitignore': """# Virtual Environment
venv/
.venv/
env/
.env
*.pyenv

# Bytecode
__pycache__/
*.pyc
*.pyo
*.pyd

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Instance folder (Flask)
instance/

# Cache
.pytest_cache/
.mypy_cache/
.ruff_cache/
.coverage

# Secrets (if not using .env)
*.secret
*.pem
*.key

# OS generated files
.DS_Store
Thumbs.db
""",

        'app/templates/base.html': """<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {% if title %}
    <title>{{ title }} - My Flask App</title>
    {% else %}
    <title>Welcome to My Flask App</title>
    {% endif %}

    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
  </head>
  <body>
    <div>My Flask App: <a href="{{ url_for('index') }}">Home</a></div>
    <hr>
    {% block content %}{% endblock %}

    <script src="{{ url_for('static', filename='js/script.js') }}"></script>
  </body>
</html>
""",

        'app/templates/index.html': """{% extends "base.html" %}

{% block content %}
    <h1>Hello, {{ user.username }}!</h1>
    <p>Welcome to your new Flask app structure.</p>
{% endblock %}
""",

        # Create empty static files
        'app/static/css/style.css': "",
        'app/static/js/script.js': ""
    }

    # Create essential Python files and templates with content
    for file_path, content in file_contents.items():
        try:
            with open(file_path, 'w') as f:
                f.write(content)
            # print(f"Created {file_path}") # Optional: uncomment to see file creation progress
        except IOError as e:
            print(f"Error writing file '{file_path}': {e}")
            # Clean up partially created directories? For this simple script, maybe just exit.
            sys.exit(1)


    print("-----------------------------------------")
    print(f"Flask project '{project_name}' created successfully.")
    print("Next steps:")
    print(f"1. cd {project_name}")
    print("2. Create and activate a virtual environment: python3 -m venv venv && source venv/bin/activate")
    print("3. Install dependencies: pip install -r requirements.txt")
    print("4. Run the development server: python run.py")
    print("-----------------------------------------")

    sys.exit(0)

if __name__ == "__main__":
    # Get project name from command line arguments
    project_directory_name = sys.argv[1] if len(sys.argv) > 1 else None
    create_flask_project(project_directory_name)