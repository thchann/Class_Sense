# Distribution Guide

How to package and share the EngageNet project with recipients.

## What to Share

Share the entire project directory. Key files:

**Required:**
- All Python source files
- `setup.sh`, `setup.bat`, `docker-compose.setup.yml`, `Dockerfile`
- `requirements.docker.txt`, `requirements.txt`
- `README.md`, `SETUP_WINDOWS.md`, `SETUP_MACOS.md`
- Model files: `models/marlin/marlin_vit_base_ytf.encoder.pt`, `checkpoints/fusion_best.keras`
- `scripts/`, `config.py`, `utils.py`, and other supporting files

**Exclude:**
- `venv/` (created by setup)
- `.git/` (unless sharing source)
- `__pycache__/`, `.DS_Store`, `*.log`, `temp_marlin.avi`
- Large training data if not needed

## Packaging

**Option 1: Git archive (recommended)**
```bash
git archive --format=tar.gz --output=engagenet-baselines.tar.gz HEAD
```

**Option 2: Manual archive**
```bash
tar -czf engagenet-baselines.tar.gz --exclude='venv' --exclude='.git' --exclude='__pycache__' .
```

**Option 3: Docker image export (optional, large file)**
```bash
docker build -t engagenet:cpu .
docker save engagenet:cpu > engagenet-cpu.tar
```

## Directory Structure

Recipients should extract to a directory containing all source files, setup scripts, and model files. After running setup, a `venv/` directory will be created automatically.

## Recipient Requirements

**Prerequisites:**
- Docker Desktop
- Python 3.10+
- OBS Studio

**Quick Start:**
- Windows: `setup.bat`
- macOS/Linux: `chmod +x setup.sh && ./setup.sh`

## Checklist Before Sharing

- All Python files and scripts included
- Model files included
- Setup scripts included and executable
- Docker files included
- Documentation included
- `venv/` excluded (will be created by setup)
- `.git/` excluded (unless sharing source)

## Sharing Methods

Use cloud storage (Google Drive, Dropbox, OneDrive) or version control (GitHub, GitLab). Model files can be large (100MB-1GB+).

## Testing

Test on a clean system before sharing. Verify setup scripts work on target platforms.

## Security

- Model files may contain sensitive information
- Never include API keys, passwords, or tokens
- Review what's being shared
