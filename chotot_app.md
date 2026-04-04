# 📱 ChoTot App (Flutter + PostgreSQL + Backend)

## 🎯 Mục tiêu

Xây dựng ứng dụng mua bán sản phẩm giống Chợ Tốt (mini) với 2 role:

* **Admin**: đăng bán, quản lý sản phẩm
* **User**: mua hàng, thanh toán

---

## 🧱 Kiến trúc hệ thống

```text
Flutter (Frontend)
        ↓
REST API (Backend - Spring Boot)
        ↓
PostgreSQL (pgAdmin)
```

> ⚠️ Flutter KHÔNG kết nối trực tiếp PostgreSQL, phải thông qua Backend

---

## 👥 Phân quyền

### 🔴 Admin

* Tạo sản phẩm
* Sửa / xoá sản phẩm
* Quản lý danh sách sản phẩm
* Xem thông tin cá nhân (Profile)

### 🔵 User

* Đăng ký / đăng nhập
* Xem sản phẩm
* Tìm kiếm
* Thêm vào giỏ hàng
* Thanh toán
* Xem thông tin cá nhân (Profile)

---

## 🔐 Authentication

### API

```
POST /auth/register
POST /auth/login
GET  /users/profile/{id}
```

### Bảng `users`

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username TEXT UNIQUE,
  password TEXT,
  role TEXT, -- admin / user
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🛒 Sản phẩm (Product)

### API

```
GET    /products
POST   /products
PUT    /products/{id}
DELETE /products/{id}
```

### Bảng `products`

```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  title TEXT,
  price NUMERIC,
  description TEXT,
  image TEXT,
  user_id INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔍 Tìm kiếm

### API

```
GET /products?keyword=iphone
```

### Logic

* Tìm theo `title`
* LIKE / ILIKE PostgreSQL

---

## 🛍️ Giỏ hàng (Cart)

### API

```
POST /cart
GET  /cart/{userId}
DELETE /cart/{id}
```

### Bảng `cart`

```sql
CREATE TABLE cart (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  product_id INTEGER,
  quantity INTEGER DEFAULT 1
);
```

---

## 💳 Thanh toán (Demo)

### API

```
POST /orders
```

### Bảng `orders`

```sql
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  total_price NUMERIC,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔄 Flow hệ thống

```text
Register/Login
      ↓
Home (List sản phẩm)
      ↓
Search sản phẩm
      ↓
Thêm vào giỏ hàng
      ↓
Thanh toán
```

---

## 📱 Frontend (Flutter)

### Màn hình

* Login / Register
* Home (list sản phẩm)
* Product Detail
* Cart
* Checkout
* Profile (Xem thông tin user)

### Gọi API

```dart
GET    /products
POST   /auth/login
POST   /cart
```

---

## ⚙️ Backend (Spring Boot)

### Công nghệ

* Spring Boot
* Spring Data JPA
* PostgreSQL

### Cấu hình DB

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/chotot_db
spring.datasource.username=postgres
spring.datasource.password=123456
```

---

## 🎯 Phạm vi demo

✔ Login / Register
✔ Phân quyền admin / user
✔ CRUD sản phẩm
✔ Tìm kiếm
✔ Giỏ hàng
✔ Thanh toán cơ bản

---

## 📌 Ghi chú

* Dữ liệu lưu trên PostgreSQL (pgAdmin)
* Hỗ trợ nhiều user
* Backend là bắt buộc

---

## 🚀 Mở rộng (optional)

* Upload ảnh thật (Cloudinary)
* Chat buyer/seller
* Notification
* Rating sản phẩm

---
