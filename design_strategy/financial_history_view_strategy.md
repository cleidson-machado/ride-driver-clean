# Estrategia de redesign da Financial History View

## Objetivo

Aproximar a tela do wireframe sem abandonar Material 3, mantendo a operacao rapida, a leitura simples e a paleta em verde claro com branco.

## Direcao visual

- Basear toda a tela em um `Scaffold` simples, com fundo claro e blocos bem delimitados.
- Usar o tema global com `ColorScheme.fromSeed()` partindo de um verde claro.
- Deixar as superficies principais em branco ou quase branco e reservar o verde para foco, selecao e CTA.
- Manter tipografia simples, com pouco contraste de tamanhos e pesos mais fortes so em titulos e valores.

## Estrategia por segmentos

1. Cabecalho:
   Mostrar a data principal centralizada e separada por divisor, como no wireframe.
2. Grade superior:
   Dividir em tres areas previsiveis: bloco esquerdo, coluna de lucro e bloco direito.
3. Campos operacionais:
   Transformar cada campo em um bloco unico com borda, evitando a mistura de botoes tonais e cards diferentes.
4. Plataformas base:
   Tratar como uma secao propria, com cards simetricos e informacao centralizada.
5. Controles finais:
   Organizar checks, acao de adicionar plataforma e observacoes como uma sequencia de uso natural.
6. Acao primaria:
   Encerrar com um unico botao forte e largo para salvar ou atualizar.

## Decisoes de UX

- Priorizar leitura vertical e consistencia de alinhamento antes de adicionar ornamentos.
- Em telas compactas, empilhar os segmentos; em telas medias e largas, reconstituir a composicao em tres colunas no topo.
- Manter dados mockados nesta etapa para avaliar apenas forma, hierarquia e operabilidade.
- Preservar alvos de toque largos, especialmente nos steppers e na acao de adicionar plataforma.

## Proximos refinamentos sugeridos

- Validar se os steppers devem continuar como controle principal ou virar campos editaveis com apoio de acao lateral.
- Revisar rotulos em portugues para padronizar acentos e capitalizacao quando a camada funcional estiver definida.
- Se a tela entrar no fluxo principal do app, criar variacoes de estado: vazio, em edicao e concluido.