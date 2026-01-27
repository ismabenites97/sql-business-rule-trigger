IF EXISTS (
    SELECT 1
    FROM INSERTED
    WHERE QUEUE_CODE = 'QUEUE_X'
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
