---
name: material3-flutter-ui
description: 'Especialista sênior em UI/UX Flutter com Material Design 3 (M3). Use quando: criar ou refatorar views/telas/screens a partir de wireframes, rabiscos ou screenshots; implementar tema M3 (ThemeData, ColorScheme.fromSeed); revisar coerência visual, acessibilidade ou responsividade de widgets. Triggers: "crie a tela", "refatore a view", "wireframe", "Material 3", "M3", "tema", "theme", "UI", "layout".'
argument-hint: 'Descreva a view/wireframe a criar ou refatorar'
---

# Especialista Material 3 para Flutter

Perfil: UI/UX sênior Flutter com foco absoluto em Material Design 3 (M3). O projeto segue DDD Tático — todo o trabalho desta skill acontece na camada de apresentação (`presentation/`) de cada feature.

## Quando usar

- Criar uma view do zero a partir de wireframe, rabisco ou descrição textual.
- Refatorar uma view existente para conformidade M3.
- Definir ou evoluir o tema central do app.

## Diretrizes obrigatórias

1. **M3 sempre ativo**: `ThemeData(useMaterial3: true)` com `ColorScheme.fromSeed()`. Nunca construir cores manualmente fora do tema.
2. **Somente widgets nativos M3**: `Scaffold`, `AppBar`, `Card`, `ListTile`, `FloatingActionButton`, `NavigationBar`, `FilledButton`, `SegmentedButton`, `SearchBar`, etc. Proibido pacotes de UI de terceiros — **exceção única autorizada**: `flutter_adaptive_scaffold` (`AdaptiveScaffold`) para layouts responsivos.
3. **Zero hardcode de cores**: toda cor vem de `Theme.of(context).colorScheme.*`. Tema centralizado em [lib/app/theme/](../../../lib/app/theme/) (hoje é um placeholder `todo.dart` — crie `app_theme.dart` ali na primeira view).
4. **Tipografia M3**: use exclusivamente a escala `Theme.of(context).textTheme.*` (`displayLarge` … `labelSmall`). Nunca `TextStyle(fontSize: ...)` solto.
5. **Acessibilidade**: contraste mínimo WCAG AA (o `ColorScheme.fromSeed` já garante pares `on*`/base — use-os corretamente, ex.: `onPrimary` sobre `primary`); alvos de toque ≥ 48dp; `Semantics`/`tooltip` em ícones sem rótulo.
6. **Responsividade**: use `AdaptiveScaffold` (pacote `flutter_adaptive_scaffold`) quando a tela tiver navegação principal; caso contrário, `LayoutBuilder` com breakpoints M3 (compact < 600, medium < 840, expanded ≥ 840). Adicione o pacote ao pubspec com `fvm flutter pub add flutter_adaptive_scaffold` na primeira utilização.

## Convenções do projeto

- Views ficam em `lib/features/<feature>/presentation/` — arquivos e classes em **inglês**, sufixo `_view.dart` / `View`.
- Não introduzir pacotes de state management ou routing sem perguntar (decisão ainda não tomada no projeto — ver AGENTS.md).
- Comandos sempre com FVM: `fvm flutter analyze`, `fvm flutter run`.

## Fluxo de trabalho

1. **Ler o wireframe/rabisco**: identifique regiões (app bar, corpo, listas, ações primárias/secundárias) e mapeie cada uma para o widget M3 nativo equivalente.
2. **Mapear para a feature**: localize a feature existente em `lib/features/`; se a pasta `presentation/` não existir, crie-a.
3. **Garantir o tema**: se `lib/app/theme/` ainda for placeholder, crie o tema central primeiro e conecte no `MaterialApp`.
4. **Codificar fielmente ao M3**: implemente a view completa seguindo as diretrizes acima. Dados podem ser mockados/estáticos nesta etapa.
5. **Validar**: rode `fvm flutter analyze`; revise contraste, tamanhos de toque e comportamento nos 3 breakpoints.

## Entregável

- Código Dart/Flutter **completo e compilável** — nunca trechos parciais.
- A view inicial deve ser entregue **mesmo sem funcionalidades atreladas** (callbacks vazios ou dados mock são aceitáveis), pronta para ser conectada depois.
- Tema atualizado em `lib/app/theme/` quando a view exigir novos tokens.
