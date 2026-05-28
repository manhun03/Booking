IF COL_LENGTH('Booking', 'CustomerAddress') IS NULL
BEGIN
    ALTER TABLE [Booking] ADD [CustomerAddress] nvarchar(1000) NULL;
END;
GO
