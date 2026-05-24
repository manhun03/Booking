# Booking

This repo now contains:

- `src/` + `pom.xml`: Spring Boot backend from branch `be`
- `frontend/`: Flutter app

## Backend

The backend runs on `http://localhost:8080` and exposes APIs under
`http://localhost:8080/api`.

Requirements:

- Java 17+
- Maven
- SQL Server running with the connection configured in
  `src/main/resources/application.yml`

Run:

```powershell
mvn spring-boot:run
```

Swagger UI:

```text
http://localhost:8080/swagger-ui.html
```

Health check:

```text
http://localhost:8080/actuator/health
```

## Frontend

Run from the frontend folder:

```powershell
cd frontend
flutter pub get
flutter run
```

By default, Flutter web/desktop uses:

```text
http://localhost:8080/api
```

Android emulator uses:

```text
http://10.0.2.2:8080/api
```

For a physical phone or a different backend URL, pass:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8080/api
```
