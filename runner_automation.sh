#!/bin/bash

# Create GitHub Actions workflow directory
mkdir -p lab3/.github/workflows

# Create the deploy.yml file
cat <<EOL > lab3/.github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches:
      - dev
      - main

jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/dev'
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Build and run Docker container for dev
        run: |
          cd lab3
          docker build -f Dockerfile.dev -t myapp-dev .
          docker run -d -p 8080:80 --name myapp-dev myapp-dev

  deploy-prod:
    if: github.ref == 'refs/heads/main'
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Build and run Docker container for prod
        run: |
          cd lab3
          docker build -f Dockerfile.prod -t myapp-prod .
          docker run -d -p 8081:80 --name myapp-prod myapp-prod
EOL

# Create Dockerfile.dev
cat <<EOL > lab3/Dockerfile.dev
# Use an official Nginx image as the base image
FROM nginx:alpine

# Copy the HTML file to the Nginx HTML directory
COPY ./index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
EOL

# Create Dockerfile.prod
cat <<EOL > lab3/Dockerfile.prod
# Use an official Nginx image as the base image
FROM nginx:alpine

# Copy the HTML file to the Nginx HTML directory
COPY ./index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
EOL

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
  git init
fi

# Add all files to git
git add .

# Commit the changes
git commit -m "Initial commit with GitHub Actions workflow and Dockerfiles"

# Create and push the main branch
git checkout -b main
git push origin main

# Create and push the dev branch
git checkout -b dev
git push origin dev

echo "GitHub Actions workflow, Dockerfiles, and branches have been configured."