#!/bin/bash

# Create directories
echo "Creating directory structure..."
mkdir -p backend/app/{core,schemas,api,agents,services,orchestrator}
mkdir -p frontend/app
mkdir -p frontend/components/{dashboard,projects}
mkdir -p frontend/lib
mkdir -p frontend/store
mkdir -p scripts
mkdir -p .github/workflows
mkdir -p docs
mkdir -p data/projects

# Backend files
echo "Creating backend files..."

cat > backend/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pydantic-settings==2.1.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
redis==5.0.1
aioredis==2.0.1
httpx==0.25.2
openai==1.3.9
anthropic==0.7.11
python-dotenv==1.0.0
pytest==7.4.3
pytest-asyncio==0.21.1
black==23.12.0
flake8==6.1.0
mypy==1.7.1
python-multipart==0.0.6
EOF

cat > backend/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Create all Python __init__.py files
touch backend/app/__init__.py
touch backend/app/core/__init__.py
touch backend/app/schemas/__init__.py
touch backend/app/api/__init__.py
touch backend/app/agents/__init__.py
touch backend/app/services/__init__.py
touch backend/app/orchestrator/__init__.py

# Frontend files
echo "Creating frontend files..."

cat > frontend/package.json << 'EOF'
{
  "name": "manipula-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.0",
    "zustand": "^4.4.0",
    "tailwindcss": "^3.3.0",
    "@headlessui/react": "^1.7.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/react": "^18.0.0",
    "jest": "^29.7.0"
  }
}
EOF

cat > frontend/Dockerfile << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
EOF

# Infrastructure files
echo "Creating infrastructure files..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: manipula_user
      POSTGRES_PASSWORD: manipula_password
      POSTGRES_DB: manipula_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://manipula_user:manipula_password@postgres:5432/manipula_db
      REDIS_URL: redis://redis:6379/0
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend:/app

  frontend:
    build: ./frontend
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:8000
    ports:
      - "3000:3000"
    depends_on:
      - backend
    volumes:
      - ./frontend:/app

volumes:
  postgres_data:
  redis_data:
EOF

cat > .env.example << 'EOF'
OPENAI_API_KEY=sk-your-key
ANTHROPIC_API_KEY=sk-ant-your-key
PRIMARY_MODEL=gpt-4
COST_LIMIT_USD=100.0
EOF

echo "✅ Project structure created successfully!"
echo ""
echo "📚 Now create these Python files with the code provided above:"
echo "  - backend/app/main.py"
echo "  - backend/app/core/config.py"
echo "  - backend/app/schemas/state.py"
echo "  - backend/app/agents/base_agent.py"
echo "  - backend/app/agents/idea_agent.py"
echo "  - backend/app/agents/backend_agent.py"
echo "  - backend/app/agents/frontend_agent.py"
echo "  - backend/app/agents/qa_agent.py"
echo "  - backend/app/services/state_manager.py"
echo "  - backend/app/services/cost_tracker.py"
echo "  - backend/app/services/model_router.py"
echo "  - backend/app/orchestrator/engine.py"
echo "  - backend/app/api/health.py"
echo "  - backend/app/api/projects.py"
echo "  - backend/app/api/orchestrator.py"
echo ""
echo "  - frontend files (TypeScript/React)"
echo "  - Documentation files"
EOF
