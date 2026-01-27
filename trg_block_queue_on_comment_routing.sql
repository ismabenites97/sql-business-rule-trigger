CREATE OR ALTER TRIGGER trg_block_queue_on_comment_routing
ON COMMENT_QUEUE_ROUTING
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /* 
       Validação baseada no conjunto inserido.
       A tabela lógica INSERTED contém todas as filas
       que o usuário tentou adicionar na aba "Encaminhar".
    */

    -- Verifica se existe alguma fila bloqueada no conjunto inserido
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE QUEUE = 999 -- Fila fictícia temporariamente suspensa
    )
    BEGIN
        /*
           Caso a fila bloqueada seja encontrada,
           a operação inteira é cancelada.
        */
        RAISERROR(
            'A fila "FILA_SUSPENSA_EXEMPLO" está temporariamente indisponível.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
