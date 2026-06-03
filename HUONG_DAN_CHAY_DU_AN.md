# Huong Dan Chay Du An StaySmart

Tai lieu nay dung cho du an tai:

```text
F:\Aptech\Project4\HotelBooking
```

Du an gom 4 phan chinh:

```text
backend            Backend Spring Boot
frontend            Ung dung khach hang Flutter
frontend_employee   Ung dung nhan vien/admin Flutter
AIAgent             Dich vu Chat AI FastAPI
```

Thu tu chay khuyen nghi:

```text
SQL Server -> MinIO -> Backend -> AIAgent -> Frontend
```

## 1. Phan Mem Can Cai

Can cai truoc cac phan mem sau:

```text
Java 17
Maven Daemon mvnd
Flutter SDK
Chrome
SQL Server / SQL Server Express
SQL Server Management Studio
Docker Desktop
Python 3.12
Git
```

Kiem tra nhanh trong PowerShell:

```powershell
java -version
mvnd -v
flutter --version
docker --version
python --version
git --version
```

Backend cua du an chay bang `mvnd`. Neu may chua co `mvnd`, can cai Maven Daemon truoc khi chay backend.

## 2. Mo Thu Muc Du An

Tat ca lenh ben duoi bat dau tu thu muc goc:

```powershell
cd "F:\Aptech\Project4\HotelBooking"
```

## 3. Database SQL Server

Backend dang dung database:

```text
Database: DoAnHotelParkingDb
Server: localhost
Port: 1433
Username: sa
Password: 123456
```

Mo SSMS va tao database neu chua co:

```sql
IF DB_ID('DoAnHotelParkingDb') IS NULL
BEGIN
    CREATE DATABASE DoAnHotelParkingDb;
END
```

Cau hinh backend nam tai:

```text
F:\Aptech\Project4\HotelBooking\backend\src\main\resources\application.yml
```

Dong ket noi can tro vao database:

```text
jdbc:sqlserver://localhost:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
```

Neu SQL Server cua may dung user/password khac, sua trong `application.yml`.

## 4. Restore Database Mau

Neu database trong may chua co du lieu mau, restore file backup:

```text
F:\Aptech\Project4\HotelBooking\DoAnHotelParkingDb.bak
```

Cach restore trong SSMS:

```text
1. Mo SSMS
2. Click phai Databases
3. Chon Restore Database
4. Chon Device
5. Chon file DoAnHotelParkingDb.bak
6. Dat ten database la DoAnHotelParkingDb
7. Bam OK
```

## 5. Chay MinIO Luu Anh

Mo Docker Desktop truoc, doi Docker chay xong.

Chay container MinIO neu da ton tai:

```powershell
docker start hotelparking-minio
```

Neu container chua ton tai, tao moi:

```powershell
docker run -d --name hotelparking-minio `
  -p 9000:9000 -p 9001:9001 `
  -e MINIO_ROOT_USER=minioadmin `
  -e MINIO_ROOT_PASSWORD=minioadmin `
  quay.io/minio/minio server /data --console-address ":9001"
```

Kiem tra MinIO:

```text
Console: http://localhost:9001
API:     http://localhost:9000
User:    minioadmin
Pass:    minioadmin
```

Lenh kiem tra health:

```powershell
Invoke-RestMethod http://localhost:9000/minio/health/live
Invoke-RestMethod http://localhost:9000/minio/health/ready
```

## 6. Firebase

Firebase dang dung project:

```text
hotelparking-9c7ce
```

Kiem tra trong file:

```text
F:\Aptech\Project4\HotelBooking\backend\src\main\resources\application.yml
```

Gia tri can dung:

```yaml
app:
  firebase:
    project-id: hotelparking-9c7ce
```

Service account JSON can dung dung project `hotelparking-9c7ce`.

Khong day service account JSON len GitHub neu repo public.

## 7. Chay Backend

Mo PowerShell moi:

```powershell
cd "F:\Aptech\Project4\HotelBooking\backend"
mvnd spring-boot:run
```



Backend mac dinh chay:

```text
http://localhost:8080
```

Kiem tra backend:

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health
```

Swagger:

```text
http://localhost:8080/swagger-ui/index.html
```

Build/test backend:

```powershell
cd "F:\Aptech\Project4\HotelBooking\backend"
mvnd test
mvnd package -DskipTests
```

## 8. Chay AIAgent

AIAgent can file `.env` trong:

```text
F:\Aptech\Project4\HotelBooking\AIAgent\.env
```

Noi dung can co:

```env
GROQ_API_KEY=your-groq-api-key
AUTH_API_BASE_URL=http://localhost:8080/api/auth
TRAVEL_API_BASE_URL=http://localhost:8080/api
```

Chay AIAgent:

```powershell
cd "F:\Aptech\Project4\HotelBooking\AIAgent"
.\.venv\Scripts\python.exe -m uvicorn chat_backend:app --host 0.0.0.0 --port 8000
```

Neu muon activate venv truoc:

```powershell
cd "F:\Aptech\Project4\HotelBooking\AIAgent"
.\.venv\Scripts\activate
uvicorn chat_backend:app --host 0.0.0.0 --port 8000
```

Kiem tra AIAgent:

```powershell
Invoke-RestMethod http://localhost:8000/health
```

Swagger AIAgent:

```text
http://localhost:8000/docs
```

## 9. Kiem Tra Backend Noi Voi AIAgent

Khi backend va AIAgent deu dang chay, kiem tra proxy AI:

```powershell
Invoke-RestMethod http://localhost:8080/api/ai-chat/health
```

Neu tra ve:

```json
{"status":"ok"}
```

la backend da noi duoc voi AIAgent.

Neu loi, kiem tra:

```text
Backend dang chay port 8080
AIAgent dang chay port 8000
AI_AGENT_BASE_URL trong backend neu co custom
GROQ_API_KEY trong AIAgent\.env
```

## 10. Chay Frontend Khach Hang

Mo PowerShell moi:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend"
flutter pub get
flutter run -d chrome --web-port 8081
```

Frontend khach hang:

```text
http://localhost:8081
```

Neu man hinh trang sau khi F5, chay lai:

```powershell
flutter clean
flutter pub get
flutter run -d chrome --web-port 8081
```

## 11. Chay Frontend Nhan Vien/Admin

Mo PowerShell moi:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend_employee"
flutter pub get
flutter run -d chrome --web-port 8082
```

Frontend nhan vien/admin:

```text
http://localhost:8082
```

## 12. Test Chat AI

Can chay du cac phan:

```text
SQL Server
MinIO
Backend port 8080
AIAgent port 8000
Frontend port 8081
```

Dang nhap customer:

```text
Email:    customer.demo@hotel.local
Password: Password@123
```

Mo frontend:

```text
http://localhost:8081
```

Mo box Chat AI va nhap:

```text
Toi muon dat phong khach san
```

Neu chat thanh cong, AI se hoi them thong tin nhu dia diem, ngay o, so khach, ngan sach.

Neu gap loi `422 UNPROCESSABLE_ENTITY` voi `thread_id required`, nghia la frontend dang gui sai body. API dung la:

```json
{
  "thread_id": "id-thread",
  "message": "Noi dung cau hoi"
}
```

Khong dung:

```json
{
  "threadId": "id-thread",
  "message": "Noi dung cau hoi"
}
```

## 13. Test Dang Nhap Google

Backend Google login dung endpoint:

```text
POST http://localhost:8080/api/auth/google
```

Khi chay Flutter web voi port co dinh:

```text
http://localhost:8081
```

Trong Google Cloud Console can them Authorized JavaScript origins:

```text
http://localhost:8081
```

Neu doi port frontend, phai them port moi vao Google Cloud Console.

## 14. Tai Khoan Test

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

Neu dang nhap that bai, kiem tra database da restore du lieu mau chua.

## 15. Lenh Chay Tung Phan

SQL Server:

```text
Mo SQL Server Services va dam bao SQL Server dang Running
```

MinIO:

```powershell
docker start hotelparking-minio
```

Backend:

```powershell
cd "F:\Aptech\Project4\HotelBooking\backend"
mvnd spring-boot:run
```

AIAgent:

```powershell
cd "F:\Aptech\Project4\HotelBooking\AIAgent"
.\.venv\Scripts\python.exe -m uvicorn chat_backend:app --host 0.0.0.0 --port 8000
```

Frontend khach hang:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend"
flutter run -d chrome --web-port 8081
```

Frontend nhan vien/admin:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend_employee"
flutter run -d chrome --web-port 8082
```

## 16. Build Va Deploy Frontend

Khi sua code Flutter va du an da deploy, can build lai web bundle roi dua thu muc build len hosting/server.

Build frontend khach hang:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend"
flutter clean
flutter pub get
flutter build web
```

Thu muc can deploy:

```text
F:\Aptech\Project4\HotelBooking\frontend\build\web
```

Build frontend nhan vien/admin/owner:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend_employee"
flutter clean
flutter pub get
flutter build web
```

Thu muc can deploy:

```text
F:\Aptech\Project4\HotelBooking\frontend_employee\build\web
```

Sau khi deploy, neu trinh duyet van hien giao dien cu, hard refresh bang `Ctrl + Shift + R` hoac xoa cache cua site.

## 17. Tat Du An

Tat Flutter:

```text
Bam q trong cua so PowerShell dang chay Flutter
```

Tat backend/AIAgent:

```text
Bam Ctrl + C trong cua so PowerShell dang chay service
```

Tat MinIO:

```powershell
docker stop hotelparking-minio
```

## 18. Loi Thuong Gap

### Backend khong ket noi duoc SQL Server

Kiem tra:

```text
SQL Server dang Running
Database ten dung la DoAnHotelParkingDb
Port SQL Server la 1433
User/password dung voi application.yml
```

### Port 8080, 8000, 8081 hoac 8082 bi trung

Kiem tra process dang dung port:

```powershell
Get-NetTCPConnection -LocalPort 8080 -State Listen
Get-NetTCPConnection -LocalPort 8000 -State Listen
Get-NetTCPConnection -LocalPort 8081 -State Listen
Get-NetTCPConnection -LocalPort 8082 -State Listen
```

Dung process:

```powershell
$p = (Get-NetTCPConnection -LocalPort 8000 -State Listen).OwningProcess
Stop-Process -Id $p -Force
```

Doi `8000` thanh port can tat.

### AIAgent thieu GROQ_API_KEY

Them vao:

```text
F:\Aptech\Project4\HotelBooking\AIAgent\.env
```

Gia tri:

```env
GROQ_API_KEY=your-groq-api-key
```

Sau do restart AIAgent.

### Chat AI bao 422 thread_id required

Can dam bao frontend tao thread truoc, sau do gui message voi field:

```text
thread_id
```

Khong gui field:

```text
threadId
```

### F5 frontend bi trang trang

Thu chay lai frontend:

```powershell
cd "F:\Aptech\Project4\HotelBooking\frontend"
flutter clean
flutter pub get
flutter run -d chrome --web-port 8081
```

Neu van bi trang, mo DevTools cua Chrome va xem loi Console.

### MinIO khong upload duoc anh

Kiem tra Docker va MinIO:

```powershell
docker ps
Invoke-RestMethod http://localhost:9000/minio/health/live
```

### Google login khong hoat dong

Kiem tra:

```text
Frontend dang chay dung port da khai bao trong Google Cloud
Client ID frontend/backend giong nhau
Authorized JavaScript origins co http://localhost:8081
```

## 19. Day Code Len GitHub

Repo remote:

```text
https://github.com/manhun03/Booking.git
```

Kiem tra branch hien tai:

```powershell
git status -sb
git branch --show-current
```

Neu push bi loi:

```text
rejected: fetch first
```

Thi remote dang co commit moi hon local. Xu ly an toan:

```powershell
git fetch origin
git status -sb
git pull --rebase origin main
git push -u origin main
```

Neu dang lam tren branch khac, thay `main` bang ten branch hien tai.

Khong dung `git push --force` neu chua chac chan, vi co the ghi de code tren GitHub.

