# AgenticSeek Digital Ocean Deployment

## 🚀 Fresh Deploy (One Command)

```bash
git clone https://github.com/zeroxf89/agenticSeek.git
cd agenticSeek
sudo ./final_deploy.sh
```

## 🔍 Check Deployment Status

```bash
./check_deployment.sh
```

## 🧪 Test Frontend Structure

```bash
./test_frontend_structure.sh
```

## 🔄 Re-deploy (Pull & Run)

```bash
cd agenticSeek
sudo ./redeploy.sh
```

## 🎯 Access

- Frontend: http://159.223.34.36:3000
- Backend: http://159.223.34.36:8000

## 🛠️ Ultimate Fix - All Issues Resolved

### ✅ Fixed Issues:
- **PPA deadsnakes**: No more Ubuntu 24.10 oracular PPA errors
- **Audio packages**: Skip playsound, pyaudio, librosa (not needed for OpenAI)
- **Docker conflicts**: Clean existing containers before start
- **npm not found**: Install Node.js from NodeSource
- **uvicorn missing**: Proper virtual environment activation
- **Tmp space**: Clean tmp directories before build
- **CORS errors**: Frontend API URL configuration
- **Build wheel errors**: Use system Python, skip problematic packages

### 🎯 Strategy:
- Use **system Python** (no PPA needed)
- Install **only essential packages** for OpenAI API
- **Clean environment** before deployment
- **Proper error handling** and health checks
- **Simple, reliable** deployment process

## 📋 Manual Deploy (if needed)

```bash
git clone https://github.com/zeroxf89/agenticSeek.git
cd agenticSeek
export SERVER_IP=159.223.34.36
export OPENAI_API_KEY=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
sudo ./deploy_ultimate.sh
```

## 🔧 Troubleshooting

If deployment fails:

1. **Check logs**: `tail -f backend.log frontend.log`
2. **Check services**: `ps aux | grep -E "(python|npm)"`
3. **Check Docker**: `docker ps` and `docker-compose logs`
4. **Clean restart**: Stop all services and run `./redeploy.sh`

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