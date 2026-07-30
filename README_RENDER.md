# H2APK - Render.com Deployment Guide

## URL Format After Deployment
```
https://h2apk.onrender.com
```
(Pwede mong palitan "h2apk" sa Render dashboard)

## Files to Update/Add sa Project Mo

### 1. Palitan ang `main.go`
- Gamitin ang updated `main.go` na kasama sa files na ito
- Key changes:
  - `baseDir` reads from `RENDER_PROJECT_DIR` env var
  - Removed `openBrowser()`, `readEnvPort()`, `saveEnvPort()`
  - Uses `http.ListenAndServe()` instead of `net.Listen()` loop
  - Updated `findLocalOrSystem()` at `findAndroidJar()` para sa Render paths

### 2. Palitan ang `config.json`
- Gamitin ang bagong `config.json` na kasama sa files na ito
- Points to `/opt/render/project/tools/` para sa JAR files

### 3. I-add ang `render-build.sh`
- Ito ang mag-iinstall ng Java, Android SDK, at JAR tools
- Ilagay sa root ng project (kasama ng `main.go`)

### 4. I-add ang `render.yaml`
- Blueprint file para sa Render
- Ilagay sa root ng project

## Deployment Steps

### Step 1: Install Git sa Termux
```bash
pkg install git -y
```

### Step 2: Initialize Git Repo
```bash
cd /storage/emulated/0/Download/Build-Apk
git init
git add .
git commit -m "Ready for Render deployment"
```

### Step 3: Create GitHub Repo
1. Punta sa https://github.com sa browser
2. Sign in / Sign up
3. Click "+" → "New repository"
4. Name: `h2apk`
5. Click "Create repository"

### Step 4: Push to GitHub
```bash
git remote add origin https://github.com/YOUR_USERNAME/h2apk.git
git branch -M main
git push -u origin main
```

### Step 5: Deploy sa Render
1. Punta sa https://render.com
2. Sign up with GitHub
3. Click "New +" → "Blueprint"
4. Connect your GitHub repo
5. Render will auto-read `render.yaml`
6. Click "Apply"
7. Wait for build (10-15 mins first time)

## Free Tier Limitations
- **Sleep after 15min idle** → cold start ~30 seconds
- **512MB RAM** → enough for APK builds
- **1GB Disk** → for output APKs
- **Build time limit** → ~15 mins

## Custom Domain (Optional)
Sa Render dashboard:
1. Go to your service
2. Click "Settings" → "Custom Domains"
3. Add your domain
