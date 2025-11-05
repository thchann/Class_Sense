# EngageNet Setup Guide for Windows

This guide will walk you through setting up EngageNet on Windows to run the live engagement detection with OBS Virtual Camera and GUI dashboard.

## Prerequisites

Before starting, ensure you have:

1. **Docker Desktop for Windows** (required)
   - Download from: https://www.docker.com/products/docker-desktop
   - Install and start Docker Desktop
   - Make sure Docker is running before proceeding

2. **Python 3.10 or higher** (required)
   - Download from: https://www.python.org/downloads/
   - During installation, check "Add Python to PATH"
   - Verify installation: Open Command Prompt and run `python --version`

3. **OBS Studio** (required for camera input)
   - Download from: https://obsproject.com/
   - Install OBS Studio (we'll use the Virtual Camera feature)

## Setting Up OBS Studio

If you've never used OBS Studio before, this section will guide you through installation and configuration.

### Installation

1. **Download OBS Studio:**
   - Visit https://obsproject.com/
   - Click "Download" and select Windows
   - Download the installer (usually `OBS-Studio-XX.X.X-Windows.exe`)

2. **Install OBS Studio:**
   - Run the installer
   - Follow the installation wizard (you can use default settings)
   - Launch OBS Studio after installation

3. **First Launch Configuration:**
   - When you first open OBS, you may see an "Auto-Configuration Wizard"
   - You can skip this wizard or use the default settings (it won't affect Virtual Camera functionality)
   - Click "Cancel" or "Skip" if you want to configure manually

### Understanding the OBS Interface

OBS Studio has several key areas:
- **Scenes**: Collections of sources (you'll typically use one scene)
- **Sources**: The inputs you add (like your webcam)
- **Preview**: The main window showing what your scene looks like
- **Controls**: Buttons at the bottom for starting/stopping Virtual Camera

### Configuring OBS for EngageNet

Follow these steps to set up OBS so it can provide video input to EngageNet:

#### Step 1: Add Video Capture Device Source

1. In OBS Studio, look at the **Sources** box (bottom-left area)
2. **Right-click** in the Sources box (or click the **+** button)
3. Select **Video Capture Device**
4. In the dialog that appears:
   - **Name**: Enter a name like "Webcam" or "Camera" (this is just for organization)
   - Click **OK**
5. In the **Properties** window:
   - **Device**: Select your camera from the dropdown menu
     - Common names: "USB Camera", "Integrated Camera", "HD Webcam", etc.
   - **Resolution**: Leave as default or select your camera's native resolution
   - Click **OK**

You should now see your camera feed in the OBS preview window.

#### Step 2: Adjust Source if Needed

If the camera feed doesn't fill the preview properly:

1. **Right-click** on your video source in the Sources list
2. Select **Transform → Fit to Screen** (or choose another fit option)
3. Alternatively, you can drag the corners of the preview to resize manually

#### Step 3: Start Virtual Camera

1. In OBS Studio, go to the menu bar at the top
2. Click **Tools → Start Virtual Camera**
   - You should see a confirmation that Virtual Camera is starting
   - A status indicator may appear showing "Virtual Camera Active"
3. **Keep OBS Studio running** - You can minimize the window, but don't close it
   - If you close OBS, the Virtual Camera will stop and EngageNet won't be able to access it

### Testing Virtual Camera

To verify that OBS Virtual Camera is working:

1. Make sure Virtual Camera is started (Tools → Start Virtual Camera)
2. You can test it in another application (like Zoom, Teams, or any video conferencing app)
3. In that app, select "OBS Virtual Camera" or "OBS-Camera" as your camera source
4. If you see your video feed, Virtual Camera is working correctly

### Finding Your Camera Index on Windows

On Windows, OBS Virtual Camera may appear as different camera indices depending on your system. To find the correct index:

1. **Method 1: Try common indices**
   - The script defaults to camera index 1 (OBS Virtual Camera on many systems)
   - If that doesn't work, try index 0 (your built-in camera)
   - You can also try 2 or 3 if you have multiple cameras

2. **Method 2: Use Device Manager**
   - Press `Win + X` and select "Device Manager"
   - Expand "Cameras" or "Imaging devices"
   - Count your cameras in order (starting from 0)
   - OBS Virtual Camera may appear as "OBS Virtual Camera" or "OBS-Camera"

3. **Method 3: Test with the script**
   - Run the script with different indices: `set VIDEO_SOURCE=0` then try `set VIDEO_SOURCE=1`, etc.
   - The script will show an error if it can't open the camera, so you can try different indices until one works

## Quick Setup (Automated)

The easiest way to set up is using the automated setup script:

1. **Open Command Prompt** or PowerShell in the project directory

2. **Run the setup script:**
   ```cmd
   setup.bat
   ```

3. **Wait for completion** - The script will:
   - Check that Docker and Python are installed
   - Build the Docker image with all dependencies
   - Extract Python packages from Docker to a local virtual environment
   - Check for system dependencies (ffmpeg, Visual C++ redistributables)
   - Validate the installation

4. **Follow the instructions** displayed at the end of the setup

## What Happens During Setup

### Step 1: Docker Build
The setup script builds a Docker image containing all Python dependencies. This ensures you get the exact same working environment that was tested.

### Step 2: Package Extraction
Python packages are extracted from the Docker container to a local `venv/` directory. These packages are now available to your host Python installation.

### Step 3: System Dependencies
The script checks for Windows-specific dependencies:
- **ffmpeg**: Required for video processing
- **Visual C++ Redistributables**: Required for some Python packages (TensorFlow, etc.)

## System Dependencies

### FFmpeg

If ffmpeg is not detected, install it using one of these methods:

**Option 1: Using winget (Windows Package Manager)**
```cmd
winget install Gyan.FFmpeg
```

**Option 2: Using Chocolatey**
```cmd
choco install ffmpeg
```

**Option 3: Manual Installation**
1. Download from: https://ffmpeg.org/download.html
2. Extract to a folder (e.g., `C:\ffmpeg`)
3. Add `C:\ffmpeg\bin` to your system PATH
4. Restart Command Prompt

### Visual C++ Redistributables

If not already installed, download and install:
- **Visual C++ Redistributables**: https://aka.ms/vs/17/release/vc_redist.x64.exe

This is usually installed automatically with many applications, but you may need to install it manually if you see DLL errors.

## Running EngageNet

### 1. Activate the Virtual Environment

```cmd
venv\Scripts\activate.bat
```

You should see `(engagenet)` at the start of your command prompt.

### 2. Start OBS Virtual Camera

If you haven't set up OBS Studio yet, see the **"Setting Up OBS Studio"** section above for detailed instructions.

Once OBS is configured:
1. Open **OBS Studio** (if not already running)
2. Make sure your camera source is visible in the preview
3. Go to **Tools → Start Virtual Camera**
4. Verify that Virtual Camera is active (you should see a status indicator)
5. Keep OBS Studio running (you can minimize the window, but don't close it)

**Note:** On Windows, OBS Virtual Camera is usually camera index 1, but this may vary. If the script can't find your camera, see the troubleshooting section below for how to find the correct camera index.

### 3. Run the Live Engagement Detection

```cmd
python live_marlin_openface_combination.py
```

The script will automatically detect OBS Virtual Camera (usually camera index 1). You should see a GUI window with the live engagement dashboard.

**Press 'q' in the GUI window to quit.**

## Model Files

Ensure you have the required model files in place:

- `models/marlin/marlin_vit_base_ytf.encoder.pt` - MARLIN encoder model
- `checkpoints/fusion_best.keras` - EngageNet fusion model

If these files are missing, contact the project maintainer for access.

## Troubleshooting

### Docker Issues

**Problem:** "Docker is not running"
- **Solution:** Start Docker Desktop and wait for it to fully start (whale icon in system tray)

**Problem:** "docker compose" command not found
- **Solution:** Update Docker Desktop to the latest version, which includes Compose V2

### Python Issues

**Problem:** "Python is not recognized"
- **Solution:** Reinstall Python and make sure to check "Add Python to PATH" during installation

**Problem:** "Python version too old"
- **Solution:** Install Python 3.10 or higher from python.org

### Package Import Errors

**Problem:** "No module named 'torch'" or similar
- **Solution:** 
  1. Make sure you activated the virtual environment: `venv\Scripts\activate.bat`
  2. Re-run `setup.bat` to reinstall packages

**Problem:** "DLL load failed" or "ImportError"
- **Solution:** Install Visual C++ Redistributables (see above)

### OBS Issues

**Problem:** "OBS Virtual Camera" not showing in Tools menu
- **Solution:** 
  1. Make sure you have the latest version of OBS Studio (Virtual Camera is built-in for recent versions)
  2. Close and restart OBS Studio
  3. If still not available, try reinstalling OBS Studio from obsproject.com

**Problem:** Virtual Camera starts but EngageNet can't see it
- **Solution:** 
  1. Make sure OBS Virtual Camera is actually running (check for "Virtual Camera Active" indicator)
  2. Try stopping and restarting Virtual Camera: Tools → Stop Virtual Camera, then Tools → Start Virtual Camera
  3. Check the camera index (see "Finding Your Camera Index on Windows" section above)

**Problem:** OBS shows "No Sources" or black screen
- **Solution:** 
  1. Make sure you added a Video Capture Device source (see "Setting Up OBS Studio" section)
  2. Check that your camera is selected in the source properties
  3. Try removing and re-adding the Video Capture Device source

### Camera Issues

**Problem:** "Could not open video source"
- **Solution:** 
  1. Make sure OBS Virtual Camera is running (Tools → Start Virtual Camera)
  2. Verify Virtual Camera is active in OBS
  3. Try using a different camera index: `set VIDEO_SOURCE=0` then run the script
  4. Check that no other application is using the camera
  5. Restart OBS Studio if the issue persists

**Problem:** Script can't find OBS Virtual Camera
- **Solution:** 
  1. Verify OBS Virtual Camera is started and active
  2. Find the correct camera index (see "Finding Your Camera Index on Windows" section above)
  3. Try manually specifying different indices: 
     - `set VIDEO_SOURCE=0` then run the script
     - `set VIDEO_SOURCE=1` then run the script
     - `set VIDEO_SOURCE=2` then run the script
  4. Check Device Manager to see how many cameras are detected
  5. Restart OBS Studio and try again

**Problem:** How to find the correct camera index on Windows
- **Solution:** See the "Finding Your Camera Index on Windows" section in "Setting Up OBS Studio" above for detailed methods

### GUI Issues

**Problem:** No GUI window appears
- **Solution:** The script runs in headless mode if GUI is not available. Check:
  1. You're running on the host (not in Docker)
  2. You have a display available
  3. Try setting `set HEADLESS=0` explicitly

## Manual Installation (Alternative)

If the automated setup script fails, you can install manually:

1. **Create virtual environment:**
   ```cmd
   python -m venv venv
   ```

2. **Activate it:**
   ```cmd
   venv\Scripts\activate.bat
   ```

3. **Install packages from requirements:**
   ```cmd
   pip install -r requirements.txt
   ```

Note: Manual installation may have version conflicts. The Docker-first approach is recommended for consistency.

## Using Different Video Sources

Instead of OBS Virtual Camera, you can use:

- **Direct camera:** `set VIDEO_SOURCE=0` (use your built-in/webcam)
- **RTSP stream:** `set VIDEO_SOURCE=rtsp://...`
- **HTTP stream:** `set VIDEO_SOURCE=http://...`

## Next Steps

- See `README.md` for more information about the project
- See `DISTRIBUTION.md` if you need to share this project with others

## Getting Help

If you encounter issues not covered here:
1. Check that all prerequisites are installed
2. Verify model files are in place
3. Check Docker and Python versions
4. Contact the project maintainer with error messages
