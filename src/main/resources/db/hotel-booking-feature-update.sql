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
