SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('[User]', 'EmailVerified') IS NULL
BEGIN
    ALTER TABLE [User] ADD [EmailVerified] bit NOT NULL CONSTRAINT DF_User_EmailVerified DEFAULT 0;
END;
GO

IF OBJECT_ID('AuthToken', 'U') IS NULL
BEGIN
    CREATE TABLE [AuthToken] (
        [Id] int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AuthToken PRIMARY KEY,
        [UserId] int NOT NULL,
        [Type] nvarchar(50) NOT NULL,
        [Token] nvarchar(255) NOT NULL,
        [ExpiresAt] datetime2 NOT NULL,
        [UsedAt] datetime2 NULL,
        [CreatedAt] datetime2 NOT NULL,
        CONSTRAINT FK_AuthToken_User FOREIGN KEY ([UserId]) REFERENCES [User]([Id])
    );

    CREATE UNIQUE INDEX IX_AuthToken_Token ON [AuthToken]([Token]);
    CREATE INDEX IX_AuthToken_UserId_Type ON [AuthToken]([UserId], [Type]);
END;
