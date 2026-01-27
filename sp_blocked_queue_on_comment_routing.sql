-- BLOQUEIO DE FILA TEMPORARIAMENTE SUSPENSA
IF EXISTS (
    SELECT 1
    FROM COMMENT_QUEUE_ROUTE
    WHERE REQUEST_ID   = @REQUEST_ID
      AND REQUEST_TYPE = @REQUEST_TYPE
      AND COMMENT_SEQ  = @COMMENT_SEQ
      AND QUEUE_CODE   = 'QUEUE_X'
)
BEGIN
    RAISERROR (
        'Encaminhamento bloqueado: a fila selecionada está temporariamente suspensa.',
        16,
        1
    )
    RETURN
END
