# Use official Python runtime as a parent image
FROM python:3.10

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages
RUN pip install --no-cache-dir -r requirements.txt

# Set the environment variable for Flask
ENV PORT 8080

# Expose the port that Flask runs on
EXPOSE 8080

# Run the application
CMD ["python", "main.py"]
