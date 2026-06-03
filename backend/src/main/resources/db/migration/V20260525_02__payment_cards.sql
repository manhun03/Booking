IF OBJECT_ID('PaymentCard', 'U') IS NULL
BEGIN
    CREATE TABLE [PaymentCard] (
        [Id] int IDENTITY(1,1) NOT NULL CONSTRAINT PK_PaymentCard PRIMARY KEY,
        [CustomerId] int NOT NULL,
        [CardHolderName] nvarchar(120) NOT NULL,
        [Brand] nvarchar(40) NOT NULL,
        [Last4] nvarchar(4) NOT NULL,
        [ExpiryMonth] int NOT NULL,
        [ExpiryYear] int NOT NULL,
        [IsDefault] bit NOT NULL CONSTRAINT DF_PaymentCard_IsDefault DEFAULT 0,
        [IsDeleted] bit NOT NULL CONSTRAINT DF_PaymentCard_IsDeleted DEFAULT 0,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT FK_PaymentCard_User FOREIGN KEY ([CustomerId]) REFERENCES [User]([Id])
    );

    CREATE INDEX IX_PaymentCard_CustomerId ON [PaymentCard]([CustomerId]);
END;
GO
