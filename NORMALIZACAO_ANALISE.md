# Análise de Normalização — histo_financial

Documento de apoio à modelagem relacional (SQLite) da POC. Registra o raciocínio
de normalização aplicado e as oportunidades futuras identificadas.

## ✅ Aplicado: Normalização das plataformas (1FN)

**Problema:** as colunas `VALOR_UBER / UBER_QTD / VALOR_BOLT / BOLT_QTD` eram
*grupos repetidos* (violação da 1ª Forma Normal). Adicionar uma nova plataforma
(ou corridas particulares avulsas via botão **"+ PLATAFORMA"**) exigiria alterar
o schema (novas colunas `VALOR_X / X_QTD`).

**Solução:** extração para catálogo + tabela associativa (1:N):

```
histo_financial (1) ──< histo_financial_plataforma >── (1) plataforma
```

| Tabela | Arquivo | Papel |
|---|---|---|
| `plataforma` | `lib/features/plataforma/plataforma_model.dart` | Catálogo: UBER, BOLT, PARTICULAR, ... |
| `histo_financial_plataforma` | `lib/features/histo_financial/histo_financial_plataforma_model.dart` | Valor e qtd. de corridas de UMA plataforma em UM dia |
| `histo_financial` | `lib/features/histo_financial/histo_financial_model.dart` | Registro diário (sem colunas por plataforma) |

**Constraint recomendada no schema SQLite:**
`UNIQUE(histo_financial_id, plataforma_id)` — evita duas linhas da mesma
plataforma no mesmo dia. FKs com `ON DELETE CASCADE` a partir de
`histo_financial`.

---

## 🔜 Oportunidades futuras (identificadas, NÃO aplicadas)

### 1. `nome_dia` é dependência transitiva (viola 3FN)
`NOME_DIA` (SÁBADO, DOMINGO...) é 100% derivável de `DATA`.
- **Proposta:** remover a coluna e calcular na apresentação
  (`DateFormat.EEEE('pt_PT')` via `intl`).
- **Risco de manter:** inconsistência (data diz quarta, coluna diz TERÇA).

### 2. `km_rodado_calc` é coluna derivada (viola 3FN)
`KM_RODADO_CALC = KM_ENTRADA - KM_SAIDA`.
- **Proposta:** remover e calcular como getter na model, ou usar
  *generated column* do SQLite (`GENERATED ALWAYS AS`).
- **Observação:** hoje na planilha ele às vezes difere do `KM_HODOMETRO` —
  manter ambos os *inputs* (`km_saida`, `km_entrada`, `km_hodometro`) e derivar
  o cálculo.

### 3. `num_passeio` mistura semânticas
Valores como `"001"` e `"NONE"` misturam número sequencial com "flag de não
trabalhado".
- **Proposta:** tornar `num_passeio` `INTEGER NULL` (NULL = não trabalhou) ou
  criar coluna `status_dia` (TRABALHADO / FOLGA / OFICINA / ...) — hoje esse
  status vive escondido no texto de `ANOTAÇÃO`.

### 4. Abastecimentos como entidade própria (1:N)
A tela prevê "Valor - ABASTECIMENTO" e a anotação "USANDO ABASTECIMENTO DO DIA /
PASSEIO ANTERIOR" mostra que um abastecimento pode servir a mais de um passeio.
- **Proposta:** tabela `abastecimento` (id, histo_financial_id, valor, litros,
  preco_litro, posto, data_hora). Permite N abastecimentos por dia e métricas de
  consumo (€/km, km/l).

### 5. Anexos / imagens (1:N)
O checkbox "COM IMAGENS?" indica futura associação de comprovantes/prints.
- **Proposta:** tabela `anexo` (id, histo_financial_id, caminho_arquivo, tipo,
  criado_em) em vez de flag booleana.

### 6. Campos de estado da tela ainda não persistidos
A tela exibe "Hodômetro 2 - ZERADO?", "Hodômetro 2 - TRAJETO" e "CONCLUÍDO?".
- **Proposta:** adicionar `hodometro2_zerado INTEGER (0/1)`,
  `hodometro2_trajeto INTEGER` e `concluido INTEGER (0/1)` em
  `histo_financial` quando essas features forem implementadas.

### 7. Valores monetários e precisão
`REAL` (double) pode acumular erro de arredondamento em somatórios.
- **Proposta futura:** persistir em cêntimos (`INTEGER`) e converter na model —
  padrão comum em apps financeiros.

---

## Schema SQLite de referência (estado atual)

```sql
CREATE TABLE plataforma (
  id    TEXT PRIMARY KEY,
  nome  TEXT NOT NULL UNIQUE,
  ativo INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE histo_financial (
  id             TEXT PRIMARY KEY,
  data           TEXT NOT NULL,            -- ISO-8601
  nome_dia       TEXT NOT NULL,            -- candidata a remoção (item 1)
  num_passeio    TEXT NOT NULL,            -- candidata a refactor (item 3)
  valor_gas      REAL NOT NULL,
  km_saida       INTEGER NOT NULL,
  km_entrada     INTEGER NOT NULL,
  km_rodado_calc INTEGER NOT NULL,         -- candidata a coluna gerada (item 2)
  km_hodometro   INTEGER NOT NULL,
  anotacao       TEXT NOT NULL
);

CREATE TABLE histo_financial_plataforma (
  id                 TEXT PRIMARY KEY,
  histo_financial_id TEXT NOT NULL REFERENCES histo_financial(id) ON DELETE CASCADE,
  plataforma_id      TEXT NOT NULL REFERENCES plataforma(id),
  valor_total_dia    REAL NOT NULL,
  corridas_total_dia INTEGER NOT NULL,
  UNIQUE (histo_financial_id, plataforma_id)
);
```
