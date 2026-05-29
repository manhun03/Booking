# Huong dan chay du an StaySmart

File nay danh cho nguoi chua biet code. Ban chi can lam lan luot tung buoc.

## 1. Can cai nhung gi

Hay cai cac phan mem sau truoc:

1. Java 17
2. Maven
3. Flutter SDK
4. SQL Server hoac SQL Server Express
5. SQL Server Management Studio, viet tat la SSMS
6. Docker Desktop, dung de chay MinIO luu anh
7. Visual Studio Code, neu muon mo du an de xem file

Sau khi cai xong, mo PowerShell va kiem tra:

```powershell
java -version
mvn -version
flutter --version
docker --version
```

Neu len thong tin phien ban la duoc. Neu bao khong tim thay lenh, hay cai lai hoac them phan mem do vao PATH.

## 2. Mo dung thu muc du an

Mo PowerShell, chay lenh:

```powershell
cd "D:\e-project 4\Booking"
```

Tat ca lenh ben duoi deu chay tu thu muc nay, tru khi co ghi ro phai vao thu muc khac.

## 3. Chuan bi database SQL Server

Backend dang dung cau hinh mac dinh:

```text
Server: localhost
Port: 1433
Database: DoAnHotelParkingDb
Username: sa
Password: 123456
```

Mo SSMS, dang nhap vao SQL Server, sau do mo New Query va chay:

```sql
IF DB_ID('DoAnHotelParkingDb') IS NULL
BEGIN
    CREATE DATABASE DoAnHotelParkingDb;
END
```

Neu may ban dang dung SQL Server voi port khac `1433`, can sua file:

```text
src/main/resources/application.yml
```

Dong can sua la:

```text
jdbc:sqlserver://localhost:1433;databaseName=DoAnHotelParkingDb;encrypt=true;trustServerCertificate=true
```

## 4. Chay MinIO de luu anh

Mo Docker Desktop truoc. Doi Docker hien trang thai running.

Sau do mo PowerShell va chay:

```powershell
docker start hotelparking-minio
```

Neu bao khong co container, chay lenh tao moi:

```powershell
docker run -d --name hotelparking-minio `
  -p 9000:9000 -p 9001:9001 `
  -e MINIO_ROOT_USER=minioadmin `
  -e MINIO_ROOT_PASSWORD=minioadmin `
  quay.io/minio/minio server /data --console-address ":9001"
```

Thong tin MinIO:

```text
Trang quan ly: http://localhost:9001
Tai khoan: minioadmin
Mat khau: minioadmin
```

## 5. Chay backend

Mo PowerShell tai thu muc:

```powershell
cd "D:\e-project 4\Booking"
```

Chay backend bang lenh:

```powershell
mvn spring-boot:run "-Dspring-boot.run.arguments=--server.port=8085"
```

Khong dong cua so PowerShell nay. Khi thay chuong trinh dung lai o trang thai dang chay va khong bao loi la backend da chay.

Kiem tra backend bang trinh duyet:

```text
http://localhost:8085/actuator/health
```

Neu thay trang co chu `UP` la backend da chay.

Trang xem API:

```text
http://localhost:8085/swagger-ui/index.html
```

## 6. Chay ung dung khach hang

Mo them mot cua so PowerShell moi. Khong dong cua so backend.

Chay:

```powershell
cd "D:\e-project 4\Booking\frontend"
flutter pub get
flutter run -d chrome
```

Sau do trinh duyet Chrome se mo ung dung khach hang.

Neu khong muon chay tren Chrome, co the xem thiet bi dang co:

```powershell
flutter devices
```

Roi chay:

```powershell
flutter run
```

## 7. Chay ung dung nhan vien/admin

Mo them mot cua so PowerShell moi.

Chay:

```powershell
cd "D:\e-project 4\Booking\frontend_employee"
flutter pub get
flutter run -d chrome
```

Sau do Chrome se mo ung dung nhan vien/admin.

## 8. Tai khoan dang nhap thu

Co the thu cac tai khoan sau:

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

Neu dang nhap khong duoc, co the database chua co du lieu mau. Khi do can import file backup `DoAnHotelParkingDb.bak` hoac chay script seed du lieu.

## 9. Cach dung file backup database

Trong thu muc du an co file:

```text
DoAnHotelParkingDb.bak
```

Neu database moi tao khong co du lieu, mo SSMS va restore file backup nay vao database `DoAnHotelParkingDb`.

Neu chua biet restore:

1. Mo SSMS
2. Click phai vao Databases
3. Chon Restore Database
4. Chon Device
5. Chon file `D:\e-project 4\Booking\DoAnHotelParkingDb.bak`
6. Dat ten database la `DoAnHotelParkingDb`
7. Bam OK

## 10. Tat du an

De tat frontend, bam vao cua so PowerShell dang chay Flutter, nhan:

```text
q
```

De tat backend, bam `Ctrl + C` trong cua so PowerShell dang chay backend.

De tat MinIO:

```powershell
docker stop hotelparking-minio
```

## 11. Loi thuong gap

### Loi backend khong ket noi duoc database

Kiem tra SQL Server da chay chua. Kiem tra database co ten dung la:

```text
DoAnHotelParkingDb
```

Kiem tra username/password SQL Server co dung:

```text
sa / 123456
```

### Loi port dang bi dung

Neu backend bao port `8085` dang bi dung, chay:

```powershell
Get-NetTCPConnection -LocalPort 8085
```

Co the doi backend sang port khac, nhung neu doi backend thi frontend cung phai doi theo.

### Loi Flutter khong tim thay Chrome

Kiem tra Chrome da cai chua, sau do chay:

```powershell
flutter doctor
```

### Loi Flutter tai thu vien cham hoac that bai

Thu chay lai:

```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

### Loi Docker khong chay

Mo Docker Desktop truoc, doi Docker khoi dong xong, roi chay lai lenh MinIO.

## 12. Thu tu chay moi lan sau

Moi lan muon mo du an, chi can lam thu tu nay:

1. Mo Docker Desktop
2. Mo PowerShell va chay MinIO:

```powershell
docker start hotelparking-minio
```

3. Mo PowerShell khac va chay backend:

```powershell
cd "D:\e-project 4\Booking"
mvn spring-boot:run "-Dspring-boot.run.arguments=--server.port=8085"
```

4. Mo PowerShell khac va chay frontend khach hang:

```powershell
cd "D:\e-project 4\Booking\frontend"
flutter run -d chrome
```

5. Neu can man hinh nhan vien/admin, mo PowerShell khac:

```powershell
cd "D:\e-project 4\Booking\frontend_employee"
flutter run -d chrome
```
