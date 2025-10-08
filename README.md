# LabLedger

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter\&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-40C4FF?logo=flutter\&logoColor=white)
![App Screenshot](https://github.com/himanshuchaurasiya24/LabLedger/raw/main/assets/images/app_image.png)

---

## 🧪 About LabLedger

**LabLedger** is a robust and modern **lab management system** built using **Flutter** and **Django REST Framework (DRF)**.
It streamlines diagnostic center operations — managing patients, doctors, diagnoses, billing, and reporting — within a unified, intuitive, and secure platform.

---

## 🔑 Key Features

* **Comprehensive Bill & Report Management**
  Easily create, view, and manage test reports and billing data.

* **Integrated Doctor & Patient Database**
  Maintain accurate and searchable records of doctors and patients.

* **Dynamic Dashboard with Analytics**
  Visualize key metrics through interactive charts and summaries.

* **Secure Authentication**
  Uses **SimpleJWT** for token-based authentication and API security.

* **Modern UI Design**
  Clean, responsive Material 3 interface with a professional color palette.

---

## 🧰 Technology Stack

### Frontend

* **Flutter** — Cross-platform app development
* **Riverpod** — Scalable state management
* **FL Chart** — Interactive charts and data visualization
* **Material Design 3** — Clean and consistent UI

### Backend

* **Django REST Framework (DRF)** — API layer
* **SimpleJWT** — Token-based authentication
* **SQLite** — Lightweight and fast local database

---

## ⚙️ Runtime Issue Fix (Windows Users)

If the compiled app shows **runtime errors** (missing DLLs or crashes), follow these steps:

1. **Download the Visual C++ Runtimes package:**
   👉 [Click here to download Visual-C-Runtimes-All-in-One-Jul-2025.zip](https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/)

2. **Extract** the ZIP file anywhere.

3. **Run:** `vcredist2015_2017_2019_2022_x64.exe`

4. Complete installation and restart (recommended).

> 💡 This fix is needed only once per system.

---

## 🚀 Getting Started

### 🧩 1. Clone the Frontend Repository

```bash
git clone https://github.com/himanshuchaurasiya24/LabLedger.git
cd LabLedger
flutter pub get
```

### 🧠 2. Running the Flutter App

If you plan to run LabLedger with the **local backend**,
**disconnect from the internet before launching the app.**

> The app automatically switches between the **online server** and **local Django server** depending on network availability.

```bash
flutter run
```

---

## 🖥️ 3. Backend Setup (Django REST Framework)

Clone the backend repository:

```bash
git clone https://github.com/himanshuchaurasiya24/LabLedger-Backend.git
cd LabLedger-Backend
```

---

### 🪟 Windows Setup Script

Save the following as **`setup_backend.bat`** in the backend directory, then double-click it or run it from CMD:

```bat
@echo off
echo ==============================================
echo   🚀 LabLedger Backend Setup (Windows)
echo ==============================================
echo.

REM Check Python installation
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found on your system.
    set /p install="Would you like to install Python automatically? (y/n): "
    if /I "%install%"=="y" (
        echo 🌐 Opening Python download page...
        start https://www.python.org/downloads/
        echo Please install Python manually, then re-run this script.
        pause
        exit /b
    ) else (
        echo ⚠️ Python installation skipped. Exiting setup.
        pause
        exit /b
    )
) else (
    echo ✅ Python is installed.
)

REM Create virtual environment
if not exist venv (
    echo 📦 Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo ⚙️ Activating virtual environment...
call venv\Scripts\activate

REM Install dependencies
echo 📚 Installing dependencies from requirements.txt...
pip install --upgrade pip
pip install -r requirements.txt

REM Run the Django development server
echo 🚀 Starting Django development server...
python manage.py runserver

pause
```

---

### 🐧 Linux Setup Script

Save the following as **`setup_backend.sh`**, then run:

```bash
bash setup_backend.sh
```

**Script:**

```bash
#!/bin/bash
echo "=============================================="
echo " 🚀 LabLedger Backend Setup (Linux)"
echo "=============================================="
echo

# Check Python installation
if ! command -v python3 &> /dev/null
then
    echo "❌ Python is not installed."
    read -p "Would you like to install Python now? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        echo "🌐 Installing Python..."
        sudo apt update && sudo apt install -y python3 python3-venv python3-pip
    else
        echo "⚠️ Skipping Python installation. Exiting setup."
        exit 1
    fi
else
    echo "✅ Python is installed."
fi

# Create venv
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate venv
echo "⚙️ Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📚 Installing dependencies from requirements.txt..."
pip install --upgrade pip
pip install -r requirements.txt

# Runserver
echo "🚀 Starting Django development server..."
python manage.py runserver
```

Your backend will now be available at:
👉 **[http://127.0.0.1:8000/](http://127.0.0.1:8000/)**

---

## 👨‍💻 About the Developer

### **Himanshu Chaurasiya**

[![GitHub](https://img.shields.io/badge/GitHub-himanshuchaurasiya24-181717?style=for-the-badge\&logo=github)](https://github.com/himanshuchaurasiya24)

🔹 **Full-Stack Developer** | **Flutter & Django REST Framework (DRF)**
🔹 Passionate about clean architecture and intuitive UI
🔹 Focused on scalable, real-world applications
🔹 Open-source contributor and continuous learner

> “I believe in writing elegant code that solves complex problems simply.”

📫 **Let’s Connect:**

* **GitHub:** [himanshuchaurasiya24](https://github.com/himanshuchaurasiya24)
* **Email:** [himanshuchaurasiya24@gmail.com](mailto:himanshuchaurasiya24@gmail.com)

---
