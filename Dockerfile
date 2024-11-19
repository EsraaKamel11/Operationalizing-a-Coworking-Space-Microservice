# Use a Python base image
FROM python:3.8-slim

# Set the working directory inside the container
WORKDIR /app

# Copy requirements.txt into the container
COPY analytics/requirements.txt .

# Install system dependencies and Python dependencies
RUN apt-get update -y && apt-get install -y \
    build-essential \
    libpq-dev \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files into the container
COPY analytics/ /app/

# Expose the port the application runs on
EXPOSE 5153

# Set the command to run the application
CMD ["python", "app.py"]
