# Use an official lightweight Python image
FROM python:3.13-slim

# Set environment optimizations
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:$PATH"

# Create a dedicated non-root system user and group
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -m -s /bin/bash appuser

# Set the working directory inside the container
WORKDIR /app

# Copy requirements.txt first to optimize Docker layer caching
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files and grant ownership to the non-root user
COPY --chown=appuser:appgroup . .

# Switch to the secure non-root user
USER appuser

# Copy the only necessary files of your project into the container 
COPY app/ .

# Expose the port Flask runs on
EXPOSE 5000

# Run Gunicorn binding to port 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]

