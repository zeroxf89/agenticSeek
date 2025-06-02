# AgenticSeek Digital Ocean Deployment

## 🚀 Fresh Deploy (One Command)

```bash
git clone https://github.com/zeroxf89/agenticSeek.git
cd agenticSeek
sudo ./quick_deploy.sh
```

## 🔄 Re-deploy (Pull & Run)

```bash
cd agenticSeek
sudo ./redeploy.sh
```

## 🎯 Access

- Frontend: http://159.223.34.36:3000
- Backend: http://159.223.34.36:8000

## 🛠️ What's Fixed

- ✅ Python 3.12 compatibility issues
- ✅ Uses Python 3.10 specifically 
- ✅ Skips heavy ML packages (not needed for OpenAI)
- ✅ Installs only essential dependencies
- ✅ Handles build dependencies properly
- ✅ Easy re-deployment script

## 📋 Manual Deploy (if needed)

```bash
git clone https://github.com/zeroxf89/agenticSeek.git
cd agenticSeek
export SERVER_IP=159.223.34.36
export OPENAI_API_KEY=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
sudo ./deploy_fixed.sh
```

## What the script does:

1. ✅ Installs system dependencies (Python 3.10, Docker, Node.js)
2. ✅ Creates Python virtual environment
3. ✅ Installs Python packages with space optimization
4. ✅ Configures for OpenAI API (not local LLM)
5. ✅ Sets up environment variables
6. ✅ Starts Docker services (SearXNG, Redis, Frontend)
7. ✅ Configures frontend for your server IP

## Troubleshooting:

- **Space issues**: Script cleans package cache automatically
- **Docker issues**: Script restarts Docker service
- **Port conflicts**: Script stops existing containers first

## Management:

```bash
# View logs
docker-compose logs

# Stop services
docker-compose down

# Restart services
docker-compose restart
```