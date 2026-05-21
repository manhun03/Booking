# Hotel Booking API Java Port

This folder is a new Java/Spring Boot version of the original .NET hotel booking backend.

## What is included

- Spring Boot REST API project.
- SQL Server/JPA persistence model for the main domain entities.
- JWT security wiring.
- MinIO and Firebase configuration placeholders.
- CRUD controllers for the main resources.
- Recommendation service ported from the .NET content-based algorithm.

## Run

```powershell
mvn spring-boot:run
```

Swagger UI:

```text
http://localhost:8080/swagger-ui.html
```

## Notes

The original .NET project remains unchanged. This Java project is a parallel port intended as the base for completing endpoint parity module by module.
