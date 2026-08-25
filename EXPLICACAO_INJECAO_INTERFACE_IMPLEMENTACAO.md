# Como o projeto "sabe" que deve usar o `FinancialHistoryRepositorySqliteImpl`?

> Explicação sobre a linha:
> `final bool exists = await _storage.getById(report.id) != null;`
> (em `lib/features/financial_history/financial_history_service.dart`)
>
> e por que a `service` chama métodos da interface
> (`lib/features/financial_history/data/financial_history_repository_interface.dart`)
> que **não têm implementação alguma**.

---

## A ideia central (em termos simples)

Pense como trocar um **receptor de TV**. A tomada na parede (contrato/interface) não
conhece a marca da TV. O controle remoto (a `service`) também não conhece a marca.
Só **você**, quando pluga a TV na tomada, decide *qual* marca está usando.

- **Interface** (`FinancialHistoryRepositoryInterface`) = a tomada. Só define "o que dá
  para fazer" (ligar/desligar/canal), mas **não sabe quem usa**.
- **Service** (`FinancialHistoryService`) = o controle remoto. Ele só **aperta botões**
  que existem na tomada.
- **Implementação concreta** (`FinancialHistoryRepositorySqliteImpl`) = a TV (Sony,
  Alienware, qualquer marca). É quem **de verdade** faz o trabalho.

---

## O "segredo": a interface **não** decide, ela só **define o contrato**

A interface `FinancialHistoryRepositoryInterface` não tem corpo (`{}`), só **assinaturas**
de métodos (`getById`, `insert`, ...). Isso é intencional — ela é só uma lista de
**"promessas"**.

O verdadeiro trabalho está na classe `FinancialHistoryRepositorySqliteImpl`, que faz
`implements FinancialHistoryRepositoryInterface` e preenche cada método com **SQL cru**
(abrir o banco, rodar `rawQuery`, etc.).

Então, tecnicamente: **`implements`** força o `SqliteImpl` a ter todos os métodos
prometidos. É a lei do contrato.

```dart
// interface só declara a promessa
abstract class FinancialHistoryRepositoryInterface {
  Future<FinancialHistoryModel?> getById(String id);
}

// impl CUMPRE a promessa — aqui mora o SQL de verdade
class FinancialHistoryRepositorySqliteImpl
    implements FinancialHistoryRepositoryInterface {
  @override
  Future<FinancialHistoryModel?> getById(String id) async {
    // ... rawQuery 'SELECT * FROM financial_history WHERE id = ?' com [id]
  }
}
```

---

## O "onde": o ponto de composição (injeção) que conecta tudo

O projeto sabe **qual** implementação usar porque existe **um único lugar** que instancia
a classe concreta e a "produz" como se fosse a interface. Esse lugar é:

**`lib/features/financial_history/financial_history_injection.dart`**

```dart
void registerFinancialHistoryDependencies(GetIt getIt) {
  // ★ aqui é o ÚNICO ponto que conhece a implementação concreta
  getIt.registerLazySingleton<FinancialHistoryRepositoryInterface>(
    () => FinancialHistoryRepositorySqliteImpl(), // ← TV plugada na tomada
  );
  getIt.registerLazySingleton<FinancialHistoryService>(
    () => FinancialHistoryService(repository: getIt<FinancialHistoryRepositoryInterface>()),
  );
}
```

Repare no que acontece aqui:

1. **Cadastra** a implementação `SqliteImpl` **com o tipo** da interface. Ou seja,
   "resolva `FinancialHistoryRepositoryInterface` → me dê um `SqliteImpl`".
2. Quando alguém pede um `FinancialHistoryService`, ele recebe a interface resolvida do
   `GetIt`.

Ou seja: **a `service` nunca sabe que existe um `SqliteImpl`**. Ela só recebe um objeto
cujo *tipo declarado* é `FinancialHistoryRepositoryInterface`. Em tempo de execução, esse
objeto **é** na verdade o `SqliteImpl` — mas isso é invisível para a `service`.

---

## Addenda técnica: polimorfismo (como o Dart faria "manual")

Sem `GetIt`, a mesma coisa aconteceria com polimorfismo simples:

```dart
// Em algum compositor raiz (ex.: main):
FinancialHistoryRepositoryInterface storage = FinancialHistoryRepositorySqliteImpl();
FinancialHistoryService service = FinancialHistoryService(repository: storage);

service.save(report); // ⇒ chama storage.getById(...) que roda o SQL do SqliteImpl
```

O tipo da variável é `FinancialHistoryRepositoryInterface`, mas o objeto real é
`SqliteImpl`. Quando a `service` chama `_storage.getById(...)`, o Dart usa **late binding**
(despacho virtual) e executa **o método do objeto real**, não o da interface. É exatamente
isso que o `GetIt` automatiza.

---

## Resposta direta à pergunta

> "como o código sabe que deve usar a classe SqliteImpl se a service chama métodos da
> interface que não tem implementação?"

1. **Quem chama é a service**, mas quem **EXECUTA** é sempre a implementação concreta
   (polimorfismo / dynamic dispatch).
2. A interface **não precisa de implementação própria** — ela é só o contrato.
3. Quem faz a ligação interface → impl é o **`financial_history_injection.dart`**,
   registrando `SqliteImpl` sob o tipo da interface no `GetIt`.
4. Doravante, toda vez que alguém resolve `FinancialHistoryRepositoryInterface`, recebe o
   `SqliteImpl` com seu SQL cru.

---

## E se amanhã virar REST?

Você cria um `FinancialHistoryRepositoryRestImpl implements FinancialHistoryRepositoryInterface`
e **muda apenas 1 linha** no `injection.dart`:

```dart
() => FinancialHistoryRepositoryRestImpl(), // trocou só a TV
```

A `service`, o `controller` e a view **nem percebem**, porque nunca importaram o
`SqliteImpl` — só a interface. É esse o ganho: **desacoplamento**. A feature inteira
depende de uma abstração, não de uma tecnologia.

---

## Resumo em uma frase

> **A interface diz *o que* pode ser feito; o `injection.dart` escolhe *quem* faz; e a
> `service` apenas aperta os botões sem se importar com quem está por trás da tomada.** 😊
