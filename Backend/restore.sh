#!/bin/sh

echo "Starting Strapi container..."

if [ ! -d "/app/src" ]; then
  echo "Creating Strapi project..."

  npx create-strapi-app@latest /app \
    --quickstart \
    --no-run \
    --skip-cloud
fi

cd /app

if [ -f "/backup/backup.tar.gz" ]; then
  echo "Restoring backup..."
  tar -xzf /backup/backup.tar.gz -C /app
fi

if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

echo "Starting Strapi..."
npm run develop