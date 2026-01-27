IF EXISTS (
    SELECT 1
    FROM COMMENT_QUEUE_ROUTING
    WHERE REQUEST_ID   = @REQUEST_ID
      AND REQUEST_TYPE = @REQUEST_TYPE
      AND COMMENT_SEQ  = @COMMENT_SEQ
      AND QUEUE_CODE   = 'QUEUE_X'
)
BEGIN
    RAISERROR (
        'A fila selecionada está temporariamente bloqueada.',
        16,
        1
    );
    RETURN;
END;
