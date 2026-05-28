DECLARE @FallbackOwnerId int;

SELECT TOP (1) @FallbackOwnerId = u.Id
FROM [User] u
JOIN UserRole ur ON ur.UserId = u.Id
JOIN [Role] r ON r.Id = ur.RoleId
WHERE u.IsDeleted = 0
  AND r.IsActive = 1
  AND r.[Name] = 'Owner'
ORDER BY u.Id;

IF EXISTS (
    SELECT 1
    FROM Hotel h
    WHERE h.OwnerId IS NULL
       OR NOT EXISTS (SELECT 1 FROM [User] u WHERE u.Id = h.OwnerId AND u.IsDeleted = 0)
)
AND @FallbackOwnerId IS NULL
BEGIN
    THROW 51000, 'Cannot require Hotel.OwnerId because no active owner user exists.', 1;
END;

IF @FallbackOwnerId IS NOT NULL
BEGIN
    UPDATE h
    SET OwnerId = @FallbackOwnerId
    FROM Hotel h
    WHERE h.OwnerId IS NULL
       OR NOT EXISTS (SELECT 1 FROM [User] u WHERE u.Id = h.OwnerId AND u.IsDeleted = 0);
END;

IF COL_LENGTH('Hotel', 'OwnerId') IS NOT NULL
BEGIN
    ALTER TABLE Hotel ALTER COLUMN OwnerId int NOT NULL;
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_key_columns fkc
    JOIN sys.objects fk ON fk.object_id = fkc.constraint_object_id
    JOIN sys.tables parent_table ON parent_table.object_id = fkc.parent_object_id
    JOIN sys.columns parent_column
      ON parent_column.object_id = fkc.parent_object_id
     AND parent_column.column_id = fkc.parent_column_id
    JOIN sys.tables referenced_table ON referenced_table.object_id = fkc.referenced_object_id
    JOIN sys.columns referenced_column
      ON referenced_column.object_id = fkc.referenced_object_id
     AND referenced_column.column_id = fkc.referenced_column_id
    WHERE fk.type = 'F'
      AND parent_table.name = 'Hotel'
      AND parent_column.name = 'OwnerId'
      AND referenced_table.name = 'User'
      AND referenced_column.name = 'Id'
)
BEGIN
    ALTER TABLE Hotel
    ADD CONSTRAINT FK_Hotel_Owner
    FOREIGN KEY (OwnerId) REFERENCES [User](Id);
END;
