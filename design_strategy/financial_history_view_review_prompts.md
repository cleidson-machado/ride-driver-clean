### Primeiro prompt para criar outro prompt - afim de organizar melhor os códigos e afins
Você vai ser um especialista front end em Flutter / Dart: "UI/UX sênior Flutter com foco absoluto em Material Design 3 (M3)." e deve ser capaz de analizar criticamente um código .dart de uma view enviada em anexo! para me ajudar a construir um prompt para agente de IA refatorar esse código de forma pragmática para deixar o mesmo, com as mesmas funcionalidades e estilo visual, mas com os widgets e afins que compõe a view em .dart separados ( atenção criar .dart separados para facilitar o entendimento e manutenção, apenas onde e se fizer sentido, NÃO QUERO E NEM PRECISO, transformar uma solução complexa que foi necessária para a construção dessa view em algo ainda complexo, mas agora espalhado ). O projeto usa DDD Tático e essa view faz parte da Feature "financial_history", a "financial_history" é tambem o nome da pasta onde esse .dart, em anexo, está criado no projeto. Se nesessário podemos criar sub pastas dentro da pasta "financial_history". Me envia esse prompt de forma resumida, sem código e em texto puro dentro de uma caixa de exibição de código, logo abaixo. No texto do prompt não precisa detalhar tudo, explique no prompt em linhas gerais os pontos do código onde o agente deve atuar e ou analizar, ou seja, deixa o agente no projeto tomar as desiões afins a partir das suas obsevações.  Obs: seja enfático no prompt para não remover os comentários atuais de forma abupta, mas sim portar ou refazer os mesmos para serem ainda mais úteis ao programador humano, mas sem exageiros na quantidade de texto dos comentários afins.

#### CRIADO DERIVADO DO PROMPT ACIMA EM: 20-08-2026
Contexto: Projeto Flutter com DDD Tático. A feature "financial_history" vive na pasta lib/.../financial_history, que já contém financial_history_view.dart, controller/ e data/. A view é um formulário M3 de report/passeio, funcional e com visual aprovado.

Objetivo: Refatorar APENAS a organização do arquivo financial_history_view.dart, extraindo widgets privados para arquivos .dart separados, mantendo 100% das funcionalidades, comportamento e estilo visual atuais. Nada de redesign, nada de mudar tema, espaçamentos, textos ou fluxo. Não alterar controller/ nem data/.

Diretrizes:

1. Criar subpastas dentro de financial_history apenas onde fizer sentido (ex.: presentation/widgets ou SIMPLESMENTE widgets/), agrupando por afinidade — sugestões de análise: header + status pill; campos de formulário reutilizáveis (_FieldSlot, _DateField, _StepperField, _BinaryField); grade superior + coluna de lucro (_TopDataGrid, _ProfitColumn); seção de plataformas (carrossel, cards, dots indicator); linha de opções rápidas; campo de notas; botões de rodapé (avaliar unificar os 5 botões quase idênticos — _SaveButton, _FuelPaymentButton, _AddImagesButton, _ExtraExpensesButton, _DeleteRideReportButton — em um único componente parametrizável, SOMENTE se isso simplificar sem perder clareza); seção de legenda de termos.

2. Pragmatismo: extraia somente o que melhora leitura e manutenção. Widgets pequenos e fortemente acoplados a um único pai podem permanecer juntos no mesmo arquivo do pai. NÃO transformar a solução DA VIEW ATUAL ( QUE JÁ BEM COMPLEXA) em complexidade espalhada em vários .dart — ou seja, menos arquivos coesos é melhor que muitos arquivos triviais.

3. A view principal deve ficar enxuta: estado do formulário, handlers, diálogos (_promptNumber, confirmação de exclusão — avaliar mover diálogos para arquivo próprio se ficar mais claro) e composição do layout. Manter a "ponte temporária" _syncControllerFromState como está, pois será substituída em etapa futura.

4. Ao extrair, tornar públicos apenas os widgets que precisarem ser importados; manter privados os auxiliares internos de cada arquivo.

5. COMENTÁRIOS — ponto crítico: NÃO remover os comentários existentes de forma abrupta. Porte cada comentário junto com o código extraído e, quando fizer sentido, reescreva-o para ficar mais útil ao programador humano (o que o widget faz, por que existe, decisões de design), mas sem exagerar no volume de texto. Comentários de seção/marcadores devem ser adaptados à nova estrutura, não descartados.
6. Não introduzir dependências novas, gerência de estado nova ou abstrações especulativas. Sem quebra de imports no restante do projeto.

Entrega: nova estrutura de pastas/arquivos, código compilando, comportamento idêntico, e um breve resumo das decisões de extração tomadas (o que extraiu, o que manteve junto e por quê).

### OUTRO ITEM A MÃO PROMPT MANUAL
Vou enviar em anexo um print e dois .dart e preciso que me ajude a excrever um prompt para agente de IA Identificar e refatorar o código, segundo as seguintes premissas: 1 - As classes e os .dart dentro da pasta da feature "financial_history" devem: se for .dart começar com: "financial_history_{ALGUMA_COISA}" se nos códigos afins as classes começam com: "FinancialHistory{ALGUMA_COISA}". Portando o código em anexo relativo a "RideReport" está com a nomenclatura errada, nesse sentido. a Unica exceção atual é para os .dart e afins que estão na pasta: "lib/features/financial_history/widgets/*.*"... os aquivos .dart enviados em anexo aqui estão na pasta: "lib/features/financial_history/*.*". 2 - A feature "financial_history" deve possuir somente uma classe de entidade. e atualmente temos duas delas (vide .dart em anexo). 3 - O projeto é uma POC que ainda salva em banco local do SQLite e afins, nesse sentido é necessário remover código desnecessário e duplicado e manter o padrão de nomenclatura de que preciso. Me envia esse prompt de forma resumida, sem código e em texto puro dentro de uma caixa de exibição de código, logo abaixo. No texto do prompt não precisa detalhar tudo, explique no prompt em linhas gerais os pontos do código onde o agente deve atuar e ou analizar, ou seja, deixa o agente no projeto tomar as desiões afins a partir das suas obsevações.

#### CRIADO DERIVADO DO PROMPT ACIMA EM: 20-08-2026 B
Refatore a feature financial_history conforme as regras abaixo:

1. Nomeação de arquivos e classes:
   - Todos os arquivos .dart localizados diretamente em lib/features/financial_history/ (excluindo a subpasta widgets) devem ter o prefixo "financial_history_".
   - Todas as classes definidas nesses arquivos devem ter o prefixo "FinancialHistory".
   - Exceção: a pasta widgets/ pode manter sua própria nomenclatura (não exige o prefixo).

2. Unificação das entidades:
   - Atualmente existem duas classes que representam o mesmo conceito: FinancialHistoryModel (entidade de banco) e RideReport (modelo de domínio).
   - Mantenha uma única classe de entidade (classe principal) que será usada tanto para persistência quanto para a lógica de domínio. Decida qual classe permanece (ou crie uma nova) e remova a outra.
   - Ao unificar, absorva todos os campos necessários de ambas as classes (ex.: kmIn/kmStart, kmOut/kmEnd, cashSpent/fuelCost, hodo2Number/kmOdometer, etc.) e preserve os getters e métodos úteis (como totalEarnings e profit, se aplicáveis).
   - A classe resultante deve ser anotada com @Entity (se for a versão de banco) e conter toda a lógica de mapeamento (toMap/fromMap). Se optar por manter um modelo de domínio separado, a instrução é "somente uma classe de entidade", portanto evite duplicidade.

3. Renomeação e adaptação:
   - Renomeie o arquivo ride_report.dart para financial_history.dart (ou outro nome consistente) e a classe RideReport para FinancialHistory (ou FinancialHistoryEntity, mas prefira sem sufixo desnecessário).
   - Renomeie o arquivo ride_report_platform.dart para financial_history_platform.dart e a classe RideReportPlatform para FinancialHistoryPlatform.
   - Atualize todas as referências em controllers, repositórios, views e demais camadas para refletir os novos nomes.

4. Limpeza:
   - Remova código morto, comentários obsoletos e duplicações que surgirem após a unificação.
   - Verifique se os DAOs, repositórios e demais serviços estão ajustados para trabalhar com a entidade unificada.

5. Mantenha a arquitetura atual (controller, repository, domain, widgets) e preserve o comportamento da POC (persistência local com SQLite via Floor).

Analise o código existente (incluindo os arquivos da pasta widgets, se necessário) e realize as alterações de forma coesa, garantindo que a aplicação continue compilando e funcionando.

#### Parte A REPETIR SEMPRE NOS FINAIS DOS PROMPTS AFINS
Me envia esse prompt de forma resumida, sem código e em texto puro dentro de uma caixa de exibição de código, logo abaixo. No texto do prompt não precisa detalhar tudo, explique no prompt em linhas gerais os pontos do código onde o agente deve atuar e ou analizar, ou seja, deixa o agente no projeto tomar as desiões afins a partir das suas obsevações.

#### Parte A REPETIR SEMPRE EM PROMPTS MAIS COMUNS DE REFINAMENTO DE DE PROMPTS HUMANOS MANUAIS
Melhora a logica e afins de composição desse meu prompt para agente de IA abaixo, mantendo a referencia a arquivos ou pastas afins.

#### QUANDO FOI NECESSÁRIO REFATORAR A MODEL FinancialHistory EM: 24-08-2026
Preciso que analize o .dart em ( lib/features/financial_history/domain/financial_history.dart ) e me ajude na refatoração pois essa model é a única no projeto que não tem o sufixo "model" como as demais seja no nome da classe que hoje é somente "FinancialHistory", seja no nome do seu respectivo .dart que hoje é apenas: "financial_history.dart". Usa o padrão de nomes das outra models como exemplo, tanto no nome do .dart como também no nome da classe e faça as refatorações a ajustes afins. Obs: esse projeto continua sendo uma POC que persiste dados em SQLite Local. Depois dos ajustes da refatoração acima verifica se a persistencia está em tese funcionando adequadamente e afins.

#### CRIADO DERIVADO DO PROMPT ACIMA EM: 24-08-2026
Contexto: Projeto Flutter (POC) com persistência local em SQLite.

Tarefa: Refatorar a model localizada em lib/features/financial_history/domain/financial_history.dart, que é a única do projeto fora do padrão de nomenclatura das demais models (falta o sufixo "Model").

Passos:
1. Analisar as outras models do projeto e identificar o padrão de nomenclatura usado (nome da classe e do arquivo).
2. Renomear a classe FinancialHistory para FinancialHistoryModel (ou conforme o padrão identificado).
3. Renomear o arquivo financial_history.dart para financial_history_model.dart (ou conforme o padrão).
4. Atualizar todas as referências no projeto: imports, instâncias, tipos, repositórios, DAOs e demais usos da classe/arquivo.
5. Após a refatoração, validar que a persistência em SQLite continua funcionando corretamente (mapeamentos toMap/fromMap, nome de tabela, queries e afins), reportando qualquer inconsistência encontrada.

Restrição: Não alterar lógica de negócio — apenas refatoração de nomenclatura e ajustes decorrentes dela.