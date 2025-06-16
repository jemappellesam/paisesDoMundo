
# 🌍 App Flutter - Lista de Países do Mundo

O intuito do aplicativo é exibir uma lista de países consumindo dados de uma API pública. Ao selecionar um país, o usuário é direcionado para uma tela com detalhes como bandeira, capital, população, região e sub-região.

## 📱 Funcionalidades

- Listagem de países com nome, capital e bandeira.
- Tela de detalhes com informações expandidas.
- Carregamento assíncrono de dados.
- Tratamento de estados de carregamento e erro.
- Interface limpa e responsiva com uso de `SliverAppBar`.

## 🧱 Estrutura do Projeto

```
lib/
├── models/
│   └── country_model.dart         # Modelo de dados do país
├── services/
│   └── pais_service.dart          # Serviço de acesso à API
├── screens/
│   ├── country_list_screen.dart   # Tela principal com lista de países
│   └── country_detail_screen.dart # Tela com os detalhes do país
```

## 🚀 Como Executar

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/seu-repositorio.git
   cd seu-repositorio
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Execute o app:**
   ```bash
   flutter run
   ```

## 📡 API Utilizada

O app consome dados da seguinte API pública:

```
https://restcountries.com
```

Essa API fornece nome, capital, população, região, sub-região e URL da bandeira de cada país.


## 🧪 Testes

Os testes podem ser adicionados utilizando o `flutter_test` e o `mockito` para simular respostas da API.

## Exemplo de funcionamento do app

Tela inicial com listagem de países:
![tela inicial](https://github.com/user-attachments/assets/ddede9b6-e845-495f-9868-3db711c19ae7)

Tela de detalhes após clicar em uma país da lista: 
![tela de detalhes](https://github.com/user-attachments/assets/3e74adcb-273a-4ddb-bbf8-5da0cc48f3bc)

