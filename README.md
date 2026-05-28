# LabLedger

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter\&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-40C4FF?logo=flutter\&logoColor=white)

---

## 🧪 About LabLedger

**LabLedger** is a robust and modern **lab management system** built using **Flutter** and **Django REST Framework (DRF)**.
It streamlines diagnostic center operations — managing patients, doctors, diagnoses, billing, and reporting — within a unified, intuitive, and secure platform.

---

## 🔑 Key Features

* **Comprehensive Bill & Report Management**
  Easily create, view, and manage test reports and billing data.

* **Advanced PDF Generation Engine**
  Generate customized, professional Doctor Incentive reports with 3 dynamic layout options. Includes visual status indicators (e.g., automated red-coding for negative balances) and native OS file-save prompts.

* **SMS Gateway Integration**
  Integrated local SMS gateway for messaging, including an in-app securely authenticated prompt to download the required Gateway APK directly from your private server.

* **Integrated Doctor & Patient Database**
  Maintain accurate and searchable records of doctors and patients.

* **Dynamic Dashboard with Analytics**
  Visualize key metrics through interactive charts and summaries.

* **Secure Authentication**
  Uses **SimpleJWT** for token-based authentication and API security.

* **Modern UI Design**
  Clean, responsive Material 3 interface featuring a beautiful, fluid glassmorphism design language, adaptive layouts, and a professional color palette.

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
**disconnect from the internet before launching the app each time.**

> The app automatically switches between the **online server** and **local Django server** depending on network availability.

```bash
flutter run
```

---

## 🖥️ 3. Backend Setup

For backend setup instructions and details, please read the README in the dedicated backend repository:
👉 **[LabLedger-Backend README](https://github.com/himanshuchaurasiya24/LabLedger-Backend)**

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
