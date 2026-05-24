# Migration Status

## Converted in this Java project

- Spring Boot application structure.
- Maven `pom.xml` with dependencies for Web, JPA, Security, SQL Server, JWT, MinIO, Firebase and Swagger.
- Main domain entities:
  - User, Role, Permission, UserRole, RolePermission, RefreshToken, FcmToken
  - Province, Ward
  - Hotel, RoomType, Room, HotelImage, FavoriteHotel, TimeSlot
  - Booking, Payment, Review
  - Notification, OwnerSetting, SystemConfig
- Enum equivalents for booking, hotel, notification, payment, room and user statuses.
- Spring Data JPA repositories for the main aggregates.
- REST controllers for the main API resources plus business endpoints from the .NET API.
- Auth endpoints:
  - `POST /api/auth/register`
  - `POST /api/auth/login`
  - `POST /api/auth/refresh-token`
- User endpoints:
  - `POST /api/users/fcm-token`
  - `POST /api/users/addtokenforuser`
  - `POST /api/users/me/avatar`
- Booking endpoints:
  - `POST /api/bookings/request`
  - `GET /api/bookings/my-bookings`
  - `POST /api/bookings/{id}/cancel`
  - `PATCH /api/admin/{id}/force-complete`
- Favorite endpoints:
  - `GET /api/favorites/my-favorites`
  - `GET /api/favorites/{hotelId}/is-favorite`
  - `POST /api/favorites/{hotelId}/toggle`
- Owner statistics endpoints:
  - `GET /api/statistics/owner/dashboard`
  - `GET /api/statistics/owner/revenue`
  - `GET /api/statistics/owner/top-rooms`
  - `GET /api/statistics/owner/peak-hours`
  - `GET /api/statistics/owner/upcoming`
  - `GET /api/statistics/owner/revenue-summary`
  - `GET /api/statistics/owner/revenue-comparison`
- Owner setting bank-info endpoints.
- System config endpoints by key.
- Permission module endpoints.
- MinIO upload endpoint:
  - `POST /api/hotels/{hotelId}/images/upload`
- Firebase push service skeleton with token lookup and delivery.
- Startup seeders for roles, permissions, role-permissions, room types and Vietnam locations.
- Recommendation endpoints:
  - `GET /api/recommendations/similar/{hotelId}`
  - `GET /api/recommendations/new-user`
  - `GET /api/recommendations/personalized`
  - `GET /api/recommendations/smart`
- Recommendation algorithm ported from the .NET implementation.
- JWT authentication, role checks and permission annotation support.
- CORS is enabled for Flutter web/mobile development clients.
- Swagger/OpenAPI includes Bearer JWT security configuration.
- Actuator health endpoint is available at `GET /actuator/health`.
- Location write endpoints now require Admin plus `location.manage`; location read endpoints remain public like the .NET API.
- `GET /api/room-types/by-hotel` is implemented.

## Still needs full parity work

- Exact DTO response shapes for every endpoint, if the frontend depends on field-for-field compatibility with the .NET DTOs.
- Some lower-risk admin CRUD endpoints still expose JPA entities directly; Hotel, Booking, Location, Favorite, OwnerSetting, Room filter endpoints and HotelImage endpoints now use DTO responses for Flutter-facing flows.
- Database migration scripts if you do not want Hibernate `ddl-auto:update`.
- Runtime verification against a real SQL Server, MinIO and Firebase credential set.

## Verification note

This project is configured for Java 17 because the available JDK is `17.0.12`.
`mvn -q -DskipTests package` builds successfully.
