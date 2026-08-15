Cartify 🛍️
> A full-stack e-commerce mobile application built with Flutter, featuring real payment processing, phone OTP authentication, and a complete shopping experience from browsing to order confirmation.

<p align="center">
  <img src="assets/logo.svg" width="80" height="80" alt="Cartify Logo"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white"/>
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white"/>
  <img src="https://img.shields.io/badge/Razorpay-02042B?style=for-the-badge&logo=razorpay&logoColor=white"/>
</p>

---

## 📱 Screenshots
 
| Splash | Login | OTP Verification |
|--------|-------|-------------------|
| <img width="1080" height="2340" alt="splash" src="https://github.com/user-attachments/assets/3d500bde-c5d6-4df7-ad0c-f46bcb65645e" /> | <img width="1080" height="2340" alt="login" src="https://github.com/user-attachments/assets/d12da8c5-557d-4f3f-964e-182fe718e7d0" /> | <img width="1080" height="2340" alt="otp" src="https://github.com/user-attachments/assets/3dd1a405-15d8-4589-bca6-2d1dc69554d0" /> |
 
| Home | Search | Wishlist |
|------|--------|----------|
| <img width="1080" height="2340" alt="home" src="https://github.com/user-attachments/assets/f74d6374-a232-4825-b630-c782c4226315" /> | <img width="1080" height="2340" alt="search" src="https://github.com/user-attachments/assets/148b6339-215a-4e0e-aea8-4e1fb8089d31" /> | <img width="1080" height="2340" alt="wishlist" src="https://github.com/user-attachments/assets/2e7ffcfd-53ca-483d-aaad-71bc7ea61497" /> |
 
| Cart | Checkout | Payment Options |
|------|----------|------------------|
| <img width="1080" height="2340" alt="cart" src="https://github.com/user-attachments/assets/2304e910-7b4b-4361-8254-d0f72c776b70" /> | <img width="1080" height="2340" alt="checkout" src="https://github.com/user-attachments/assets/596d1f12-334c-43e3-a3f3-0b5754a35e0b" /> | <img width="1080" height="2340" alt="payment" src="https://github.com/user-attachments/assets/50e41458-5b95-4884-8b60-e64788f633f6" /> |
 
| Order Success | Profile | All Products |
|----------------|---------|---------------|
| <img width="1080" height="2340" alt="success" src="https://github.com/user-attachments/assets/151e6977-ea3a-4df8-a1f4-e45e64dc9f7d" /> | <img width="1080" height="2340" alt="profile" src="https://github.com/user-attachments/assets/ee9cc0ce-0d4d-4f42-a238-1603eea15c27" /> | <img width="1080" height="2340" alt="products" src="https://github.com/user-attachments/assets/388768b7-0007-46c9-8218-ada4eecc2f0c" /> |
 
---

## 🎥 Demo Video

[![Cartify Demo](https://img.shields.io/badge/Watch%20Demo-YouTube-red?style=for-the-badge&logo=youtube)](https://youtube.com/your-demo-link)

> Full app walkthrough — splash animation, OTP login, product browsing, add to cart, Razorpay payment, and order history.

---

## ✨ Features

- 🔐 **Phone OTP Authentication** — Real SMS via Twilio + Supabase Auth
- 🎬 **Animated Splash Screen** — Elastic logo scale + text slide animations
- 🏠 **Home Screen** — Auto-scrolling banner carousel + category filters
- 🔍 **Live Search** — Real-time product filtering by name and category
- 🛍️ **Product Listing** — 25+ products across 5 categories with wishlist hearts
- ❤️ **Wishlist** — Save and manage favourite products with badge counter
- 🛒 **Cart** — Add, remove, increment/decrement quantity with live total
- 💳 **Razorpay Payment Gateway** — UPI, Cards, Netbanking support
- 🔒 **Payment Verification** — HMAC-SHA256 signature verification on backend
- 📦 **Order History** — All past orders with status badges and payment IDs
- 👤 **Profile Screen** — User info, order history, logout with confirmation

---

## 🏗️ Architecture

Flutter App (Frontend)
↕ HTTP requests
Node.js + Express (Backend — Render)
↕ Razorpay API calls
Razorpay Payment Gateway
↕ stores data
Supabase PostgreSQL (Database)
↕ Phone OTP
Twilio SMS

---

## 🗂️ Folder Structure

lib/
├── core/
│   ├── constants/
│   │   └── app_banners.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── banner_carousel.dart
│       └── product_card.dart
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       ├── login_screen.dart
│   │       ├── otp_screen.dart
│   │       ├── otp_verified_screen.dart
│   │       └── profile_screen.dart
│   ├── products/
│   │   ├── models/
│   │   │   └── product_model.dart
│   │   ├── providers/
│   │   │   └── product_provider.dart
│   │   └── screens/
│   │       ├── product_list_screen.dart
│   │       ├── product_detail_screen.dart
│   │       └── search_screen.dart
│   ├── cart/
│   │   ├── models/
│   │   │   └── cart_item_model.dart
│   │   ├── providers/
│   │   │   └── cart_provider.dart
│   │   └── screens/
│   │       └── cart_screen.dart
│   ├── wishlist/
│   │   ├── providers/
│   │   │   └── wishlist_provider.dart
│   │   └── screens/
│   │       └── wishlist_screen.dart
│   ├── orders/
│   │   ├── models/
│   │   │   └── order_model.dart
│   │   ├── providers/
│   │   │   └── order_provider.dart
│   │   └── screens/
│   │       └── order_history_screen.dart
│   └── payment/
│       ├── providers/
│       │   └── payment_provider.dart
│       └── screens/
│           ├── checkout_screen.dart
│           └── order_success_screen.dart
└── main.dart

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|-----------|---------|
| Flutter / Dart | Cross-platform mobile UI |
| Provider (ChangeNotifier) | State management |
| Supabase Flutter SDK | Database + Auth |
| Razorpay Flutter SDK | Payment gateway |
| Cached Network Image | Optimized image loading |
| Flutter SVG | SVG logo rendering |

### Backend
| Technology | Purpose |
|-----------|---------|
| Node.js + Express | REST API server |
| Razorpay Node SDK | Payment order creation |
| crypto (Node.js) | HMAC-SHA256 signature verification |
| dotenv | Environment variable management |
| Render | Cloud deployment |

### Database & Auth
| Technology | Purpose |
|-----------|---------|
| Supabase PostgreSQL | Relational database |
| Row Level Security | Data isolation policies |
| Supabase Auth | Phone OTP authentication |
| Twilio | SMS delivery |

---

## 🗄️ Database Schema

```sql
-- Products
products (id, name, description, price, image_url, category, stock, created_at)

-- Orders
orders (id, user_id, total_amount, status, razorpay_order_id, razorpay_payment_id, created_at)

-- Order Items
order_items (id, order_id, product_id, quantity, price)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Node.js 18+
- Supabase account
- Razorpay test account
- Twilio account (for OTP)

### Frontend Setup
```bash
# Clone the repo
git clone https://github.com/ArushGarg/cartify.git
cd cartify

# Install dependencies
flutter pub get

# Add your credentials in lib/main.dart
# Supabase URL and anon key

# Add Razorpay test key in lib/features/payment/providers/payment_provider.dart

# Run the app
flutter run
```

### Backend Setup
```bash
# Clone backend repo
git clone https://github.com/ArushGarg/cartify-backend.git
cd cartify-backend

# Install dependencies
npm install

# Create .env file
RAZORPAY_KEY_ID=rzp_test_xxxx
RAZORPAY_KEY_SECRET=xxxx

# Run server
node server.js
```

### Backend API Endpoints
| Method | Endpoint | Description |
|--------|---------|-------------|
| POST | `/api/payment/create-order` | Create Razorpay order |
| POST | `/api/payment/verify-payment` | Verify payment signature |

---

## 🔒 Security

- Razorpay secret key stored only on backend — never exposed in Flutter
- Payment signature verified via HMAC-SHA256 before saving order to database
- Supabase RLS policies enforce scoped data access
- Environment variables used for all sensitive credentials

---

## 🔮 Upcoming Features

- [ ] Google Sign-In
- [ ] Address management
- [ ] Push notifications
- [ ] Product reviews and ratings
- [ ] Play Store release

---

## 👨‍💻 Author

**Arush Garg**
> Final year B.Tech Computer Science student at AKGEC, Ghaziabad. Flutter developer with internship experience at Dolat Digital and RadhaVallabh Healthcare.

<p align="left">
  <a href="https://linkedin.com/in/arushgarg">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"/>
  </a>
  <a href="https://github.com/ArushGarg">
    <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white"/>
  </a>
  <a href="mailto:arushgarg662@gmail.com">
    <img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white"/>
  </a>
  <a href="https://thriving-palmier-a22a8c.netlify.app">
    <img src="https://img.shields.io/badge/Portfolio-FF5722?style=for-the-badge&logo=google-chrome&logoColor=white"/>
  </a>
</p>

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<p align="center">Made with ❤️ by Arush Garg</p>
