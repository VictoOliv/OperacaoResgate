# Operação Resgate — Central de Achados

**Atividade 2 — somente a versão 1.**

Login com Google, cadastro de ocorrências, investigação com pistas e controle de resolução.

## Estrutura

- `versao1/`: projeto Flutter completo da versão publicada.

## Configurar Firebase

As configurações locais do projeto original não são publicadas. Copie
`firebase.local.example.json` para `firebase.local.json`, na raiz do repositório,
e preencha os valores da configuração Web do seu próprio projeto Firebase.

O arquivo `firebase.local.json` está no `.gitignore`. A aplicação recebe os valores
por `--dart-define-from-file`; não é necessário alterar o código Dart.
Habilite o Cloud Firestore e use as regras de exemplo em `firestore.rules` para
o ambiente educacional. A publicação deste código não aplica regras no Firebase.

Habilite Authentication com provedor Google e autorize `localhost` nos domínios de autenticação.

Referência: [configuração oficial do Firebase para Flutter](https://firebase.google.com/docs/flutter/setup).

## Executar o Flutter

Instale o Flutter compatível com `versao1/pubspec.yaml` e execute:

```powershell
cd versao1
flutter pub get
flutter run -d chrome --dart-define-from-file=../firebase.local.json
```

## Verificação básica

```powershell
flutter analyze
flutter build web --dart-define-from-file=../firebase.local.json
```

O projeto foi conferido em Flutter Web em 28/10/2026, com análise e abertura básica.
Esta checagem não é uma bateria completa de testes. Builds nativos não foram validados.
A tela de login foi verificada; o fluxo completo de autenticação e as gravações no Firebase não foram executados nesta checagem.
