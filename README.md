# Aria 🌏

**Aria** is a comprehensive tourism application designed to showcase the beauty of Iran, organize local events, and provide an interactive user experience. The project consists of a **Django backend** and a **Flutter mobile application**, following the **Clean Architecture** principles to ensure a modular and maintainable structure.  

Users can explore, search, bookmark, and interact with attractions and events across different provinces of Iran.  

---

## ⚙️ Features

### 🏠 Home
- Dynamic slider showcasing top attractions per province.  
- Sections for services, categories, and personalized recommendations.  
- Interactive touch animations and smooth UI effects.  

### 🗺️ Attractions
- Browse attractions by province.  
- Detailed pages with tabbed views for information, reviews, and galleries.  
- Add or remove bookmarks in real-time.  
- Post and view user reviews.  
- Advanced search with filters and result cards.  

### 🎉 Events
- Full listings and detailed pages of local events.  
- Integrated review and rating system.  
- Full API integration with proper error handling and multiple UI states.  

### 💬 Reviews & Feedback
- Submit reviews in real-time with auto-refresh.  
- View ratings and feedback from other users.  

### 🔖 Bookmarks
- Save favorite attractions and events.  
- Instant UI updates upon bookmark changes.  
- Modern design consistent with the app theme.  

### 🌆 Provinces
- View province information and photo galleries.  
- Explore attractions and events associated with each province.  
- Switch between user-selected provinces easily.  

### 🖼️ Gallery
- Fullscreen image gallery for a rich visual experience.  
- Sliders and shimmer loaders for smoother loading.  

### 🔐 Authentication
- OTP-based login via SMS.  
- JWT authentication for session management.  
- Province selection upon login.  

### 🎵 Background Music
- Play soft background music within the app.  
- Synchronize music playback across pages.  

### 🎨 User Interface
- Custom fonts and color schemes with live theme switching.  
- Bottom navigation for easy access.  
- Smooth animations and minimalistic design.  

---

## 🧱 Backend Architecture
- **Django** + **Django REST Framework**.  
- **DRF Spectacular** for Swagger / ReDoc API documentation.  
- JWT authentication.  
- OTP-based login system.  
- Media & static file management.  
- ORM models for provinces, attractions, events, and users.  

---

## 🔧 Tech Stack
- **Frontend:** Flutter  
- **Backend:** Django, Django REST Framework  
- **Authentication:** JWT, OTP  
- **Architecture:** Clean Architecture  
- **Documentation:** DRF Spectacular (Swagger / ReDoc)  

---

## 🚀 Installation & Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/aria.git
   ```
2. Setup backend:
   ```bash
   cd backend
   pip install -r requirements.txt
   python manage.py migrate
   python manage.py runserver
   ```
3. Setup Flutter app:
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

---

## 📜 License
Aria is [MIT Licensed](LICENSE).  

---

## 🌟 Contact
For feedback or collaboration, reach out at **me@mr-keshi.ir**
