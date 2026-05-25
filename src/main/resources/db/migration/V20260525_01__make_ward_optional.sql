-- Make Ward optional in Hotel table
IF OBJECT_ID('FK_Hotel_Ward', 'F') IS NOT NULL
    ALTER TABLE [Hotel] DROP CONSTRAINT [FK_Hotel_Ward];

IF COL_LENGTH('Hotel', 'WardId') IS NOT NULL
    ALTER TABLE [Hotel] ALTER COLUMN [WardId] int NULL;

-- Recreate the foreign key if it was dropped
IF OBJECT_ID('FK_Hotel_Ward', 'F') IS NULL
    ALTER TABLE [Hotel] ADD CONSTRAINT [FK_Hotel_Ward] FOREIGN KEY ([WardId]) REFERENCES [Ward]([Id]);
GO
