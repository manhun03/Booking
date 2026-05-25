SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

DECLARE @PasswordHash varchar(255) = '$2a$10$CQskqg9eCUJiQChkD.i2reKdPbItvbfxVg3h8Ux4zdAHDyJCP/y66'; -- Password@123
DECLARE @Now datetime2 = SYSUTCDATETIME();

DECLARE @AdminRoleId int = (SELECT TOP 1 Id FROM [Role] WHERE [Name] = 'Admin');
DECLARE @OwnerRoleId int = (SELECT TOP 1 Id FROM [Role] WHERE [Name] = 'Owner');
DECLARE @CustomerRoleId int = (SELECT TOP 1 Id FROM [Role] WHERE [Name] = 'Customer');
DECLARE @WardId int = ISNULL((SELECT TOP 1 Id FROM Ward WHERE IsActive = 1 ORDER BY Id), (SELECT TOP 1 Id FROM Ward ORDER BY Id));
DECLARE @StandardRoomTypeId int = ISNULL((SELECT TOP 1 Id FROM RoomType WHERE [Name] LIKE '%Standard%' ORDER BY Id), (SELECT TOP 1 Id FROM RoomType ORDER BY Id));
DECLARE @DeluxeRoomTypeId int = ISNULL((SELECT TOP 1 Id FROM RoomType WHERE [Name] LIKE '%Deluxe%' ORDER BY Id), @StandardRoomTypeId);

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'admin.demo@hotel.local')
BEGIN
    INSERT INTO [User] (LastName, FirstName, Email, Phone, [Password], AvatarUrl, [Status], IsDeleted, DeletedBy, CreatedAt, UpdatedAt, DeletedAt, EmailVerified, Username)
    VALUES ('System', 'Admin', 'admin.demo@hotel.local', '0900000001', @PasswordHash, NULL, 1, 0, NULL, @Now, @Now, NULL, 1, 'admin_demo');
END;

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'owner.demo@hotel.local')
BEGIN
    INSERT INTO [User] (LastName, FirstName, Email, Phone, [Password], AvatarUrl, [Status], IsDeleted, DeletedBy, CreatedAt, UpdatedAt, DeletedAt, EmailVerified, Username)
    VALUES ('Demo', 'Owner', 'owner.demo@hotel.local', '0900000002', @PasswordHash, NULL, 1, 0, NULL, @Now, @Now, NULL, 1, 'owner_demo');
END;

IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'customer.demo@hotel.local')
BEGIN
    INSERT INTO [User] (LastName, FirstName, Email, Phone, [Password], AvatarUrl, [Status], IsDeleted, DeletedBy, CreatedAt, UpdatedAt, DeletedAt, EmailVerified, Username)
    VALUES ('Demo', 'Customer', 'customer.demo@hotel.local', '0900000003', @PasswordHash, NULL, 1, 0, NULL, @Now, @Now, NULL, 1, 'customer_demo');
END;

DECLARE @AdminId int = (SELECT Id FROM [User] WHERE Email = 'admin.demo@hotel.local');
DECLARE @OwnerId int = (SELECT Id FROM [User] WHERE Email = 'owner.demo@hotel.local');
DECLARE @CustomerId int = (SELECT Id FROM [User] WHERE Email = 'customer.demo@hotel.local');

IF NOT EXISTS (SELECT 1 FROM UserRole WHERE UserId = @AdminId AND RoleId = @AdminRoleId)
    INSERT INTO UserRole (UserId, RoleId, CreatedAt) VALUES (@AdminId, @AdminRoleId, @Now);
IF NOT EXISTS (SELECT 1 FROM UserRole WHERE UserId = @OwnerId AND RoleId = @OwnerRoleId)
    INSERT INTO UserRole (UserId, RoleId, CreatedAt) VALUES (@OwnerId, @OwnerRoleId, @Now);
IF NOT EXISTS (SELECT 1 FROM UserRole WHERE UserId = @CustomerId AND RoleId = @CustomerRoleId)
    INSERT INTO UserRole (UserId, RoleId, CreatedAt) VALUES (@CustomerId, @CustomerRoleId, @Now);

IF NOT EXISTS (SELECT 1 FROM Hotel WHERE [Name] = 'EasyStay Riverside Demo')
BEGIN
    INSERT INTO Hotel (OwnerId, WardId, [Name], Street, Phone, [Description], [Status], IsDeleted, CreatedAt, UpdatedAt)
    VALUES (@OwnerId, @WardId, 'EasyStay Riverside Demo', '12 Tran Phu', '02877770001', 'Riverside business hotel with breakfast, pool and airport pickup.', 1, 0, @Now, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM Hotel WHERE [Name] = 'EasyStay Ocean Demo')
BEGIN
    INSERT INTO Hotel (OwnerId, WardId, [Name], Street, Phone, [Description], [Status], IsDeleted, CreatedAt, UpdatedAt)
    VALUES (@OwnerId, @WardId, 'EasyStay Ocean Demo', '88 Vo Nguyen Giap', '02877770002', 'Beach hotel for family vacations with seasonal promotion rooms.', 2, 0, @Now, @Now);
END;

DECLARE @HotelActiveId int = (SELECT Id FROM Hotel WHERE [Name] = 'EasyStay Riverside Demo');
DECLARE @HotelPendingId int = (SELECT Id FROM Hotel WHERE [Name] = 'EasyStay Ocean Demo');

IF NOT EXISTS (SELECT 1 FROM OwnerSetting WHERE OwnerId = @OwnerId)
BEGIN
    INSERT INTO OwnerSetting (OwnerId, DepositRate, MinBookingNotice, AllowReview, BankName, BankAccountNumber, BankAccountName, BankQrCodeUrl, CreatedAt, UpdatedAt)
    VALUES (@OwnerId, 0.3000, 2, 1, 'VCB', '0123456789', 'DEMO OWNER', NULL, @Now, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM HotelImage WHERE HotelId = @HotelActiveId AND IsPrimary = 1)
BEGIN
    INSERT INTO HotelImage (HotelId, ImageUrl, ObjectKey, IsPrimary, SortOrder, CreatedAt)
    VALUES (@HotelActiveId, 'http://localhost:9000/hotel-images/demo/riverside-main.jpg', 'demo/riverside-main.jpg', 1, 1, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM HotelImage WHERE HotelId = @HotelPendingId AND IsPrimary = 1)
BEGIN
    INSERT INTO HotelImage (HotelId, ImageUrl, ObjectKey, IsPrimary, SortOrder, CreatedAt)
    VALUES (@HotelPendingId, 'http://localhost:9000/hotel-images/demo/ocean-main.jpg', 'demo/ocean-main.jpg', 1, 1, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM Room WHERE HotelId = @HotelActiveId AND RoomNumber = 'A101')
BEGIN
    INSERT INTO Room (HotelId, RoomTypeId, RoomNumber, Capacity, Price, [Status], IsDeleted, CreatedAt, Amenities, SeasonalPrice, PromotionPrice)
    VALUES (@HotelActiveId, @StandardRoomTypeId, 'A101', 2, 850000, 1, 0, @Now, 'WiFi, Breakfast, City view, Air conditioning', 950000, 790000);
END;

IF NOT EXISTS (SELECT 1 FROM Room WHERE HotelId = @HotelActiveId AND RoomNumber = 'A201')
BEGIN
    INSERT INTO Room (HotelId, RoomTypeId, RoomNumber, Capacity, Price, [Status], IsDeleted, CreatedAt, Amenities, SeasonalPrice, PromotionPrice)
    VALUES (@HotelActiveId, @DeluxeRoomTypeId, 'A201', 4, 1350000, 1, 0, @Now, 'WiFi, Breakfast, River view, Bathtub, Airport pickup', 1550000, 1250000);
END;

IF NOT EXISTS (SELECT 1 FROM Room WHERE HotelId = @HotelPendingId AND RoomNumber = 'B101')
BEGIN
    INSERT INTO Room (HotelId, RoomTypeId, RoomNumber, Capacity, Price, [Status], IsDeleted, CreatedAt, Amenities, SeasonalPrice, PromotionPrice)
    VALUES (@HotelPendingId, @DeluxeRoomTypeId, 'B101', 3, 1200000, 1, 0, @Now, 'WiFi, Ocean view, Pool access', 1400000, 990000);
END;

DECLARE @RoomA101 int = (SELECT Id FROM Room WHERE HotelId = @HotelActiveId AND RoomNumber = 'A101');
DECLARE @RoomA201 int = (SELECT Id FROM Room WHERE HotelId = @HotelActiveId AND RoomNumber = 'A201');

IF NOT EXISTS (SELECT 1 FROM TimeSlot WHERE RoomId = @RoomA101 AND StartDate = '2026-06-01')
BEGIN
    INSERT INTO TimeSlot (RoomId, StartDate, EndDate, Price, IsActive, CreatedAt, UpdatedAt)
    VALUES (@RoomA101, '2026-06-01', '2026-08-31', 780000, 1, @Now, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM Coupon WHERE Code = 'DEMO10')
BEGIN
    INSERT INTO Coupon (Code, [Description], DiscountType, DiscountValue, MaxDiscountAmount, MinOrderAmount, StartAt, EndAt, MaxUses, UsedCount, IsActive, CreatedAt)
    VALUES ('DEMO10', 'Demo coupon: 10 percent off for testing checkout.', 'PERCENT', 10, 200000, 0, DATEADD(day, -1, @Now), DATEADD(day, 90, @Now), 100, 0, 1, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM Coupon WHERE Code = 'WELCOME500')
BEGIN
    INSERT INTO Coupon (Code, [Description], DiscountType, DiscountValue, MaxDiscountAmount, MinOrderAmount, StartAt, EndAt, MaxUses, UsedCount, IsActive, CreatedAt)
    VALUES ('WELCOME500', 'Demo coupon: fixed 500000 VND discount.', 'FIXED', 500000, 500000, 1000000, DATEADD(day, -1, @Now), DATEADD(day, 90, @Now), 50, 0, 1, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM Booking WHERE CustomerId = @CustomerId AND RoomId = @RoomA101 AND Note = 'Demo pending booking')
BEGIN
    INSERT INTO Booking (RoomId, CustomerId, CheckInDate, CheckOutDate, NightCount, GuestCount, RoomUnitPrice, TotalAmount, PaidAmount, Note, [Status], CancelledBy, CancelReason, CancelledAt, CreatedAt, UpdatedAt, CancellationFee, RejectedReason, RejectedAt, CheckedInAt, CheckedOutAt)
    VALUES (@RoomA101, @CustomerId, DATEADD(day, 7, @Now), DATEADD(day, 9, @Now), 2, 2, 850000, 1700000, 0, 'Demo pending booking', 0, NULL, NULL, NULL, @Now, @Now, 0, NULL, NULL, NULL, NULL);
END;

IF NOT EXISTS (SELECT 1 FROM Booking WHERE CustomerId = @CustomerId AND RoomId = @RoomA201 AND Note = 'Demo confirmed booking')
BEGIN
    INSERT INTO Booking (RoomId, CustomerId, CheckInDate, CheckOutDate, NightCount, GuestCount, RoomUnitPrice, TotalAmount, PaidAmount, Note, [Status], CancelledBy, CancelReason, CancelledAt, CreatedAt, UpdatedAt, CancellationFee, RejectedReason, RejectedAt, CheckedInAt, CheckedOutAt)
    VALUES (@RoomA201, @CustomerId, DATEADD(day, 14, @Now), DATEADD(day, 16, @Now), 2, 3, 1350000, 2700000, 2700000, 'Demo confirmed booking', 1, NULL, NULL, NULL, @Now, @Now, 0, NULL, NULL, NULL, NULL);
END;

IF NOT EXISTS (SELECT 1 FROM Booking WHERE CustomerId = @CustomerId AND RoomId = @RoomA101 AND Note = 'Demo completed booking')
BEGIN
    INSERT INTO Booking (RoomId, CustomerId, CheckInDate, CheckOutDate, NightCount, GuestCount, RoomUnitPrice, TotalAmount, PaidAmount, Note, [Status], CancelledBy, CancelReason, CancelledAt, CreatedAt, UpdatedAt, CancellationFee, RejectedReason, RejectedAt, CheckedInAt, CheckedOutAt)
    VALUES (@RoomA101, @CustomerId, DATEADD(day, -10, @Now), DATEADD(day, -8, @Now), 2, 2, 850000, 1700000, 1700000, 'Demo completed booking', 3, NULL, NULL, NULL, DATEADD(day, -15, @Now), DATEADD(day, -8, @Now), 0, NULL, NULL, DATEADD(day, -10, @Now), DATEADD(day, -8, @Now));
END;

DECLARE @PendingBooking int = (SELECT Id FROM Booking WHERE CustomerId = @CustomerId AND Note = 'Demo pending booking');
DECLARE @ConfirmedBooking int = (SELECT Id FROM Booking WHERE CustomerId = @CustomerId AND Note = 'Demo confirmed booking');
DECLARE @CompletedBooking int = (SELECT Id FROM Booking WHERE CustomerId = @CustomerId AND Note = 'Demo completed booking');

IF NOT EXISTS (SELECT 1 FROM Payment WHERE TransactionCode = 'DEMO-PENDING-001')
BEGIN
    INSERT INTO Payment (BookingId, Amount, Method, [Status], TransactionCode, Note, PaidAt, CreatedAt, Provider, GatewayTransactionId, CheckoutUrl, FailureReason, RefundedAmount, RefundedAt, UpdatedAt)
    VALUES (@PendingBooking, 500000, 'CARD', 0, 'DEMO-PENDING-001', 'Pending payment for demo booking', NULL, @Now, 'MOCK', NULL, 'mock://checkout/DEMO-PENDING-001', NULL, 0, NULL, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM Payment WHERE TransactionCode = 'DEMO-PAID-001')
BEGIN
    INSERT INTO Payment (BookingId, Amount, Method, [Status], TransactionCode, Note, PaidAt, CreatedAt, Provider, GatewayTransactionId, CheckoutUrl, FailureReason, RefundedAmount, RefundedAt, UpdatedAt)
    VALUES (@ConfirmedBooking, 2700000, 'CARD', 1, 'DEMO-PAID-001', 'Completed payment for demo booking', @Now, @Now, 'MOCK', 'GW-DEMO-PAID-001', 'mock://checkout/DEMO-PAID-001', NULL, 0, NULL, @Now);
END;

IF NOT EXISTS (SELECT 1 FROM Review WHERE BookingId = @CompletedBooking AND CustomerId = @CustomerId)
BEGIN
    INSERT INTO Review (BookingId, CustomerId, RoomId, Rating, Comment, CreatedAt, OwnerReply, OwnerRepliedAt, IsReported, ReportReason, IsVisible, ModeratedAt)
    VALUES (@CompletedBooking, @CustomerId, @RoomA101, 5, 'Clean room, fast check-in and helpful owner.', DATEADD(day, -7, @Now), 'Thank you for staying with us.', DATEADD(day, -6, @Now), 0, NULL, 1, NULL);
END;

IF NOT EXISTS (SELECT 1 FROM Notification WHERE UserId = @CustomerId AND Title = 'Demo booking confirmed')
BEGIN
    INSERT INTO Notification (UserId, SenderId, Title, [Message], [Type], RelatedTable, RelatedId, IsRead, CreatedAt, ReadAt)
    VALUES (@CustomerId, @OwnerId, 'Demo booking confirmed', 'Your demo booking has been confirmed.', 1, 'Booking', @ConfirmedBooking, 0, @Now, NULL);
END;

IF NOT EXISTS (SELECT 1 FROM Notification WHERE UserId = @OwnerId AND Title = 'Demo new booking')
BEGIN
    INSERT INTO Notification (UserId, SenderId, Title, [Message], [Type], RelatedTable, RelatedId, IsRead, CreatedAt, ReadAt)
    VALUES (@OwnerId, @CustomerId, 'Demo new booking', 'Customer created a pending demo booking.', 1, 'Booking', @PendingBooking, 0, @Now, NULL);
END;

IF NOT EXISTS (SELECT 1 FROM ChatMessage WHERE SenderId = @CustomerId AND ReceiverId = @OwnerId AND Content = 'Hello, is early check-in available?')
BEGIN
    INSERT INTO ChatMessage (SenderId, ReceiverId, BookingId, Content, IsRead, CreatedAt, ReadAt)
    VALUES (@CustomerId, @OwnerId, @ConfirmedBooking, 'Hello, is early check-in available?', 0, DATEADD(minute, -30, @Now), NULL);
END;

IF NOT EXISTS (SELECT 1 FROM ChatMessage WHERE SenderId = @OwnerId AND ReceiverId = @CustomerId AND Content = 'Yes, early check-in is available after 12:00.')
BEGIN
    INSERT INTO ChatMessage (SenderId, ReceiverId, BookingId, Content, IsRead, CreatedAt, ReadAt)
    VALUES (@OwnerId, @CustomerId, @ConfirmedBooking, 'Yes, early check-in is available after 12:00.', 0, DATEADD(minute, -20, @Now), NULL);
END;

IF NOT EXISTS (SELECT 1 FROM AuditLog WHERE Action = 'DEMO_SEED')
BEGIN
    INSERT INTO AuditLog (ActorId, Action, TargetTable, TargetId, Detail, CreatedAt)
    VALUES (@AdminId, 'DEMO_SEED', 'Database', NULL, 'Inserted demo data for Flutter and Java backend testing.', @Now);
END;

SELECT 'Demo data ready' AS Result,
       @AdminId AS AdminUserId,
       @OwnerId AS OwnerUserId,
       @CustomerId AS CustomerUserId,
       @HotelActiveId AS ActiveHotelId,
       @PendingBooking AS PendingBookingId,
       @ConfirmedBooking AS ConfirmedBookingId,
       @CompletedBooking AS CompletedBookingId;
