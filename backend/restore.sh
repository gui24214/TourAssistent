#!/bin/sh

echo "🚀 Starting Strapi container..."

# Criar projeto se não existir
if [ ! -f "/app/package.json" ]; then
  echo "📦 Creating Strapi project..."

  npx create-strapi-app@latest /app \
    --quickstart \
    --no-run \
    --skip-cloud
fi

cd /app

# Restaurar backup se existir
if [ -f "/backup/backup.tar.gz" ]; then
  echo "♻️ Restoring backup..."
  tar -xzf /backup/backup.tar.gz -C /app
fi

# Instalar dependências se necessário
if [ ! -d "node_modules" ] || [ ! -f "node_modules/.bin/strapi" ]; then
  echo "📥 Installing dependencies..."
  npm install
fi
echo "🔥 Starting Strapi..."
npm run develop