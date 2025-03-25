# Use official Python runtime as a parent image
FROM python:3.10

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set the environment variable for Flask
ENV PORT 8080

# Expose the port Flask will run on
EXPOSE 8080

# Use gunicorn instead of running Flask directly
CMD ["gunicorn", "-b", "0.0.0.0:8080", "main:app"]
