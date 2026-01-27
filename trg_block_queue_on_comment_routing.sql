CREATE OR ALTER TRIGGER trg_block_queue_on_comment_routing
ON COMMENT_QUEUE_ROUTING
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica se existe alguma fila bloqueada no conjunto inserido
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE QUEUE_CODE = 'QUEUE_X' -- Fila fictícia temporariamente suspensa
    )
    BEGIN
        RAISERROR(
            'A fila "QUEUE_X" está temporariamente indisponível.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
