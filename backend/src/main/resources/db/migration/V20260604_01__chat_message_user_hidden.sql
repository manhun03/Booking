IF COL_LENGTH('ChatMessage', 'SenderHidden') IS NULL
BEGIN
    ALTER TABLE ChatMessage ADD SenderHidden bit NOT NULL CONSTRAINT DF_ChatMessage_SenderHidden DEFAULT 0;
END;

IF COL_LENGTH('ChatMessage', 'ReceiverHidden') IS NULL
BEGIN
    ALTER TABLE ChatMessage ADD ReceiverHidden bit NOT NULL CONSTRAINT DF_ChatMessage_ReceiverHidden DEFAULT 0;
END;