import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:paises/models/country_model.dart';
import 'package:paises/services/pais_service.dart';
import 'package:flutter/material.dart';
import 'country_list_screen_test.mocks.dart';
import 'package:paises/country_list_screen.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:paises/screens/country_detail_screen.dart';

@GenerateMocks([PaisService])
void main() {
  late MockPaisService mockPaisService;

  setUp(() {
    // Cria uma nova instância do mock antes de cada teste
    mockPaisService = MockPaisService();
  });

  /// Cenário 01 - Listagem bem-sucedida
  /// Testa se a lista de países é retornada e os dados estão corretos
  test('Cenário 01 – Listagem bem-sucedida', () async {
    final countries = [
      Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 21000000,
        region: 'America Latina',
        flag: 'https://flagcdn.com/w320/br.png',
        subregion: 'America do Sul'
      ),
    ];

    // Configura o mock para retornar a lista de países criada acima
    when(mockPaisService.listarPaises()).thenAnswer((_) async => countries);

    // Chama o método mockado para obter os países
    final result = await mockPaisService.listarPaises();

    // Verifica se a lista não está vazia e os dados do primeiro país estão corretos
    expect(result.isNotEmpty, true);
    expect(result.first.name, 'Brasil');
    expect(result.first.capital, 'Brasília');
    expect(result.first.flag, 'https://flagcdn.com/w320/br.png');
  });

  /// Cenário 02 - Erro na requisição de países
  /// Testa se uma exceção é lançada quando ocorre um erro na requisição
  test('Cenário 02 – Erro na requisição de países lança exceção', () async {
    // Configura o mock para lançar uma exceção
    when(mockPaisService.listarPaises()).thenThrow(Exception('Erro ao buscar países'));

    // Verifica se o método realmente lança uma exceção
    expect(() async => await mockPaisService.listarPaises(), throwsException);
  });

  /// Cenário 03 - Busca de país por nome com resultado
  /// Testa se ao buscar por um país existente, ele é retornado corretamente
  test('Cenário 03 – Busca de país por nome com resultado', () async {
    final country = Country(
      name: 'Brasil',
      capital: 'Brasília',
      population: 213000000,
      region: 'America Latina',
      flag: 'https://flagcdn.com/w320/br.png',
      subregion: 'America do Sul'
    );

    // Configura o mock para retornar o país quando buscado pelo nome
    when(mockPaisService.buscarPaisPorNome('Brasil')).thenAnswer((_) async => country);

    // Busca o país pelo nome
    final result = await mockPaisService.buscarPaisPorNome('Brasil');

    // Verifica se o país retornado não é nulo e seus dados estão corretos
    expect(result, isNotNull);
    expect(result!.name, 'Brasil');
    expect(result.capital, 'Brasília');
    expect(result.population, 213000000);
    expect(result.flag, 'https://flagcdn.com/w320/br.png');
  });

  /// Cenário 04 - Busca de país por nome com resultado vazio
  /// Testa se a busca por um país inexistente retorna null
  test('Cenário 04 – Busca de país por nome com resultado vazio', () async {
    // Configura o mock para retornar null ao buscar um país inexistente
    when(mockPaisService.buscarPaisPorNome('PaísInexistente')).thenAnswer((_) async => null);

    // Realiza a busca pelo país inexistente
    final result = await mockPaisService.buscarPaisPorNome('PaísInexistente');

    // Verifica se o resultado é realmente null
    expect(result, isNull);
  });

  /// Cenário 05 - País com dados incompletos
  /// Testa se o país retornado pode ter dados vazios, como capital e bandeira
  test('Cenário 05 – País com dados incompletos', () async {
    final incompleteCountry = Country(
      name: 'Brasil',
      capital: '',
      population: 21000000,
      region: 'America Latina',
      flag: '',
      subregion: 'America do Sul'
    );

    // Configura o mock para retornar um país com dados incompletos
    when(mockPaisService.buscarPaisPorNome('PaísSemCapital')).thenAnswer((_) async => incompleteCountry);

    // Busca o país com dados incompletos
    final result = await mockPaisService.buscarPaisPorNome('PaísSemCapital');

    // Verifica se o país não é nulo e os campos incompletos estão vazios como esperado
    expect(result, isNotNull);
    expect(result!.name, 'Brasil');
    expect(result.capital, isEmpty);
    expect(result.flag, isEmpty);
  });

  /// Cenário 06 - Verificar chamada ao método listarPaises()
  /// Testa se o método listarPaises() é chamado exatamente uma vez
  test('Cenário 06 – Verificar chamada ao método listarPaises()', () async {
    // Configura o mock para retornar uma lista vazia
    when(mockPaisService.listarPaises()).thenAnswer((_) async => []);

    // Chama o método listarPaises()
    await mockPaisService.listarPaises();

    // Verifica se o método foi chamado uma vez
    verify(mockPaisService.listarPaises()).called(1);
  });

  /// Cenário 07 - Simular lentidão da API e verificar loading na tela
  testWidgets('Simular lentidão da API e verificar loading', (WidgetTester tester) async {
    // Configura o mock para demorar 2 segundos antes de retornar a lista de países
    when(mockPaisService.listarPaises()).thenAnswer(
      (_) => Future.delayed(const Duration(seconds: 2), () => [
        Country(
          name: 'Brasil',
          capital: 'Brasília',
          population: 21000000,
          region: 'America Latina',
          flag: 'https://flagcdn.com/w320/br.png',
          subregion: 'America do Sul',
        ),
      ]),
    );

    // Usa o mock para simular carregamento das imagens para evitar erros
    await mockNetworkImagesFor(() async {
      // Monta o widget da lista de países
      await tester.pumpWidget(
        MaterialApp(home: CountryListScreen(paisService: mockPaisService)),
      );

      // Verifica se o indicador de carregamento está visível no início
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Avança o tempo em 1 segundo e verifica se o loading ainda aparece
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Avança o tempo em mais 2 segundos para completar o carregamento
      await tester.pump(const Duration(seconds: 2));

      // Verifica se o loading desapareceu e o nome do país apareceu na tela
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Brasil'), findsOneWidget);
    });
  });

  /// Cenário 08 - Verificar múltiplas chamadas ao método buscarPaisPorNome com nomes diferentes
  test('Verificar múltiplas chamadas ao mesmo método com parâmetros diferentes', () async {
    final countryA = Country(
      name: 'Brasil',
      capital: 'Brasília',
      population: 213000000,
      region: 'América Latina',
      flag: 'https://flagcdn.com/w320/br.png',
      subregion: 'América do Sul',
    );

    final countryB = Country(
      name: 'Argentina',
      capital: 'Buenos Aires',
      population: 45000000,
      region: 'América Latina',
      flag: 'https://flagcdn.com/w320/ar.png',
      subregion: 'América do Sul',
    );

    // Configura o mock para retornar os países conforme o nome buscado
    when(mockPaisService.buscarPaisPorNome('Brasil')).thenAnswer((_) async => countryA);
    when(mockPaisService.buscarPaisPorNome('Argentina')).thenAnswer((_) async => countryB);

    // Chama o método buscarPaisPorNome para os dois países
    await mockPaisService.buscarPaisPorNome('Brasil');
    await mockPaisService.buscarPaisPorNome('Argentina');

    // Verifica se cada método foi chamado uma vez com os respectivos parâmetros
    verify(mockPaisService.buscarPaisPorNome('Brasil')).called(1);
    verify(mockPaisService.buscarPaisPorNome('Argentina')).called(1);
  });

  /// Cenário 09 - Filtrar países por continente e população
  /// Testa se a lista pode ser filtrada corretamente por região e população
  test('Filtrar países por continente e população', () async {
    final countries = [
      Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 210000000,
        region: 'America Latina',
        flag: 'https://flagcdn.com/w320/br.png',
        subregion: 'America do Sul',
      ),
      Country(
        name: 'Canadá',
        capital: 'Ottawa',
        population: 38000000,
        region: 'América do Norte',
        flag: 'https://flagcdn.com/w320/ca.png',
        subregion: 'América do Norte',
      ),
      Country(
        name: 'Japão',
        capital: 'Tóquio',
        population: 125000000,
        region: 'Ásia',
        flag: 'https://flagcdn.com/w320/jp.png',
        subregion: 'Ásia Oriental',
      ),
    ];

    // Configura o mock para retornar todos os países da lista
    when(mockPaisService.listarPaises()).thenAnswer((_) async => countries);

    // Obtém a lista completa
    final result = await mockPaisService.listarPaises();

    // Filtra os países da Ásia e verifica se só o Japão está na lista
    final asiaCountries = result.where((c) => c.region == 'Ásia').toList();
    expect(asiaCountries.length, 1);
    expect(asiaCountries.first.name, 'Japão');

    // Filtra os países com população maior que 50 milhões e verifica os resultados
    final bigPopulation = result.where((c) => c.population > 50000000).toList();
    expect(bigPopulation.length, 2);
    expect(bigPopulation.any((c) => c.name == 'Brasil'), true);
    expect(bigPopulation.any((c) => c.name == 'Japão'), true);

    // Filtra os países que são da Ásia e têm população maior que 50 milhões
    final asiaBigPop = result.where((c) => c.region == 'Ásia' && c.population > 50000000).toList();
    expect(asiaBigPop.length, 1);
    expect(asiaBigPop.first.name, 'Japão');
  });


// a partir desse trecho seguem os testes de widgets: 
 /// Cenário 10 - Verificar se o nome do país é exibido no widget da lista
  testWidgets('Cenário 01 – Verifica se o nome do país é exibido no widget', (WidgetTester tester) async {
    final countries = [
      Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 210000000,
        region: 'America Latina',
        flag: 'https://flagcdn.com/w320/br.png',
        subregion: 'America do Sul',
      ),
    ];

    // Configura o mock para retornar a lista com um país
    when(mockPaisService.listarPaises()).thenAnswer((_) async => countries);

    // Usa o mock para simular o carregamento das imagens das bandeiras
    await mockNetworkImagesFor(() async {
      // Monta o widget da lista de países
      await tester.pumpWidget(
        MaterialApp(
          home: CountryListScreen(paisService: mockPaisService),
        ),
      );
      // Aguarda todos os frames carregarem
      await tester.pumpAndSettle();
    });

    // Verifica se o nome do país aparece na tela
    expect(find.text('Brasil'), findsOneWidget);
  });

  /// Cenário 11 - Verificar se ao clicar no país, os detalhes são exibidos corretamente
  testWidgets('Cenário 02 – Verificar se ao clicar em um país os dados são abertos', (WidgetTester tester) async {
    final countries = [
      Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 210000000,
        region: 'America Latina',
        flag: 'https://flagcdn.com/w320/br.png',
        subregion: 'America do Sul',
      ),
    ];

    // Configura o mock para retornar a lista de países
    when(mockPaisService.listarPaises()).thenAnswer((_) async => countries);

    await mockNetworkImagesFor(() async {
      // Monta o widget da lista
      await tester.pumpWidget(
        MaterialApp(
          home: CountryListScreen(paisService: mockPaisService),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica se o nome do país está visível na lista
      expect(find.text('Brasil'), findsOneWidget);

      // Simula o clique no nome do país
      await tester.tap(find.text('Brasil'));
      await tester.pumpAndSettle();

      // Verifica se a tela de detalhes abriu mostrando as informações corretas
      expect(find.text('População'), findsOneWidget);
      expect(find.text('210000000'), findsOneWidget);

      expect(find.text('Capital'), findsOneWidget);
      expect(find.text('Brasília'), findsOneWidget);

      expect(find.text('Região'), findsOneWidget);
      expect(find.text('America Latina'), findsOneWidget);

      expect(find.text('Sub-região'), findsOneWidget);
      expect(find.text('America do Sul'), findsOneWidget);
    });
  });

  /// Cenário 12 - Verificar se a imagem da bandeira é carregada no widget de detalhes
  testWidgets('Cenário 03 – Verificar se um componente de imagem é carregado com a bandeira', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final country = Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 210000000,
        region: 'Americas',
        subregion: 'South America',
        flag: 'https://flagcdn.com/w320/br.png'
      );

      // Monta o widget da tela de detalhes do país
      await tester.pumpWidget(
        MaterialApp(
          home: CountryDetailScreen(country: country),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica se alguma imagem (como a bandeira) está sendo exibida
      expect(find.byType(Image), findsWidgets);
    });
  });
}
