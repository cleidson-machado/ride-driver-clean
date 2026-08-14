---
name: ride-driver-flutter-data
description: "Engenharia Flutter/Dart para o app Ride Driver: modelagem SQLite com sqflite, DAOs, migrações incrementais, integração das views com dados reais, métricas financeiras e evolução para Repository/REST com Dio. Use ao implementar persistência, histórico, dashboard, busca, exportação, sincronização ou refatorações de dados neste projeto."
argument-hint: "Descreva a funcionalidade, tela ou mudança de dados do Ride Driver"
user-invocable: true
---

# Ride Driver: Dados e Persistência

## Objetivo

Conduzir mudanças de dados no app Ride Driver do diagnóstico à validação. A resposta deve ser em português e seguir esta ordem, salvo quando a solicitação exigir outra forma:

1. diagnóstico curto;
2. plano em passos;
3. código Dart/SQL pronto para aplicar;
4. migração, quando houver mudança de schema;
5. como testar e validar.

Faça mudanças mínimas e incrementais, preserve APIs públicas quando possível e aponte os arquivos e símbolos alterados.

## Quando usar

- Completar models, `fromMap`/`toMap`, DAOs ou consultas SQL.
- Ligar views a dados reais e remover mocks/TODOs de persistência.
- Implementar salvar, encerrar passeio, plataformas, busca, filtros, agregações, CSV, reset ou métricas.
- Persistir estado que hoje existe apenas na UI.
- Criar entidades filhas 1:N, como abastecimentos e anexos/imagens.
- Introduzir Repository, `LocalRepository`, `RemoteRepository`, DTOs, cache ou sincronização REST.
- Investigar inconsistências de schema, chaves estrangeiras, datas, duplicidades ou compatibilidade de plataforma.

## Contexto e invariantes

- O projeto usa Flutter/Dart com FVM. Execute comandos Flutter/Dart como `fvm flutter ...` e `fvm dart ...`.
- A persistência atual é `sqflite` manual. Não proponha voltar ao `floor_generator`; as anotações Floor permanecem apenas como contrato/documentação, salvo pedido explícito.
- Entidades implementam `BaseModel` com `String id` UUID/TEXT PK e `Map<String, dynamic> toMap()`.
- Datas são `INTEGER` em epoch millis; booleanos são `0/1`; tabelas usam `snake_case` e propriedades Dart `camelCase`.
- FKs devem usar `ON DELETE CASCADE` quando a relação exigir exclusão do filho, e FKs devem ter índices.
- `AppDatabaseBuilder` controla a versão, `PRAGMA foreign_keys = ON`, `onCreate` e migrações via `MigrationAdapter`.
- A regra de lucratividade é central e imutável: giro mínimo diário = combustível + o dobro do combustível + 100 EUR, isto é, `3 * fuelCost + 100`. Centralize-a em uma função/serviço de domínio e não a duplique nas telas.
- O modelo consolidado inclui `financial_history`, `platform`, `financial_history_platform` e `extra_expenses`.
- A UI deve depender do padrão de estado mais simples compatível com o código existente, como `FutureBuilder`, `ValueNotifier` ou `ChangeNotifier`. Não introduza Riverpod, Provider, Bloc ou outro framework sem pedido.

## Procedimento

### 1. Ancorar o diagnóstico

Comece pela tela, símbolo, erro, teste ou comando citado. Leia apenas o caminho local que decide o comportamento:

- model e `toMap`/`fromMap`;
- tabela, builder e migração;
- DAO concreto e consulta;
- view e seu estado;
- teste ou call site próximo.

Formule uma hipótese falsificável sobre a causa e indique uma verificação barata. Se o arquivo apenas encaminhar a chamada, avance um salto para o método que calcula ou muta o dado.

Antes de editar, confirme:

- qual camada é dona da decisão;
- se a mudança altera schema;
- qual teste, análise, compilação ou consulta pode desconfirmar a hipótese.

Se a solicitação for ambígua, faça no máximo duas perguntas objetivas. Caso contrário, declare a premissa simples adotada e prossiga.

### 2. Classificar o trabalho

Escolha um caminho principal:

- **Persistência sem schema:** corrigir model, DAO, consulta ou estado sem alterar versão.
- **Mudança de schema:** adicionar/alterar entidade, coluna, FK ou índice e preparar migração incremental.
- **Integração da UI:** conectar a view ao DAO/repositório, tratar loading/erro/vazio e atualizar após mutações.
- **Métrica/agregação:** preferir `SUM`, `COUNT`, `GROUP BY` e `COALESCE` em SQL; mapear o resultado para um tipo claro.
- **Exportação/reset:** definir formato, transação, confirmação e comportamento de erro antes de alterar a UI.
- **Fronteira REST:** manter a UI contra interfaces de Repository; separar modelos de domínio de DTOs quando a API justificar.

### 3. Implementar com o menor delta

Siga as convenções existentes e altere primeiro o dono do comportamento. Para modelos:

- valide conversões null-safe e tipos numéricos;
- converta datas com epoch millis de modo consistente;
- preserve o `id` ao atualizar;
- use nomes de colunas explícitos.

Para DAOs:

- use `rawQuery`, `insert`, `update` e `delete` com `ConflictAlgorithm.abort`;
- prefira parâmetros posicionais a interpolação de SQL;
- use transação quando uma operação grava entidades relacionadas;
- inclua índices e FKs na definição de schema.

Para UI:

- substitua mocks apenas no fluxo afetado;
- represente loading, erro, vazio e sucesso;
- após salvar/encerrar/excluir, recarregue a fonte de dados;
- evite colocar regra financeira ou SQL dentro da view.

Para Repository/REST:

- defina a interface antes da implementação;
- faça `LocalRepository` preservar o comportamento atual;
- adapte `gen_crud_repository`/Dio em `RemoteRepository`, sem expor Dio à UI;
- explicite seleção local, remoto ou híbrida, erros de rede, idempotência e sincronização.

### 4. Tratar schema e migrações

Qualquer mudança de schema exige todos os itens abaixo:

1. atualizar `onCreate` para instalações novas;
2. criar `Migration(vN, vN+1)` preservando dados existentes;
3. atualizar `version` no builder;
4. criar colunas/tabelas/índices/FKs com nomes e tipos convencionados;
5. considerar rollback ou comportamento parcial em transações quando aplicável;
6. testar banco vazio e banco já existente na versão anterior.

Nunca reescreva a tabela ou apague dados como atalho. Para novas relações 1:N, defina a nulabilidade da FK, o comportamento de órfãos e os índices. Sinalize explicitamente despesas com `financial_history_id IS NULL`.

### 5. Revisar riscos do domínio

Antes de concluir, verifique especialmente:

- divergência entre `kmStart`/`kmEnd` e `kmOdometer`;
- duplicidade de registros para a mesma data;
- `financial_history_platform` com FKs inválidas;
- despesas órfãs ou exclusões em cascata inesperadas;
- soma de valores nulos e contagens duplicadas em joins;
- conversão de EUR e arredondamento;
- compatibilidade de `sqflite` com web;
- exportação com vírgulas, aspas, quebras de linha e dados sensíveis;
- concorrência ao salvar ou encerrar um passeio.

### 6. Validar

Use o teste mais barato que pode falsificar a hipótese e depois amplie apenas se necessário:

- `fvm dart format` nos arquivos alterados;
- `fvm flutter analyze`;
- testes unitários para mapeamento, regra de lucratividade e agregações;
- testes de DAO para CRUD, filtros, joins, nulos e cascatas;
- teste de migração da versão anterior para a atual;
- `fvm flutter test`;
- execução em Android/iOS; quando a mudança depender de persistência no navegador,
  verificar separadamente a compatibilidade web de `sqflite` e registrar o risco
  caso o ambiente não ofereça um backend suportado.

Se models/DAOs anotados forem modificados, só rode build_runner se o projeto realmente exigir geração; a regra atual é sqflite manual e o Floor não deve ser reintroduzido como gerador.

## Checklist de conclusão

- A hipótese inicial foi confirmada ou corrigida por uma verificação executável.
- A regra `3 * fuelCost + 100` continua centralizada e coberta.
- Nenhuma view acessa Dio diretamente quando Repository já foi introduzido.
- Toda mudança de schema atualiza `onCreate`, versão e migração incremental.
- Consultas agregadas tratam `NULL`, joins e duplicidades.
- Estados de loading, erro e vazio não quebram o fluxo.
- Foram executados format/analyze e os testes relevantes; falhas preexistentes são separadas das novas.
- A resposta final informa arquivos alterados, comportamento, validação e riscos remanescentes.
