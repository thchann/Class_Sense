@echo off
REM Setup script for Windows
REM Uses Docker to install Python packages, then checks for system dependencies

setlocal enabledelayedexpansion

echo ========================================
echo EngageNet Native Setup
echo ========================================
echo.

REM Check if Docker is installed
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not installed.
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    exit /b 1
)

echo [OK] Docker found

REM Check if Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running.
    echo Please start Docker Desktop and try again.
    exit /b 1
)

echo [OK] Docker is running

REM Check Python version
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python is not installed.
    echo Please install Python 3.10 or higher from: https://www.python.org/downloads/
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [OK] Python %PYTHON_VERSION% found

REM Check Python version is 3.10+
python -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python 3.10+ is required. Found %PYTHON_VERSION%
    exit /b 1
)

echo.
echo Creating virtual environment directory...
if not exist "venv\lib\python3.10\site-packages" (
    mkdir "venv\lib\python3.10\site-packages"
)
echo [OK] Created venv directory
echo.

echo Building Docker image and extracting Python packages...
echo This may take several minutes on first run...
echo.

REM Determine docker compose command
docker compose version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set COMPOSE_CMD=docker compose
) else (
    docker-compose version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set COMPOSE_CMD=docker-compose
    ) else (
        echo [ERROR] Docker Compose is not available.
        exit /b 1
    )
)

%COMPOSE_CMD% -f docker-compose.setup.yml up --build
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to extract Python packages
    exit /b 1
)

echo [OK] Python packages extracted successfully
echo.

echo Creating virtual environment configuration...
REM Get Python home directory
for /f "tokens=*" %%i in ('python -c "import sys; print(sys.prefix)"') do set PYTHON_HOME=%%i

(
echo home = %PYTHON_HOME%
echo include-system-site-packages = false
echo version = %PYTHON_VERSION%
) > venv\pyvenv.cfg

echo [OK] Virtual environment configured
echo.

echo Creating activation scripts...
if not exist "venv\Scripts" mkdir "venv\Scripts"

(
echo @echo off
echo setlocal
echo set VIRTUAL_ENV=%%~dp0..
echo set PATH=%%VIRTUAL_ENV%%\lib\python3.10\site-packages;%%PATH%%
echo set PYTHONPATH=%%VIRTUAL_ENV%%\lib\python3.10\site-packages;%%PYTHONPATH%%
echo set PROMPT=^(engagenet^) %%PROMPT%%
echo endlocal
) > venv\Scripts\activate.bat

echo [OK] Virtual environment configured
echo.

echo Checking system dependencies...
echo.

REM Check for ffmpeg
where ffmpeg >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] ffmpeg is not installed.
    echo.
    echo Please install ffmpeg using one of these methods:
    echo 1. Using winget (if available):
    echo    winget install Gyan.FFmpeg
    echo.
    echo 2. Using Chocolatey (if installed):
    echo    choco install ffmpeg
    echo.
    echo 3. Download from: https://ffmpeg.org/download.html
    echo    Add ffmpeg.exe to your PATH
    echo.
) else (
    echo [OK] ffmpeg found
)

echo.
echo Checking Visual C++ Redistributables...
REM Check for VC++ redistributables (simplified check)
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Visual C++ Redistributables may be required for some packages.
    echo Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe
    echo.
) else (
    echo [OK] Visual C++ Redistributables found
)

echo.
echo Validating installation...
python -c "import sys; sys.path.insert(0, 'venv\\lib\\python3.10\\site-packages'); import torch; import tensorflow; import cv2; import mediapipe; print('[OK] Key packages are importable')" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Some packages may not be importable yet.
    echo This is normal if system libraries are missing.
)

echo.
echo ========================================
echo [OK] Setup complete!
echo ========================================
echo.
echo Next steps:
echo 1. Activate the virtual environment:
echo    venv\Scripts\activate.bat
echo.
echo 2. Start OBS Studio and enable Virtual Camera:
echo    - Open OBS Studio
echo    - Tools -^> Start Virtual Camera
echo.
echo 3. Run the live engagement detection:
echo    python live_marlin_openface_combination.py
echo.
echo The script will automatically detect OBS Virtual Camera (usually camera index 1).
echo.
echo Note: Make sure model files are in place:
echo   - models\marlin\marlin_vit_base_ytf.encoder.pt
echo   - checkpoints\fusion_best.keras
echo.

endlocal
