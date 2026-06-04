# HUONG DAN CAI DAT, DONG GOI VA CHAY DU AN STAYSMART

```text
F:\Aptech\Project4\HotelBooking
```

Cau truc chinh:

```text
backend             Backend Spring Boot, chay local bang mvnd
frontend            Web khach hang Flutter
frontend_employee   Web Admin/Owner/Employee Flutter
AIAgent             Chat AI FastAPI
docker-compose.yml  Dong goi va chay toan bo he thong bang Docker
```

Cac URL mac dinh sau khi deploy Docker:

```text
Backend API:        http://localhost:8080/api
Swagger Backend:    http://localhost:8080/swagger-ui/index.html
Customer Web:       http://localhost:8081
Admin/Owner Web:    http://localhost:8082
AI Agent API:       http://localhost:8000
AI Agent Swagger:   http://localhost:8000/docs
MinIO API:          http://localhost:9100
MinIO Console:      http://localhost:9101
```

## 1. Phan Mem Can Cai

Can cai cac phan mem sau:

```text
Docker Desktop
Git
Java 17
Maven Daemon mvnd
Flutter SDK
Chrome
SQL Server / SQL Server Express
SQL Server Management Studio
Python 3.12
```

Neu chi chay ban da deploy bang Docker, bat buoc can:

```text
Docker Desktop
SQL Server neu dung database tren may host
Git neu clone source tu GitHub
```

Kiem tra nhanh trong PowerShell:

```powershell
docker --version
docker compose version
git --version
java -version
mvnd -v
flutter --version
python --version
```

## 2. Mo Thu Muc Du An

Tat ca lenh Docker chay tu thu muc goc:

```powershell
cd "F:\Aptech\Project4\HotelBooking"
```

## 3. Cau Hinh Database SQL Server

Mac dinh backend trong Docker ket noi toi SQL Server dang chay tren may host Windows:

```text
Server:   host.docker.internal
Port:     1433
Database: DoAnHotelParkingDb
Username: sa
Password: 123456
```

Chuoi ket noi dung trong Docker:

```text
jdbc:sqlserver://host.docker.internal:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
```

Khi chay backend local bang mvnd, chuoi ket noi local la:

```text
jdbc:sqlserver://localhost:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
```

Tao database neu chua co:

```sql
IF DB_ID('DoAnHotelParkingDb') IS NULL
BEGIN
    CREATE DATABASE DoAnHotelParkingDb;
END
```

Yeu cau SQL Server:

```text
TCP/IP enabled
Port 1433 dang mo
SQL Server Authentication enabled
User sa dang bat
Password sa la 123456 hoac sua lai trong .env
```

## 4. Cau Hinh File .env Cho Docker

Trong thu muc goc da co file mau:

```text
.env.docker.example
```

Tao file `.env`:

```powershell
Copy-Item .env.docker.example .env
```

Noi dung quan trong can kiem tra trong `.env`:

```env
PUBLIC_API_BASE_URL=http://localhost:8080/api
GOOGLE_CLIENT_ID=883824205385-182f65ondho5qnima9ladd5j7qk2b40h.apps.googleusercontent.com

BACKEND_PORT=8080
CUSTOMER_WEB_PORT=8081
ADMIN_WEB_PORT=8082
AI_AGENT_PORT=8000
MINIO_API_PORT=9100
MINIO_CONSOLE_PORT=9101

SPRING_DATASOURCE_URL=jdbc:sqlserver://host.docker.internal:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
SPRING_DATASOURCE_USERNAME=sa
SPRING_DATASOURCE_PASSWORD=123456

AI_AGENT_BASE_URL=http://ai-agent:8000
AUTH_API_BASE_URL=http://backend:8080/api/auth
TRAVEL_API_BASE_URL=http://backend:8080/api
CHAT_DB_PATH=/app/data/memory.db

APP_MINIO_ENDPOINT=http://minio:9000
APP_MINIO_PUBLIC_BASE_URL=http://localhost:9100
APP_MINIO_ACCESS_KEY=minioadmin
APP_MINIO_SECRET_KEY=minioadmin
APP_MINIO_BUCKET_NAME=hotel-images

APP_JWT_SECRET_KEY=change-this-secret-before-production
GROQ_API_KEY=your-groq-api-key
VNPAY_TMN_CODE=
VNPAY_HASH_SECRET=
VNPAY_RETURN_URL=http://localhost:8080/api/payments/vnpay-return
MAIL_HOST=
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
```

Neu deploy len server that, sua cac URL public:

```env
PUBLIC_API_BASE_URL=https://your-domain.com/api
APP_MINIO_PUBLIC_BASE_URL=https://your-domain.com/minio
VNPAY_RETURN_URL=https://your-domain.com/api/payments/vnpay-return
```

Sau khi doi `PUBLIC_API_BASE_URL`, phai build lai image frontend vi URL nay duoc compile vao Flutter web.

## 5. Cau Hinh AIAgent

Docker Compose doc file:

```text
AIAgent\.env
```

Neu chua co, tao file:

```powershell
Copy-Item .env.docker.example AIAgent\.env
```

Toi thieu can co:

```env
GROQ_API_KEY=your-groq-api-key
AUTH_API_BASE_URL=http://backend:8080/api/auth
TRAVEL_API_BASE_URL=http://backend:8080/api
CHAT_DB_PATH=/app/data/memory.db
```

Neu thieu `GROQ_API_KEY`, Chat AI co the loi hoac khong tra loi.

## 6. Dong Goi Docker Images

Mo Docker Desktop va doi Docker chay xong.

Build toan bo image:

```powershell
docker compose build
```

Build rieng tung phan khi chi sua mot service:

```powershell
docker compose build backend
docker compose build ai-agent
docker compose build customer-web
docker compose build admin-web
```

Cac image duoc tao:

```text
staysmart/backend:latest
staysmart/ai-agent:latest
staysmart/customer-web:latest
staysmart/admin-web:latest
```

## 7. Chay Du An Bang Docker

Chay toan bo he thong voi SQL Server tren may host:

```powershell
docker compose up -d
```

Cac service se chay:

```text
backend
ai-agent
customer-web
admin-web
minio
```

Kiem tra container:

```powershell
docker compose ps
```

Xem log:

```powershell
docker compose logs -f backend
docker compose logs -f ai-agent
docker compose logs -f customer-web
docker compose logs -f admin-web
docker compose logs -f minio
```

Restart mot service:

```powershell
docker compose restart backend
docker compose restart customer-web
```

Dung toan bo:

```powershell
docker compose down
```

Dung va xoa volume du lieu Docker:

```powershell
docker compose down -v
```

Chi dung `down -v` khi muon xoa du lieu MinIO, AI memory hoac SQL Server Docker.

## 8. Chay SQL Server Bang Docker Neu May Khong Co SQL Server

Docker Compose co service `sqlserver` trong profile `full-db`.

Chay kem SQL Server Docker:

```powershell
docker compose --profile full-db up -d
```

Khi dung SQL Server Docker, sua `.env`:

```env
SPRING_DATASOURCE_URL=jdbc:sqlserver://sqlserver:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
SPRING_DATASOURCE_USERNAME=sa
SPRING_DATASOURCE_PASSWORD=YourStrong!Passw0rd
MSSQL_SA_PASSWORD=YourStrong!Passw0rd
```

Luu y: SQL Server container can password manh. Khong dung `123456` cho SQL Server Docker vi image SQL Server se tu choi khoi dong.

Sau khi SQL Server container len, tao database `DoAnHotelParkingDb` bang SSMS hoac sqlcmd.

## 9. Kiem Tra Sau Khi Deploy

Kiem tra backend:

```powershell
Invoke-WebRequest http://localhost:8080/api/hotels -UseBasicParsing
```

Kiem tra AI agent:

```powershell
Invoke-WebRequest http://localhost:8000/health -UseBasicParsing
```

Kiem tra backend proxy toi AI:

```powershell
Invoke-WebRequest http://localhost:8080/api/ai-chat/health -UseBasicParsing
```

Kiem tra web:

```powershell
Invoke-WebRequest http://localhost:8081 -UseBasicParsing
Invoke-WebRequest http://localhost:8082 -UseBasicParsing
```

Kiem tra MinIO:

```powershell
Invoke-WebRequest http://localhost:9100/minio/health/live -UseBasicParsing
Invoke-WebRequest http://localhost:9100/minio/health/ready -UseBasicParsing
```

Mo trinh duyet:

```text
Customer Web:    http://localhost:8081
Admin/Owner Web: http://localhost:8082
MinIO Console:   http://localhost:9101
Swagger:         http://localhost:8080/swagger-ui/index.html
```

## 10. Tai Khoan Test

Neu database da co du lieu mau:

```text
Admin:
admin@hotel.local
Password@123

Owner:
owner@hotel.local
Password@123

Customer:
customer.demo@hotel.local
Password@123
```

Neu dang nhap that bai, kiem tra database da co du lieu mau chua va backend log co loi migration/connection khong.

## 11. Cap Nhat Code Sau Khi Da Deploy Docker

Sau khi sua code backend/frontend/admin/AI, chay lai:

```powershell
docker compose build
docker compose up -d
```

Neu chi sua Customer FE:

```powershell
docker compose build customer-web
docker compose up -d customer-web
```

Neu chi sua Admin/Owner FE:

```powershell
docker compose build admin-web
docker compose up -d admin-web
```

Neu chi sua Backend:

```powershell
docker compose build backend
docker compose up -d backend
```

Neu trinh duyet van hien giao dien cu, bam:

```text
Ctrl + F5
```

hoac xoa cache site tren Chrome DevTools.

## 12. Chay Local Cho Dev Khong Dung Docker

Thu tu chay local:

```text
SQL Server -> MinIO -> Backend -> AIAgent -> Frontend Customer -> Frontend Admin
```

### 12.1 Backend local bang mvnd

Cau hinh trong:

```text
backend\src\main\resources\application.yml
```

Dung URL local:

```text
jdbc:sqlserver://localhost:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
```

Chay backend:

```powershell
cd "F:\Aptech\Project4\HotelBooking\backend"
mvnd spring-boot:run
```

Build/test backend:

```powershell
mvnd test
mvnd package -DskipTests
```

### 12.2 MinIO local bang Docker

Neu chay local tung phan va khong dung compose:

```powershell
docker run -d --name staysmart-minio-local `
  -p 9100:9000 -p 9101:9001 `
  -e MINIO_ROOT_USER=minioadmin `
  -e MINIO_ROOT_PASSWORD=minioadmin `
  minio/minio:RELEASE.2025-04-22T22-12-26Z server /data --console-address ":9001"
```

### 12.3 AIAgent local

```powershell
cd "F:\Aptech\Project4\HotelBooking\AIAgent"
.\.venv\Scripts\python.exe -m uvicorn chat_backend:app --host 0.0.0.0 --port 8000
```

File `AIAgent\.env` khi chay local:

```env
GROQ_API_KEY=your-groq-api-key
AUTH_API_BASE_URL=http://localhost:8080/api/auth
TRAVEL_API_BASE_URL=http://localhost:8080/api
CHAT_DB_PATH=memory.db
```

### 12.4 Customer Web local

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend"
flutter pub get
flutter run -d chrome --web-port 8081
```

### 12.5 Admin/Owner Web local

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend_employee"
flutter pub get
flutter run -d chrome --web-port 8082
```

## 13. Build Thu Cong Frontend Neu Khong Dung Docker

Customer FE:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend"
flutter clean
flutter pub get
flutter build web --release
```

Thu muc output:

```text
frontend\build\web
```

Admin/Owner FE:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend_employee"
flutter clean
flutter pub get
flutter build web --release
```

Thu muc output:

```text
frontend_employee\build\web
```

Neu deploy len domain:

```text
Authorized JavaScript origins can co domain production
PUBLIC_API_BASE_URL can la URL production
GOOGLE_CLIENT_ID dung voi Google Cloud project
```

Deploy production thi doi thanh domain that.

## 16. Lenh Nhanh Hay Dung

```powershell
cd "F:\Aptech\Project4\HotelBooking"

# build va chay toan bo
docker compose build
docker compose up -d

# xem trang thai
docker compose ps

# xem log backend
docker compose logs -f backend

# rebuild customer web
docker compose build customer-web
docker compose up -d customer-web

# tat toan bo
docker compose down
```


