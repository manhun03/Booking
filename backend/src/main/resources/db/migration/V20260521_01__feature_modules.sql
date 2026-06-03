IF COL_LENGTH('Payment', 'Provider') IS NULL ALTER TABLE [Payment] ADD [Provider] nvarchar(50) NULL;
IF COL_LENGTH('Payment', 'GatewayTransactionId') IS NULL ALTER TABLE [Payment] ADD [GatewayTransactionId] nvarchar(255) NULL;
IF COL_LENGTH('Payment', 'CheckoutUrl') IS NULL ALTER TABLE [Payment] ADD [CheckoutUrl] nvarchar(1000) NULL;
IF COL_LENGTH('Payment', 'FailureReason') IS NULL ALTER TABLE [Payment] ADD [FailureReason] nvarchar(1000) NULL;
IF COL_LENGTH('Payment', 'RefundedAmount') IS NULL ALTER TABLE [Payment] ADD [RefundedAmount] decimal(18,2) NOT NULL CONSTRAINT DF_Payment_RefundedAmount DEFAULT 0;
IF COL_LENGTH('Payment', 'RefundedAt') IS NULL ALTER TABLE [Payment] ADD [RefundedAt] datetime2 NULL;
IF COL_LENGTH('Payment', 'UpdatedAt') IS NULL ALTER TABLE [Payment] ADD [UpdatedAt] datetime2 NULL;
GO
IF COL_LENGTH('Review', 'OwnerReply') IS NULL ALTER TABLE [Review] ADD [OwnerReply] nvarchar(2000) NULL;
IF COL_LENGTH('Review', 'OwnerRepliedAt') IS NULL ALTER TABLE [Review] ADD [OwnerRepliedAt] datetime2 NULL;
IF COL_LENGTH('Review', 'IsReported') IS NULL ALTER TABLE [Review] ADD [IsReported] bit NOT NULL CONSTRAINT DF_Review_IsReported DEFAULT 0;
IF COL_LENGTH('Review', 'ReportReason') IS NULL ALTER TABLE [Review] ADD [ReportReason] nvarchar(1000) NULL;
IF COL_LENGTH('Review', 'IsVisible') IS NULL ALTER TABLE [Review] ADD [IsVisible] bit NOT NULL CONSTRAINT DF_Review_IsVisible DEFAULT 1;
IF COL_LENGTH('Review', 'ModeratedAt') IS NULL ALTER TABLE [Review] ADD [ModeratedAt] datetime2 NULL;
GO
IF COL_LENGTH('Booking', 'CancellationFee') IS NULL ALTER TABLE [Booking] ADD [CancellationFee] decimal(18,2) NOT NULL CONSTRAINT DF_Booking_CancellationFee DEFAULT 0;
IF COL_LENGTH('Booking', 'RejectedReason') IS NULL ALTER TABLE [Booking] ADD [RejectedReason] nvarchar(1000) NULL;
IF COL_LENGTH('Booking', 'RejectedAt') IS NULL ALTER TABLE [Booking] ADD [RejectedAt] datetime2 NULL;
IF COL_LENGTH('Booking', 'CheckedInAt') IS NULL ALTER TABLE [Booking] ADD [CheckedInAt] datetime2 NULL;
IF COL_LENGTH('Booking', 'CheckedOutAt') IS NULL ALTER TABLE [Booking] ADD [CheckedOutAt] datetime2 NULL;
GO
IF COL_LENGTH('Room', 'Amenities') IS NULL ALTER TABLE [Room] ADD [Amenities] nvarchar(2000) NULL;
IF COL_LENGTH('Room', 'SeasonalPrice') IS NULL ALTER TABLE [Room] ADD [SeasonalPrice] decimal(18,2) NULL;
IF COL_LENGTH('Room', 'PromotionPrice') IS NULL ALTER TABLE [Room] ADD [PromotionPrice] decimal(18,2) NULL;
GO
IF OBJECT_ID('Coupon', 'U') IS NULL
BEGIN
    CREATE TABLE [Coupon] (
        [Id] int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Coupon PRIMARY KEY,
        [Code] nvarchar(100) NOT NULL,
        [Description] nvarchar(1000) NULL,
        [DiscountType] nvarchar(20) NOT NULL,
        [DiscountValue] decimal(18,2) NOT NULL CONSTRAINT DF_Coupon_DiscountValue DEFAULT 0,
        [MaxDiscountAmount] decimal(18,2) NULL,
        [MinOrderAmount] decimal(18,2) NOT NULL CONSTRAINT DF_Coupon_MinOrderAmount DEFAULT 0,
        [StartAt] datetime2 NULL,
        [EndAt] datetime2 NULL,
        [MaxUses] int NULL,
        [UsedCount] int NOT NULL CONSTRAINT DF_Coupon_UsedCount DEFAULT 0,
        [IsActive] bit NOT NULL CONSTRAINT DF_Coupon_IsActive DEFAULT 1,
        [CreatedAt] datetime2 NOT NULL
    );
    CREATE UNIQUE INDEX IX_Coupon_Code ON [Coupon]([Code]);
END;
GO
IF OBJECT_ID('ChatMessage', 'U') IS NULL
BEGIN
    CREATE TABLE [ChatMessage] (
        [Id] int IDENTITY(1,1) NOT NULL CONSTRAINT PK_ChatMessage PRIMARY KEY,
        [SenderId] int NOT NULL,
        [ReceiverId] int NOT NULL,
        [BookingId] int NULL,
        [Content] nvarchar(2000) NOT NULL,
        [IsRead] bit NOT NULL CONSTRAINT DF_ChatMessage_IsRead DEFAULT 0,
        [CreatedAt] datetime2 NOT NULL,
        [ReadAt] datetime2 NULL,
        CONSTRAINT FK_ChatMessage_Sender FOREIGN KEY ([SenderId]) REFERENCES [User]([Id]),
        CONSTRAINT FK_ChatMessage_Receiver FOREIGN KEY ([ReceiverId]) REFERENCES [User]([Id]),
        CONSTRAINT FK_ChatMessage_Booking FOREIGN KEY ([BookingId]) REFERENCES [Booking]([Id])
    );
END;
GO
IF OBJECT_ID('AuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE [AuditLog] (
        [Id] int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AuditLog PRIMARY KEY,
        [ActorId] int NULL,
        [Action] nvarchar(100) NOT NULL,
        [TargetTable] nvarchar(100) NULL,
        [TargetId] int NULL,
        [Detail] nvarchar(2000) NULL,
        [CreatedAt] datetime2 NOT NULL
    );
END;
GO
