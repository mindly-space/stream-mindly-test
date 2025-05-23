# Mindly Stream Video Call - iPhone Setup Guide

This project is built with **Ionic v6** + **Capacitor v6** + **Vite** and uses React. Follow these step-by-step
instructions to run the app on iPhone device or simulator.

## Prerequisites

### macOS Requirements

- **macOS** (iOS development requires macOS)
- **Xcode 15.0+** (required for Capacitor v6)
- **Xcode Command Line Tools**
- **Node.js** (v16+ recommended)
- **CocoaPods**

### Install Required Tools

1. **Install Xcode** from the App Store
2. **Install Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```
3. **Install CocoaPods (version 1.15.2 required):**

   ```bash
   # Using Homebrew (recommended)
   brew install cocoapods

   # Verify version (should be 1.15.2+)
   pod --version

   # If you need to update to 1.15.2
   brew upgrade cocoapods

   # Or using gem for specific version
   sudo gem install cocoapods -v 1.15.2
   ```

## Project Setup

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone <repository-url>
cd stream-call-mindly-test

# Install dependencies
npm install
```

### 2. Build the Web App

```bash
# Build the React app with Vite
npm run build
```

### 3. Sync with Capacitor

```bash
# Copy web assets to iOS platform
npx cap copy ios

# Update iOS dependencies
npx cap sync ios
```

## Running on iPhone

### Option A: Using Xcode (Recommended)

1. **Open the iOS project in Xcode:**

   ```bash
   npx cap open ios
   ```

2. **Configure signing in Xcode:**

   - Select the project root in Project Navigator
   - Under "Signing & Capabilities", enable "Automatically manage signing"
   - Select your Development Team (Apple ID)
   - Verify Bundle Identifier matches: `com.mindly.stream.video.call`

3. **Select target device:**

   - Choose your iPhone from the device list, or
   - Select an iOS Simulator (iPhone 14/15 recommended)

4. **Run the app:**
   - Click the ▶️ (Play) button in Xcode

### Option B: Using Capacitor CLI

1. **Run on device/simulator:**

   ```bash
   npx cap run ios
   ```

   - Select target when prompted

2. **Run with live reload (development):**

   ```bash
   # Start dev server
   npm start

   # In another terminal, run with live reload
   npx cap run ios --livereload --external
   ```

## Development Workflow

### Making Changes

1. **Edit source code** in `src/` directory
2. **Rebuild the app:**
   ```bash
   npm run build
   npx cap copy ios
   ```
3. **Refresh in Xcode** or restart the app

### Live Reload Development

For faster development with live reload:

```bash
# Terminal 1: Start Vite dev server
npm start

# Terminal 2: Run with live reload
npx cap run ios --livereload --external
```

## Troubleshooting

### Common Issues

1. **Build fails**: Ensure all dependencies are installed and Xcode is up to date
2. **Signing issues**: Check your Apple Developer account and team selection
3. **Pod install fails**: Try `cd ios && pod install --repo-update`
4. **Simulator not showing**: Restart Xcode and check iOS Simulator availability

### Useful Commands

```bash
# Update Capacitor
npm install @capacitor/cli@latest @capacitor/core@latest @capacitor/ios@latest

# Clean and rebuild
npx cap sync ios --force-copy

# Check Capacitor setup
npx cap doctor
```

## Documentation Links

- [Capacitor iOS Documentation](https://capacitorjs.com/docs/v6/ios)
- [Ionic iOS Development Guide](https://ionic-docs-5utg8ms4c-ionic1.vercel.app/docs/v6/developing/ios)
- [Capacitor Environment Setup](https://capacitorjs.com/docs/v6/getting-started/environment-setup)
- [Vite Documentation](https://vitejs.dev/guide/)

## Project Configuration

- **App ID**: `com.mindly.stream.video.call`
- **App Name**: Mindly Stream Video Call
- **Web Directory**: `build/`
- **Build Tool**: Vite
- **Framework**: Ionic React

---

**Note**: Make sure you have a valid Apple Developer account for device testing. For simulator testing, a free Apple ID
is sufficient.
