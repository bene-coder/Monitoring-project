# Use an official lightweight Python image
FROM python:3.13-slim

# Set the working directory inside the container
WORKDIR /app

# Copy requirements.txt first to optimize Docker layer caching
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your project files into the container 
COPY . .

# Expose the port Flask runs on
EXPOSE 5000

# Tell Flask where your application entry point is located
ENV FLASK_APP=app/app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Command to run the Flask development server
CMD ["flask", "run"]

