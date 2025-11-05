# EngageNet Setup Guide for macOS

This guide will walk you through setting up EngageNet on macOS to run the live engagement detection with OBS Virtual Camera and GUI dashboard.

## Prerequisites

Before starting, ensure you have:

1. **Docker Desktop for Mac** (required)
   - Download from: https://www.docker.com/products/docker-desktop
   - Install and start Docker Desktop
   - Make sure Docker is running (whale icon in menu bar)

2. **Python 3.10 or higher** (required)
   - macOS typically comes with Python 2.7 or 3.x
   - Check version: `python3 --version`
   - If needed, install from: https://www.python.org/downloads/
   - Or use Homebrew: `brew install python@3.10`

3. **Homebrew** (recommended, for system dependencies)
   - Install from: https://brew.sh/
   - Run: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

4. **OBS Studio** (required for camera input)
   - Download from: https://obsproject.com/
   - Or install via Homebrew: `brew install --cask obs`

## Setting Up OBS Studio

If you've never used OBS Studio before, this section will guide you through installation and configuration.

### Installation

1. **Download OBS Studio:**
   - **Option 1: Direct Download**
     - Visit https://obsproject.com/
     - Click "Download" and select macOS
     - Download the installer (usually a `.dmg` file)
     - Open the `.dmg` file and drag OBS Studio to your Applications folder
   
   - **Option 2: Homebrew (Recommended)**
     - If you have Homebrew installed, run: `brew install --cask obs`
     - This automatically handles installation and updates

2. **First Launch:**
   - Open OBS Studio from Applications (or Launchpad)
   - You may see a "First Launch" wizard
   - You can skip this wizard or use default settings (it won't affect Virtual Camera functionality)
   - Click "Skip" or "Cancel" if you want to configure manually

3. **macOS Permissions:**
   - When you first open OBS, macOS may prompt you for camera and microphone permissions
   - Click "Allow" to grant these permissions
   - If you missed the prompt, see "macOS Camera Permissions for OBS" section below

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
   - **Name**: Enter a name like "FaceTime HD Camera" or "Camera" (this is just for organization)
   - Click **OK**
5. In the **Properties** window:
   - **Device**: Select your camera from the dropdown menu
     - Common names on macOS: "FaceTime HD Camera", "USB Camera", "OBS Virtual Camera", etc.
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
   - On macOS, you may see a system notification about Virtual Camera
3. **Keep OBS Studio running** - You can minimize the window, but don't close it
   - If you close OBS, the Virtual Camera will stop and EngageNet won't be able to access it

### macOS Camera Permissions for OBS

macOS requires explicit camera permissions for both OBS Studio and your terminal application. You need to grant permissions to **both**:

#### For OBS Studio:

1. Open **System Settings** (or **System Preferences** on older macOS)
2. Go to **Privacy & Security** (or **Security & Privacy**)
3. Select **Camera** from the left sidebar
4. **Enable the checkbox** next to "OBS Studio"
5. If OBS Studio is not listed, you may need to:
   - Open OBS Studio once (it will trigger the permission prompt)
   - Or restart OBS Studio after enabling permissions

#### For Terminal (or your terminal app):

1. Open **System Settings** → **Privacy & Security** → **Camera**
2. **Enable the checkbox** next to "Terminal" (or "iTerm2" if you use that)
3. **Restart Terminal** after granting permissions

**Important:** Both OBS Studio and Terminal need camera permissions for EngageNet to access OBS Virtual Camera.

### Testing Virtual Camera

To verify that OBS Virtual Camera is working:

1. Make sure Virtual Camera is started (Tools → Start Virtual Camera)
2. You can test it in another application (like FaceTime, Zoom, or any video conferencing app)
3. In that app, select "OBS Virtual Camera" or "OBS-Camera" as your camera source
4. If you see your video feed, Virtual Camera is working correctly

### Finding Your Camera Index on macOS

On macOS, OBS Virtual Camera is typically camera index 1, but you can verify:

1. **Method 1: Use ffmpeg**
   ```bash
   ffmpeg -f avfoundation -list_devices true -i ""
   ```
   - Look through the output for "OBS Virtual Camera" or "OBS-Camera"
   - The order in the list corresponds to camera indices (starting from 0)

2. **Method 2: Try common indices**
   - Index 0: Usually your built-in FaceTime HD Camera
   - Index 1: Usually OBS Virtual Camera (when running)
   - Try different indices if needed

3. **Method 3: Test with the script**
   - Run the script with different indices: `VIDEO_SOURCE=0 python live_marlin_openface_combination.py`
   - Then try `VIDEO_SOURCE=1`, etc.
   - The script will show an error if it can't open the camera

## Quick Setup (Automated)

The easiest way to set up is using the automated setup script:

1. **Open Terminal** in the project directory

2. **Make the script executable** (if needed):
   ```bash
   chmod +x setup.sh
   ```

3. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

4. **Wait for completion** - The script will:
   - Check that Docker and Python are installed
   - Build the Docker image with all dependencies
   - Extract Python packages from Docker to a local virtual environment
   - Install system dependencies (ffmpeg) via Homebrew
   - Validate the installation

5. **Follow the instructions** displayed at the end of the setup

## What Happens During Setup

### Step 1: Docker Build
The setup script builds a Docker image containing all Python dependencies. This ensures you get the exact same working environment that was tested.

### Step 2: Package Extraction
Python packages are extracted from the Docker container to a local `venv/` directory. These packages are now available to your host Python installation.

### Step 3: System Dependencies
The script installs macOS-specific dependencies:
- **ffmpeg**: Required for video processing (installed via Homebrew)

## System Dependencies

### FFmpeg

The setup script will automatically install ffmpeg via Homebrew if it's not already installed.

**Manual installation** (if needed):
```bash
brew install ffmpeg
```

**Verify installation:**
```bash
ffmpeg -version
```

## Camera Permissions

macOS requires camera permissions for both OBS Studio and your terminal application to access cameras. This is a security feature of macOS.

### Why Both Are Needed

- **OBS Studio** needs camera permission to capture video from your physical camera
- **Terminal** (or your terminal app) needs camera permission for the EngageNet script to access OBS Virtual Camera

### Granting Permissions

1. Open **System Settings** (or **System Preferences** on older macOS)
2. Go to **Privacy & Security** (or **Security & Privacy**)
3. Select **Camera** from the left sidebar
4. **Enable checkboxes** for:
   - **OBS Studio** (required for Virtual Camera to work)
   - **Terminal** (or "iTerm2" if you use that terminal app)
5. **Restart both applications** after granting permissions:
   - Quit and reopen OBS Studio
   - Quit and reopen Terminal

If you're using a different terminal (iTerm2, etc.), grant permissions to that application instead.

**Note:** If you haven't set up OBS Studio yet, see the "Setting Up OBS Studio" section above for detailed instructions, including OBS-specific permissions.

## Running EngageNet

### 1. Activate the Virtual Environment

```bash
source venv/bin/activate
```

You should see `(engagenet)` at the start of your terminal prompt.

### 2. Start OBS Virtual Camera

If you haven't set up OBS Studio yet, see the **"Setting Up OBS Studio"** section above for detailed instructions.

Once OBS is configured:
1. Open **OBS Studio** (if not already running)
2. Make sure your camera source is visible in the preview
3. Go to **Tools → Start Virtual Camera**
4. Verify that Virtual Camera is active (you should see a status indicator)
5. Keep OBS Studio running (you can minimize the window, but don't close it)

**Note:** On macOS, OBS Virtual Camera is usually camera index 1. Make sure both OBS Studio and Terminal have camera permissions (see "Camera Permissions" section above).

### 3. Run the Live Engagement Detection

```bash
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

**Problem:** "Docker is not installed"
- **Solution:** Install Docker Desktop from docker.com and start it

**Problem:** "Docker is not running"
- **Solution:** Start Docker Desktop from Applications and wait for the whale icon to appear in the menu bar

**Problem:** "docker compose" command not found
- **Solution:** Update Docker Desktop to the latest version, which includes Compose V2

### Python Issues

**Problem:** "Python 3 is not installed"
- **Solution:** 
  - Install via Homebrew: `brew install python@3.10`
  - Or download from python.org

**Problem:** "Python version too old"
- **Solution:** Install Python 3.10 or higher

**Problem:** "command not found: python3"
- **Solution:** Check your PATH or install Python via Homebrew

### Package Import Errors

**Problem:** "No module named 'torch'" or similar
- **Solution:** 
  1. Make sure you activated the virtual environment: `source venv/bin/activate`
  2. Re-run `./setup.sh` to reinstall packages

**Problem:** Import errors related to system libraries
- **Solution:** Make sure system dependencies are installed:
  ```bash
  brew install ffmpeg
  ```

### OBS Issues

**Problem:** "OBS Virtual Camera" not showing in Tools menu
- **Solution:** 
  1. Make sure you have the latest version of OBS Studio (Virtual Camera is built-in for recent versions)
  2. Close and restart OBS Studio
  3. If still not available, try reinstalling OBS Studio from obsproject.com or via Homebrew

**Problem:** Virtual Camera starts but EngageNet can't see it
- **Solution:** 
  1. Make sure OBS Virtual Camera is actually running (check for "Virtual Camera Active" indicator)
  2. Verify both OBS Studio and Terminal have camera permissions (see "Camera Permissions" section)
  3. Try stopping and restarting Virtual Camera: Tools → Stop Virtual Camera, then Tools → Start Virtual Camera
  4. Check the camera index (see "Finding Your Camera Index on macOS" section above)

**Problem:** OBS shows "No Sources" or black screen
- **Solution:** 
  1. Make sure you added a Video Capture Device source (see "Setting Up OBS Studio" section)
  2. Check that your camera is selected in the source properties
  3. Verify OBS Studio has camera permissions in System Settings
  4. Try removing and re-adding the Video Capture Device source

**Problem:** OBS prompts for camera permission but doesn't work
- **Solution:** 
  1. Make sure you clicked "Allow" when OBS first requested camera access
  2. Manually enable in System Settings → Privacy & Security → Camera → Enable OBS Studio
  3. Restart OBS Studio after granting permissions

### Camera Issues

**Problem:** "Could not open video source"
- **Solution:** 
  1. Make sure OBS Virtual Camera is running (Tools → Start Virtual Camera)
  2. Verify both OBS Studio and Terminal have camera permissions (see "Camera Permissions" section)
  3. Try using a different camera index: `VIDEO_SOURCE=0 python live_marlin_openface_combination.py`
  4. Check that no other application is using the camera
  5. Restart OBS Studio if the issue persists

**Problem:** Script can't find OBS Virtual Camera
- **Solution:** 
  1. Verify OBS Virtual Camera is started and active
  2. Check that both OBS Studio and Terminal have camera permissions
  3. Find the correct camera index (see "Finding Your Camera Index on macOS" section above)
  4. Try manually specifying different indices: 
     - `VIDEO_SOURCE=0 python live_marlin_openface_combination.py`
     - `VIDEO_SOURCE=1 python live_marlin_openface_combination.py`
     - `VIDEO_SOURCE=2 python live_marlin_openface_combination.py`
  5. Use `ffmpeg -f avfoundation -list_devices true -i ""` to list available cameras
  6. Restart OBS Studio and try again

**Problem:** Permission denied for camera
- **Solution:** 
  1. Grant camera permissions to both OBS Studio and Terminal in System Settings → Privacy & Security → Camera
  2. Make sure both checkboxes are enabled
  3. Restart both OBS Studio and Terminal after granting permissions
  4. See "Camera Permissions" section above for detailed steps

### GUI Issues

**Problem:** No GUI window appears
- **Solution:** The script runs in headless mode if GUI is not available. Check:
  1. You're running on the host (not in Docker)
  2. You have a display available
  3. Try setting `HEADLESS=0` explicitly

**Problem:** "X11 forwarding" errors
- **Solution:** You shouldn't need X11 on macOS. If you see these errors, make sure you're running natively (not in Docker)

### Homebrew Issues

**Problem:** "brew: command not found"
- **Solution:** Install Homebrew from brew.sh (see Prerequisites)

**Problem:** Permission denied for brew install
- **Solution:** Make sure Homebrew has proper permissions:
  ```bash
  sudo chown -R $(whoami) /opt/homebrew
  ```

## Manual Installation (Alternative)

If the automated setup script fails, you can install manually:

1. **Install system dependencies:**
   ```bash
   brew install ffmpeg
   ```

2. **Create virtual environment:**
   ```bash
   python3 -m venv venv
   ```

3. **Activate it:**
   ```bash
   source venv/bin/activate
   ```

4. **Install packages from requirements:**
   ```bash
   pip install -r requirements.txt
   ```

Note: Manual installation may have version conflicts. The Docker-first approach is recommended for consistency.

## Using Different Video Sources

Instead of OBS Virtual Camera, you can use:

- **Built-in camera:** `VIDEO_SOURCE=0 python live_marlin_openface_combination.py`
- **External camera:** Try different indices (0, 1, 2, etc.)
- **RTSP stream:** `VIDEO_SOURCE=rtsp://... python live_marlin_openface_combination.py`
- **HTTP stream:** `VIDEO_SOURCE=http://... python live_marlin_openface_combination.py`

To find available cameras:
```bash
ffmpeg -f avfoundation -list_devices true -i ""
```

## Apple Silicon (M1/M2) Notes

If you're on an Apple Silicon Mac:

- Docker Desktop for Mac supports ARM64
- Python packages should install correctly (most have ARM64 wheels)
- If you encounter issues, the Docker-based setup ensures compatibility

## Next Steps

- See `README.md` for more information about the project
- See `DISTRIBUTION.md` if you need to share this project with others

## Getting Help

If you encounter issues not covered here:
1. Check that all prerequisites are installed
2. Verify model files are in place
3. Check Docker and Python versions
4. Ensure camera permissions are granted
5. Contact the project maintainer with error messages
