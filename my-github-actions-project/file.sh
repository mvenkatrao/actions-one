#!/bin/bash

# Define project name
PROJECT_NAME="my-github-actions-project"

# Create project structure
echo "Creating project structure..."
mkdir -p $PROJECT_NAME/src/tests
mkdir -p $PROJECT_NAME/.github/workflows

# Navigate into project folder
cd $PROJECT_NAME

# Initialize Node.js project
echo "Initializing Node.js project..."
npm init -y > /dev/null

# Install dependencies
echo "Installing dependencies..."
npm install express > /dev/null
npm install --save-dev jest > /dev/null

# Create package.json scripts
echo "Updating package.json..."
jq '.scripts.test = "jest"' package.json > temp.json && mv temp.json package.json

# Create index.js
echo "Creating src/index.js..."
cat <<EOL > src/index.js
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Hello from GitHub Actions Project!");
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
EOL

# Create a basic test file
echo "Creating test file..."
cat <<EOL > src/tests/test.js
test("Simple Test", () => {
  expect(2 + 2).toBe(4);
});
EOL

# Create Dockerfile
echo "Creating Dockerfile..."
cat <<EOL > Dockerfile
FROM node:18
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
CMD ["npm", "start"]
EXPOSE 3000
EOL

# Create CI/CD GitHub Actions workflow
echo "Creating CI/CD workflow..."
cat <<EOL > .github/workflows/ci-cd-pipeline.yml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
      - develop
  pull_request:

jobs:
  build-test-push:
    runs-on: ubuntu-latest

    steps:
      - name: Clone Repository
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install Dependencies
        run: npm install

      - name: Run Tests
        run: npm test

      - name: Build Docker Image
        run: docker build -t my-app:latest .

      - name: Push Docker Image
        run: |
          echo "\${{ secrets.DOCKER_PASSWORD }}" | docker login -u "\${{ secrets.DOCKER_USERNAME }}" --password-stdin
          docker tag my-app:latest \${{ secrets.DOCKER_REPO }}:latest
          docker push \${{ secrets.DOCKER_REPO }}:latest
EOL

# Create Deployment workflow
echo "Creating deployment workflow..."
cat <<EOL > .github/workflows/deploy.yml
name: Deploy Application

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: SSH and Deploy
        uses: appleboy/ssh-action@master
        with:
          host: \${{ secrets.SSH_HOST }}
          username: \${{ secrets.SSH_USER }}
          password: \${{ secrets.SSH_PASSWORD }}
          script: |
            cd /home/ubuntu/app
            docker pull \${{ secrets.DOCKER_REPO }}:latest
            docker stop my-app || true
            docker rm my-app || true
            docker run -d --name my-app -p 3000:3000 \${{ secrets.DOCKER_REPO }}:latest
EOL

# Create README.md
echo "Creating README.md..."
cat <<EOL > README.md
# My GitHub Actions Project

This is an example project using **GitHub Actions** for **CI/CD** with **Docker**.

## Features
- ✅ Automated Tests with **Jest**
- ✅ Builds & Pushes to **Docker Hub**
- ✅ Deploys via **SSH & Docker**
- ✅ CI/CD Workflow with **GitHub Actions**

## How to Run
1. **Install dependencies**  
   \`\`\`sh
   npm install
   \`\`\`

2. **Run the app**  
   \`\`\`sh
   npm start
   \`\`\`

3. **Run tests**  
   \`\`\`sh
   npm test
   \`\`\`
EOL

# Done
echo "✅ Project setup complete! Navigate to '$PROJECT_NAME' and start coding!"

