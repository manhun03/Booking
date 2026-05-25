SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('[User]', 'Username') IS NULL
BEGIN
    ALTER TABLE [User] ADD [Username] nvarchar(20) NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_User_Username' AND object_id = OBJECT_ID('[User]'))
BEGIN
    CREATE UNIQUE INDEX IX_User_Username ON [User]([Username]) WHERE [Username] IS NOT NULL;
END;
