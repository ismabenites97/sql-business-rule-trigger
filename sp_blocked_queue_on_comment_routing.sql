IF EXISTS (
    SELECT 1
    FROM INSERTED
    WHERE REQUEST_ID   = @REQUEST_ID
      AND REQUEST_TYPE = @REQUEST_TYPE
      AND COMMENT_SEQ  = @COMMENT_SEQ
      AND QUEUE_CODE   = 'QUEUE_X'
)
BEGIN
    RAISERROR(
        'A fila "QUEUE_X" está temporariamente suspensa.',
        16,
        1
    );

    ROLLBACK TRANSACTION;
    RETURN;
END
