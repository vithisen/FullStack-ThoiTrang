# Dự Án FullStack Shop Thời Trang (Fashion Shop)

Chào mừng bạn đến với dự án FullStack Shop Thời Trang. Dự án này được tổ chức thành hai phần chính: **Mobile Frontend** (Flutter/Dart) và **Backend** (Java Spring Boot) kết nối tới cơ sở dữ liệu **PostgreSQL**.

## Cấu trúc Thư mục Tổng quan

```text
FullStack-ShopThoiTrang/
├── backend/                              # Dự án Java Spring Boot
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/fashion/shop/    # Gói mã nguồn chính
│   │   │   │   ├── config/               # Cấu hình Spring Security, CORS, Swagger, Database...
│   │   │   │   ├── controller/           # REST Controllers (API endpoints)
│   │   │   │   ├── entity/               # JPA Entities (PostgreSQL mapping)
│   │   │   │   ├── exception/            # Xử lý lỗi toàn cục (Global Exception Handler)
│   │   │   │   ├── repository/           # JPA Repositories (Truy vấn database)
│   │   │   │   ├── service/              # Nghiệp vụ chính (Business Logic)
│   │   │   │   └── security/             # Cấu hình bảo mật, phân quyền & JWT
│   │   │   └── resources/
│   │   │       └── application.yml       # Cấu hình database, cổng chạy server (mặc định 8080)
│   │   └── test/                         # Unit & Integration Tests
│   └── pom.xml                           # File cấu hình thư viện Maven
├── mobile/                               # Dự án Flutter App
│   ├── android/                          # Native Android
│   ├── ios/                              # Native iOS
│   ├── lib/                              # Mã nguồn Dart chính
│   │   ├── config/                       # Định nghĩa endpoints API, theme, routes...
│   │   ├── constants/                    # Hằng số (colors, assets, strings)
│   │   ├── models/                       # Object Model (User, Product, Order...)
│   │   ├── views/                        # Các màn hình (Auth, Home, ProductDetail, Cart...)
│   │   ├── widgets/                      # Widget tái sử dụng toàn cục
│   │   ├── services/                     # Gọi API & Lưu trữ local
│   │   ├── providers/                    # Quản lý trạng thái (State Management)
│   │   └── utils/                        # Các hàm format, helper
│   └── pubspec.yaml                      # Khai báo dependencies của Flutter
└── README.md                             # Tài liệu dự án (File này)
```

---

## Hướng dẫn Khởi chạy

### 1. Cấu hình & Chạy Backend (Spring Boot)

#### Chuẩn bị Database (Sử dụng Docker - Khuyên dùng cho sinh viên):
1. Đảm bảo máy đã cài đặt **Docker Desktop**.
2. Tại thư mục gốc của dự án, mở Terminal và chạy lệnh:
   ```bash
   docker compose up -d
   ```
   Lệnh này sẽ tự động tải và chạy cơ sở dữ liệu PostgreSQL với tên DB là `fashion_shop_db`, tài khoản `postgres`, mật khẩu `postgres_password` ở cổng `5432`.
   *(Nếu không dùng Docker, bạn phải tự cài PostgreSQL cục bộ và tạo database tên `fashion_shop_db`).*

#### Các bước chạy Backend:
1. Mở thư mục `backend/` bằng IDE của bạn (IntelliJ IDEA được khuyên dùng, hoặc Visual Studio Code / Android Studio có cài extension Java).
2. Kiểm tra file cấu hình database trong [backend/src/main/resources/application.yml](backend/src/main/resources/application.yml) (mặc định đã cấu hình khớp với Docker ở trên).
3. Chạy ứng dụng từ lớp main `com.fashion.shop.ShopApplication`. Mặc định server sẽ chạy ở cổng `8080`.

---

### 2. Cấu hình & Chạy Frontend (Flutter Mobile App)

#### Chuẩn bị:
- Cài đặt **Flutter SDK** và cấu hình biến môi trường đầy đủ.
- Mở **Android Studio** hoặc **VS Code**.

#### Các bước chạy:
1. Mở thư mục `mobile/` bằng Android Studio hoặc VS Code.
2. Mở Terminal tại thư mục `mobile/` và chạy lệnh sau để tải các package:
   ```bash
   flutter pub get
   ```
3. Mở máy ảo Android/iOS hoặc cắm thiết bị thật của bạn.
4. Chạy ứng dụng bằng lệnh:
   ```bash
   flutter run
   ```
   Hoặc nhấn nút **Run/Debug** trên Android Studio.

---
