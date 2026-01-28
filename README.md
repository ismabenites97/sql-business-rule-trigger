# SQL Business Rule: Queue Blocking with Stored Procedure and Trigger

---

Este repositório demonstra a implementação de uma **regra de negócio em SQL Server**
para bloquear o encaminhamento de solicitações para uma fila temporariamente.

O objetivo do projeto é mostrar **a evolução da solução**, partindo de uma validação
no fluxo Stored Procedure até a implementação correta de uma Trigger.

## Contexto do Problema

Em um sistema fictício, os usuários podem:

- Criar comentários em uma solicitação
- Inserir uma ou mais filas para encaminhamento
- Executar uma ação de encaminhamento posteriormente

Uma fila específica (`QUEUE_X`) foi **temporariamente suspensa** e **não deveria ser utilizada**.

### Problema identificado

Mesmo com validações no momento do encaminhamento, o sistema permitia que:
- A fila suspensa fosse **inserida junto com outras filas**
- O bloqueio só ocorresse **depois**, no botão de encaminhar

Isso gerava inconsistência de dados e comportamentos inesperados.

## Primeira abordagem: Stored Procedure (validação no fluxo)

📄 Arquivo: `sp_blocked_queue_on_comment_routing.sql`

A primeira tentativa de solução foi implementar a validação na **Stored Procedure**
responsável pelo encaminhamento do comentário.

### O que essa abordagem fazia

- Verificava se a fila suspensa estava associada ao comentário
- Bloqueava a execução do encaminhamento
- Exibia uma mensagem de erro ao usuário

```
IF EXISTS (
    SELECT 1
    FROM COMMENT_QUEUE_ROUTING
    WHERE REQUEST_ID   = @REQUEST_ID
      AND REQUEST_TYPE = @REQUEST_TYPE
      AND COMMENT_SEQ  = @COMMENT_SEQ
      AND QUEUE_CODE   = 'QUEUE_X'
)
BEGIN
    RAISERROR(
        'Encaminhamento bloqueado: a fila selecionada está temporariamente suspensa.',
        16,
        1
    );
    RETURN;
END; 
```

### Limitação da abordagem

Apesar de funcionar no momento do encaminhamento, essa solução **não impedia**
que a fila suspensa fosse inserida previamente na aba de encaminhamento.

Ou seja, a validação ocorria tarde demais no fluxo do processo.

Segunda abordagem: Trigger (validação no momento da inserção)

📄 Arquivo: `trg_block_queue_on_comment_routing.sql`

Diante da limitação da validação na Stored Procedure, foi adotada uma abordagem
mais adequada do ponto de vista de integridade de dados: a criação de uma Trigger
na tabela responsável pelo relacionamento entre encaminhamento e fila.

O objetivo da Trigger é bloquear a operação no momento exato em que a fila é inserida,
impedindo que dados inválidos sejam persistidos no banco.

O que a Trigger resolve

Impede a inserção da fila suspensa logo na aba de encaminhamento

Garante que a regra de negócio seja aplicada independentemente do fluxo da aplicação

Evita que o usuário chegue à etapa de encaminhamento com dados inconsistentes

Centraliza a validação no nível do banco de dados

Exemplo de Trigger implementada:

```
CREATE OR ALTER TRIGGER trg_block_queue_on_comment_routing
ON COMMENT_QUEUE_ROUTING
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE QUEUE = 999 -- Fila fictícia temporariamente suspensa
    )
    BEGIN
        RAISERROR(
            'A fila "FILA_SUSPENSA_EXEMPLO" está temporariamente indisponível.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
```

### Conclusão

Este projeto demonstra a importância de escolher o ponto correto de validação
para regras de negócio críticas.

Embora a validação em Stored Procedures funcione para fluxos específicos,
ela não garante a integridade dos dados quando o problema ocorre antes da ação final.

Ao mover a regra para uma Trigger, o bloqueio passa a acontecer no momento correto,
evitando inconsistências e garantindo que dados inválidos nunca sejam persistidos.

Essa abordagem torna a solução mais robusta, previsível e alinhada com boas práticas
de banco de dados.
