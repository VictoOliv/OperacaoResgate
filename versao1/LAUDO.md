# Laudo Técnico — Operação Resgate: Detetives de Bugs (Versão 1)

Estratégia desta versão: correções pontuais, alterando apenas as linhas defeituosas e mantendo a estrutura original do projeto.

Caminho investigado: `main` → `GatePage` → `CentralPage` → `DetalhePage`.

---

## Missão 1 — Fazer o sistema funcionar

### Bug 01 — String quebrada no subtítulo da lista
- **Arquivo:** `lib/pages/central_page.dart` (linhas 81–82)
- **Sintoma:** o projeto não compilava. O analisador acusava `Unterminated string literal` e uma série de erros em cascata nas linhas seguintes.
- **Causa:** a string do subtítulo, delimitada por aspas simples, tinha uma quebra de linha real no meio. Strings de aspas simples não podem atravessar linhas em Dart.
- **Correção:** a quebra de linha foi trocada por `\n` dentro da mesma linha: `'${o.local} • ${...}\nPor ${o.autorNome}'`.
- **Teste:** `flutter analyze` deixou de acusar os erros de sintaxe e a lista passou a exibir local, status e "Por <nome>" em duas linhas.

### Bug 02 — Tela de detalhes aberta sem a ocorrência
- **Arquivo:** `lib/pages/central_page.dart` (linha 86)
- **Sintoma:** depois do Bug 01, o analisador acusava `The named parameter 'ocorrencia' is required`. O app não compilava e, portanto, não era possível abrir os detalhes.
- **Causa:** `DetalhePage()` era criada sem o parâmetro obrigatório `ocorrencia`.
- **Correção:** `DetalhePage(ocorrencia: o)`.
- **Teste:** ao tocar em um item da lista, a tela "Investigação" abre com o título, o local e o autor corretos.

---

## Missão 2 — Cadastro e consulta

### Bug 03 — Validação aceitava campos vazios
- **Arquivo:** `lib/pages/central_page.dart` (linha 26)
- **Sintoma:** era possível registrar uma ocorrência sem objeto ou sem local. O aviso só aparecia quando os dois campos estavam vazios.
- **Causa:** a condição usava `&&` (os dois vazios) em vez de `||` (qualquer um vazio).
- **Correção:** `if (titulo.text.trim().isEmpty || local.text.trim().isEmpty)`.
- **Teste:** registrar só com o objeto e depois só com o local. Nos dois casos aparece "Informe título e local." e nada é gravado.

### Bug 04 — Interruptor "Somente não resolvidos" invertido
- **Arquivo:** `lib/pages/central_page.dart` (linha 68)
- **Sintoma:** ao ligar o interruptor ele continuava desligado, e o filtro não acompanhava o que o usuário escolhia.
- **Causa:** `somenteAbertos = !value` gravava o oposto do valor escolhido.
- **Correção:** `somenteAbertos = value`.
- **Teste:** ligar e desligar o interruptor. A chave acompanha o toque.

### Bug 05 — Filtro mostrava apenas os resolvidos
- **Arquivo:** `lib/pages/central_page.dart` (linha 75)
- **Sintoma:** com "Somente não resolvidos" ativo, a lista exibia justamente os casos resolvidos.
- **Causa:** o filtro era `where((o) => o.resolvido)`.
- **Correção:** `where((o) => !o.resolvido)`.
- **Teste:** com um caso resolvido e outro em aberto, ligar o filtro. Só aparece o caso "Em aberto".

### Bug 06 — Objetos recém-registrados apareciam como "Resolvido"
- **Arquivo:** `lib/models/ocorrencia.dart` (linha 22)
- **Sintoma:** toda ocorrência nova aparecia como "Resolvido", embora no Firestore estivesse `resolvido: false`.
- **Causa:** a leitura negava o valor do banco: `!(d['resolvido'] ...)`.
- **Correção:** `resolvido: d['resolvido'] as bool? ?? false`.
- **Teste:** registrar um objeto. Ele aparece como "Em aberto" e o campo no console do Firestore é `false`.

### Bug 07 — Identificação do dono lida do campo errado
- **Arquivo:** `lib/models/ocorrencia.dart` (linha 21)
- **Sintoma:** o dono de uma ocorrência nunca via o botão "Marcar como resolvido".
- **Causa:** `autorId` era preenchido com `d['autorNome']`, então a comparação com o `uid` do usuário logado sempre falhava.
- **Correção:** `autorId: d['autorId'] as String? ?? ''`.
- **Teste:** só depois do Bug 08 é possível confirmar. O dono passa a ver o botão de status.

### Bug 08 — Responsável gravado com o e-mail no lugar do uid
- **Arquivo:** `lib/services/central_service.dart` (linha 17)
- **Sintoma:** não aparece no terminal. No console do Firestore, o campo `autorId` continha o e-mail do usuário (dado pessoal desnecessário), e a regra de dono nunca batia com o `uid`.
- **Causa:** `'autorId': u.email ?? ''`.
- **Correção:** `'autorId': u.uid`.
- **Teste:** registrar um objeto e conferir no console que `autorId` é o uid (o mesmo de Authentication > Users). Na tela de detalhes, o dono vê o botão de status.

### Bug 09 — Ordem dos registros invertida
- **Arquivo:** `lib/services/central_service.dart` (linha 9)
- **Sintoma:** os registros mais antigos ficavam no topo e o último objeto registrado ia para o fim da lista.
- **Causa:** `orderBy('criadoEm', descending: false)`.
- **Correção:** `orderBy('criadoEm', descending: true)`.
- **Teste:** registrar dois objetos em sequência. O último registrado aparece primeiro.

### Bug 10 — "Marcar como resolvido" não mudava nada
- **Arquivo:** `lib/services/central_service.dart` (linha 25)
- **Sintoma:** só aparece depois dos Bugs 07 e 08. O dono tocava no botão, a tela voltava, mas o status continuava o mesmo.
- **Causa:** o `update` gravava o valor atual (`item.resolvido`) em vez do novo.
- **Correção:** `update({'resolvido': !item.resolvido})`.
- **Teste:** como dono, marcar como resolvido. A lista mostra "Resolvido". Abrir de novo e tocar em "Reabrir": volta para "Em aberto".

---

## Missão 3 — Investigação multiusuário

### Bug 11 — Pistas gravadas no lugar errado
- **Arquivo:** `lib/services/central_service.dart` (linha 30)
- **Sintoma:** não aparece no terminal. Na tela, nenhuma pista aparecia em nenhuma ocorrência. No console, todas eram gravadas em `ocorrencias/pistas/pistas`, misturando as pistas de todos os casos.
- **Causa:** o documento usado era o texto fixo `'pistas'` em vez do id da ocorrência.
- **Correção:** `.doc(ocorrenciaId).collection('pistas')`.
- **Teste:** na conta B, enviar uma pista no caso X. Ela aparece no caso X (nas contas A e B) e não aparece no caso Y.

### Bug 12 — Envio de pista bloqueado e com texto vazio
- **Arquivo:** `lib/pages/detalhe_page.dart` (linhas 21 e 23)
- **Sintoma:** ao digitar uma pista e tocar em enviar, nada acontecia. Se o campo estivesse vazio, tentava enviar.
- **Causa:** a condição estava invertida (`isNotEmpty) return`) e o texto enviado era sempre `''`.
- **Correção:** `if (pista.text.trim().isEmpty) return;` e `service.enviarPista(widget.ocorrencia.id, pista.text)`.
- **Teste:** com o campo vazio, nada é enviado. Com texto, a pista aparece na lista e o campo é limpo.

---

## Ajustes de configuração (não contados como bugs)

| Item | Arquivo | Problema | Ajuste |
|---|---|---|---|
| A | `lib/firebase_options.dart` | arquivo ausente (`Target URI doesn't exist`) | criado com a configuração Web do projeto Firebase |
| B | `pubspec.yaml` | `analysis_options.yaml` usa `flutter_lints`, mas o pacote não estava declarado | `flutter_lints` adicionado em `dev_dependencies` |
| C | `pubspec.yaml` | o `device_preview` usa ícones Cupertino, mas a fonte não estava incluída | `cupertino_icons` adicionado |
| D | `test/widget_test.dart` | teste padrão do contador, importando `package:bugsresolver` e `MyApp`, que não existem | removido (testava uma funcionalidade que não existe no app) |
| E | `firestore.rules` | o projeto não tinha regras | criado (ver abaixo) |

## Regras de segurança (`firestore.rules`)
- Só usuários autenticados leem ocorrências e pistas.
- Ao criar uma ocorrência, `autorId` precisa ser o próprio uid, `resolvido` começa `false` e objeto e local não podem ser vazios.
- Só o dono altera a ocorrência, e somente o campo `resolvido`.
- Ao criar uma pista, `autorId` precisa ser o próprio uid e a mensagem não pode ser vazia.
- Teste de autorização: na conta B, abrir um caso da conta A. O botão de status não aparece. Uma tentativa de alteração fora do app é recusada pelas regras (`permission-denied`).

## Verificação
- `flutter analyze`: nenhum erro ou warning. Restam 4 avisos de estilo (`if` sem chaves) do código original.
- `flutter build web`: compilou com sucesso.
- Teste com duas contas Google em janelas separadas do Chrome (normal e anônima). Print das duas contas vendo a mesma ocorrência: `print_duas_contas.png`.
