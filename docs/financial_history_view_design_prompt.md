# Prompt: Descrição do Uso de Design na `FinancialHistoryView`

A **`FinancialHistoryView`** (cadastro/edição de passeio) usa exclusivamente os widgets do **Material Design 3** vindo do `ThemeData` padrão — não há cores, fontes ou temas customizados próprios; tudo deriva de `textTheme` e `colorScheme` do `Theme.of(context)`.

## Layout Estrutural e Alinhamento
- `Scaffold` com `AppBar(centerTitle: true)` — o título (data mockada, `titleMedium` itálico em `onSurfaceVariant`) sempre centralizado.
- Body usa `SafeArea` + `LayoutBuilder` para **responsividade por largura**: `compact` (<600), `medium` (600–840), senão desktop.
- Conteúdo é alinhado **top-center** via `Align` + `ConstrainedBox` (largura máxima de **720px** em medium, **920px** em telas largas).
- Sistema de layout principal é **`Wrap`** (com `spacing 12`, `runSpacing 12`): em telas compactas cada bloco vira `double.infinity` (empilhado verticalmente); em telas maiores fixa-se larguras (320px / 140px / 300px) lado a lado.
- Scroll vertical com `SingleChildScrollView` (padding LTRB 16,16,16,20). Coluna com `crossAxisAlignment.stretch` (campos ocupam toda a largura disponível).

## Campos (TextFields / Inputs)
- **Botões funcionam como campos de entrada**: o campo "Data - Passeio" é um `FilledButton.tonalIcon` (ícone calendário + LabeledField acima). Os campos numéricos ("Kilometragem Saída/Chegada", "Valor Abastecimento", "Hodômetro Trajeto") são `_StepperField` — um `Row` com botão `OutlinedButton` de decremento (ícone `remove`), um botão central `FilledButton.tonal` mostrando o valor (ellipsis), e botão de incremento (`add`), todos de altura fixa **48px**, com `Expanded` (1:2:1) controlando proporção.
- **`SegmentedButton<bool>`** para "Hodômetro 2 - Zerado?" (SIM/NAO, sem ícone selecionado).
- **`CheckboxListTile`** (checks "Com imagens?" e "Concluido?") dentro de um `Card`, com `controlAffinity.leading`, conteúdo verticalmente centralizado — o card com `Wrap` interno.
- Campo **"Anotacoes / Observacoes"**: `TextField` multilinha (4–5 linhas) com `OutlineInputBorder`.

## Botões
- **Botão principal "SALVAR / ATUALIZAR"**: `FilledButton` esticado com `minimumSize` de altura **56px**, texto `titleMedium` peso `w800` em `onPrimary`, centralizado (`textAlign.center`).
- `FloatingActionButton.small` com ícone `add_rounded` para adicionar plataforma.
- Cards de plataforma usam `OutlinedButton` para exibir o nome da plataforma (UBER/BOLT).

## Cores
- Sem paleta própria — usa `colorScheme.outline` (bordas de containers/boxes), `secondaryContainer` (destaque de LUCRO), `onSecondaryContainer` (texto do LUCRO), `onSurfaceVariant` (título do AppBar), `onPrimary` (texto do botão salvar).
- Destaques e "caixas" são containers com `borderRadius` (8–12px) e borda `outline`.

## Fontes / Textos
- Todos os textos usam `textTheme` (título do AppBar: `titleMedium`; labels e títulos de seção: `titleSmall`, peso `w700`/`w800`; corpos: `bodyLarge`; valores destacados: `titleMedium` peso `w700`).
- Texto em **português**, com **acentos omitidos** intencionalmente (ex.: "NAO", "Kilometragem", "Anotacoes", "Concluido", "Hodometro") — padrão recorrente em toda a tela.

## Observações de Design (problemas percebidos vs. planejado)
- Uso de botões no lugar de campos de texto reais (steppers e tonal buttons) para entrada de dados — gera aparência pouco "polida"/distinta do esperado.
- Layout fortemente dependente de `Wrap` com larguras fixas que em alguns breakpoints deixam colunas desalinhadas (bloco de 320px + 140px + 320px pode não encaixar bem em `medium`), causando quebras visuais.
- Mistura de `Card`, `Container` com bordas, e `FilledButton` cria hierarquia visual inconsistente.
