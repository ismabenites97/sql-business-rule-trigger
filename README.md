# SQL Business Rule: Queue Blocking with Stored Procedure and Trigger

Este repositório demonstra a implementação de uma **regra de negócio em SQL Server**
para bloquear o encaminhamento de solicitações para uma fila temporariamente suspensa.

O objetivo do projeto é mostrar **a evolução da solução**, partindo de uma validação
no fluxo (Stored Procedure) até a implementação correta no nível de dados (Trigger).

> Todos os nomes de tabelas, colunas e filas são **fictícios** e usados apenas
> para fins educacionais e de portfólio.

---

## Contexto do Problema

Em um sistema de atendimento fictício, os usuários podem:

- Criar comentários em uma solicitação
- Inserir uma ou mais filas para encaminhamento
- Executar uma ação de encaminhamento posteriormente

Uma fila específica (`QUEUE_X`) foi **temporariamente suspensa** e **não deveria ser utilizada**.

### Problema identificado

Mesmo com validações no momento do encaminhamento, o sistema permitia que:
- A fila suspensa fosse **inserida junto com outras filas**
- O bloqueio só ocorresse **depois**, no botão de encaminhar

Isso gerava inconsistência de dados e comportamentos inesperados.

---

## 🛠️ Primeira abordagem: Stored Procedure (validação no fluxo)

📄 Arquivo: `sp_blocked_queue_on_comment_routing.sql`

A primeira tentativa de solução foi implementar a validação na **Stored Procedure**
responsável pelo encaminhamento do comentário.

### O que essa abordagem fazia

- Verificava se a fila suspensa estava associada ao comentário
- Bloqueava a execução do encaminhamento
- Exibia uma mensagem de erro ao usuário

```sql
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
