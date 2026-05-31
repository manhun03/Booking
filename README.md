# Hotel Booking API - Java Spring Boot

Backend Java/Spring Boot cho he thong dat phong khach san. API chay voi SQL Server, JWT, Swagger, MinIO, Firebase, SMTP email va VNPay.

## Yeu Cau

- Java 17
- Maven
- SQL Server chay o `localhost:1433`
- Docker Desktop neu muon chay MinIO bang Docker
- Firebase service account JSON trong thu muc `firebase`

## Cau Hinh Database

Database mac dinh:

```text
Database: DoAnHotelParkingDb
Username: sa
Password: 123456
JDBC: jdbc:sqlserver://localhost:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
```

Tao database tren SQL Server truoc khi chay:

```sql
CREATE DATABASE DoAnHotelParkingDb;
```

Backend dung Flyway/JPA de chay migration va bo sung bang chuc nang.

## Cau Hinh Firebase

Dat file Firebase Admin SDK tai:

```text
java-hotel-booking-api/firebase/hotelapp-63196-firebase-adminsdk-fbsvc-a126f141e7.json
```

Cau hinh trong `src/main/resources/application.yml`:

```yaml
app:
  firebase:
    credentials-path: firebase/hotelapp-63196-firebase-adminsdk-fbsvc-a126f141e7.json
    project-id: hotelapp-63196
```

## Chay MinIO

Neu dung Docker:

```powershell
docker run -d --name hotelparking-minio `
  -p 9000:9000 -p 9001:9001 `
  -e MINIO_ROOT_USER=minioadmin `
  -e MINIO_ROOT_PASSWORD=minioadmin `
  quay.io/minio/minio server /data --console-address ":9001"
```

MinIO:

```text
API: http://localhost:9000
Console: http://localhost:9001
Bucket: hotel-images
Username: minioadmin
Password: minioadmin
```

Backend tu tao bucket neu chua co.

## Cau Hinh SMTP

SMTP la tuy chon neu khong dung chuc nang email. Khi dung forgot password/verify email, backend can cau hinh SMTP de gui email that; neu thieu cau hinh, API se tra loi loi cau hinh email.

Thiet lap bien moi truong khi can gui email that:

```powershell
$env:MAIL_HOST="smtp.gmail.com"
$env:MAIL_PORT="587"
$env:MAIL_USERNAME="your-email@gmail.com"
$env:MAIL_PASSWORD="your-app-password"
$env:MAIL_HEALTH_ENABLED="true"
```

Voi Gmail can dung App Password, khong dung mat khau tai khoan thuong.

## Cau Hinh Google Login

Client ID mac dinh da cau hinh trong `application.yml`:

```text
883824205385-182f65ondho5qnima9ladd5j7qk2b40h.apps.googleusercontent.com
```

Trong Google Cloud Console, them:

```text
Authorized JavaScript origins: http://localhost:8081
```

## Cau Hinh VNPay

Payment dung VNPay that khi provider la `VNPAY`. Can khai bao credential that:

```powershell
$env:VNPAY_PAY_URL="https://sandbox.vnpayment.vn/paymentv2/vpcpay.html"
$env:VNPAY_RETURN_URL="http://localhost:8080/api/payments/vnpay-return"
$env:VNPAY_TMN_CODE="your-vnpay-tmn-code"
$env:VNPAY_HASH_SECRET="your-vnpay-hash-secret"
```

Neu thieu `VNPAY_TMN_CODE` hoac `VNPAY_HASH_SECRET`, API `/api/payments/initiate` se tra loi cau hinh thay vi tao payment gia.

## Build Backend

Trong thu muc `java-hotel-booking-api`:

```powershell
mvn clean package -DskipTests
```

File jar sau build:

```text
target/hotel-booking-api-0.1.0.jar
```

## Chay Backend

Cach 1, chay bang Maven:

```powershell
mvn spring-boot:run
```

Cach 2, chay bang jar:

```powershell
java -jar target/hotel-booking-api-0.1.0.jar
```

Backend chay tai:

```text
http://localhost:8080
```

Swagger UI:

```text
http://localhost:8080/swagger-ui/index.html
```

Health check:

```text
http://localhost:8080/actuator/health
```

## Tai Khoan Demo

```text
Admin:    admin@hotel.local / Password@123
Owner:    owner@hotel.local / Password@123
Customer: customer.demo@hotel.local / Password@123
```

## Test Nhanh API

Login:

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/auth/login" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"email":"admin@hotel.local","password":"Password@123"}'
```

Swagger/OpenAPI:

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/v3/api-docs"
```

Health:

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/actuator/health"
```

## Cac Module Chinh

- Auth: register, login, refresh token, forgot password, reset password, verify email, change password, Google login.
- Hotel/Room: hotel, room, room type, hotel image, owner room management.
- Booking: create booking, owner confirm/reject, change booking, cancel, check-in, check-out, force complete.
- Payment: initiate VNPay, callback/return, webhook, refund, pending/failed/refunded status.
- Review: create review by booking, block invalid review, owner reply, report, moderation.
- Notification: auto notification by booking/payment/review, mark read/read-all.
- Admin: dashboard, approve/lock hotel, lock user, audit log, system config.
- Promotion/Coupon: CRUD coupon va validate coupon.
- Chat: customer-owner message, conversation, unread, mark read.
- Statistics: owner dashboard, revenue, top rooms, peak hours.

## Ghi Chu Khi Chay

- Neu `mvn package` bao khong rename duoc jar, backend dang chay va giu file jar. Dung process Java o port `8080` roi build lai.
- Neu health bao MinIO DOWN, kiem tra Docker container MinIO va port `9000`.
- Neu health bao Mail DOWN, cau hinh SMTP hoac de `MAIL_HEALTH_ENABLED=false`.
- Neu VNPay initiate bao thieu cau hinh, khai bao du `VNPAY_TMN_CODE` va `VNPAY_HASH_SECRET`.
