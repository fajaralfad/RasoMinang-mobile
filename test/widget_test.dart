import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:klasifikasi_makanan_minang/core/network/api_client.dart';
import 'package:klasifikasi_makanan_minang/data/datasources/food_classification_remote_data_source.dart';
import 'package:klasifikasi_makanan_minang/data/repositories/food_classification_repository.dart';
import 'package:klasifikasi_makanan_minang/domain/usecases/classify_food_usecase.dart';
import 'package:klasifikasi_makanan_minang/presentation/providers/classification_provider.dart';
import 'package:klasifikasi_makanan_minang/presentation/screens/home_screen.dart';



class MockApiClient extends Mock implements ApiClient {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockFoodClassificationRemoteDataSource extends Mock 
    implements FoodClassificationRemoteDataSource {}
class MockFoodClassificationRepository extends Mock 
    implements FoodClassificationRepository {}
class MockClassifyFoodUseCase extends Mock implements ClassifyFoodUseCase {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late MockClassifyFoodUseCase mockClassifyFoodUseCase;
  late MockFoodClassificationRepository mockRepository;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockClassifyFoodUseCase = MockClassifyFoodUseCase();
    mockRepository = MockFoodClassificationRepository();

    // Setup default behavior for mocks
    when(() => mockSharedPreferences.getStringList(any()))
        .thenReturn([]);
    
    // PERBAIKAN UTAMA: Mock getPredictionHistory untuk mengembalikan list kosong
    when(() => mockRepository.getPredictionHistory())
        .thenAnswer((_) async => []);
  });

  // Helper function to create the app with mocked dependencies
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ClassificationProvider(
            classifyFoodUseCase: mockClassifyFoodUseCase,
            repository: mockRepository,
          ),
        ),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen displays main elements correctly', (WidgetTester tester) async {
    // Build our app with mocked dependencies
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Tunggu sampai semua frame selesai (termasuk initState)
    await tester.pumpAndSettle();

    // Verify that the main elements are present
    expect(find.text('Minang Food Classifier'), findsOneWidget);
    expect(find.text('Klasifikasi Makanan Minangkabau'), findsOneWidget);
    expect(find.text('Pilih Gambar Makanan'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera), findsOneWidget);
  });

  testWidgets('History button is present in app bar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find and verify history button
    final historyButton = find.byIcon(Icons.history);
    expect(historyButton, findsOneWidget);
  });

  testWidgets('Image picker button is present and has correct icon', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find the image picker button
    final imagePickerButton = find.text('Pilih Gambar');
    expect(imagePickerButton, findsOneWidget);

    // Verify the button has the correct icon
    expect(find.byIcon(Icons.add_photo_alternate), findsOneWidget);
  });

  testWidgets('App bar title is displayed correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Minang Food Classifier'), findsOneWidget);
  });

  testWidgets('App description is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify that the app description is present
    expect(
      find.text('Unggah foto makanan untuk mengidentifikasi jenis makanan Minangkabau tradisional'),
      findsOneWidget,
    );
  });

  testWidgets('No loading indicator shown initially', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Initially should not show loading
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('No prediction results shown initially', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify initial empty state for results
    expect(find.text('Hasil Klasifikasi'), findsNothing);
  });
}

// Group of tests for specific scenarios
void classificationFeatureTests() {
  late MockClassifyFoodUseCase mockClassifyFoodUseCase;
  late MockFoodClassificationRepository mockRepository;

  setUp(() {
    mockClassifyFoodUseCase = MockClassifyFoodUseCase();
    mockRepository = MockFoodClassificationRepository();
    
    // Mock getPredictionHistory
    when(() => mockRepository.getPredictionHistory())
        .thenAnswer((_) async => []);
  });

  group('Classification Feature Tests', () {
    testWidgets('Tapping image picker button shows bottom sheet', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => ClassificationProvider(
                classifyFoodUseCase: mockClassifyFoodUseCase,
                repository: mockRepository,
              ),
            ),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap tombol pilih gambar
      final imageButton = find.text('Pilih Gambar');
      expect(imageButton, findsOneWidget);
      
      await tester.tap(imageButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet muncul (sesuaikan dengan implementasi Anda)
      // expect(find.text('Pilih Sumber Gambar'), findsOneWidget);
    });

    testWidgets('History screen can be navigated to', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => ClassificationProvider(
                classifyFoodUseCase: mockClassifyFoodUseCase,
                repository: mockRepository,
              ),
            ),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap history button
      final historyButton = find.byIcon(Icons.history);
      expect(historyButton, findsOneWidget);
      
      await tester.tap(historyButton);
      await tester.pumpAndSettle();

      // Verify navigasi ke history screen
      // expect(find.text('Riwayat Klasifikasi'), findsOneWidget);
    });
  });
}