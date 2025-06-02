# AgenticSeek Digital Ocean Deployment

## Quick Start

1. **Clone repository on your Digital Ocean droplet:**
```bash
git clone https://github.com/zeroxf89/agenticSeek.git
cd agenticSeek
```

2. **Set your configuration:**
```bash
export SERVER_IP=159.223.34.36
export OPENAI_API_KEY=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
```

3. **Deploy:**
```bash
chmod +x deploy_simple.sh
sudo ./deploy_simple.sh
```

4. **Start backend:**
```bash
source agentic_seek_env/bin/activate
python3 api.py
```

5. **Access:**
- Frontend: http://159.223.34.36:3000
- Backend: http://159.223.34.36:8000

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