import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:klasifikasi_makanan_minang/core/network/api_client.dart';
import 'package:klasifikasi_makanan_minang/data/datasources/food_classification_remote_data_source.dart';
import 'package:klasifikasi_makanan_minang/data/repositories/food_classification_repository.dart';
import 'package:klasifikasi_makanan_minang/domain/usecases/classify_food_usecase.dart';
import 'package:klasifikasi_makanan_minang/presentation/providers/classification_provider.dart';
import 'package:klasifikasi_makanan_minang/presentation/screens/home_screen.dart';

void main() async {

  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading .env file: $e');
    print('Make sure .env file exists in project root');
  }
  
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Create API client with your actual API configuration
  final apiClient = ApiClient();
  
  // Create data source
  final remoteDataSource = FoodClassificationRemoteDataSourceImpl(
    apiClient: apiClient,
  );
  
  // Create repository
  final repository = FoodClassificationRepository(
    remoteDataSource: remoteDataSource,
    sharedPreferences: sharedPreferences,
  );
  
  // Create use cases
  final classifyFoodUseCase = ClassifyFoodUseCase(repository: repository);
  
  runApp(MyApp(
    classifyFoodUseCase: classifyFoodUseCase,
    repository: repository,
  ));
}

class MyApp extends StatelessWidget {
  final ClassifyFoodUseCase classifyFoodUseCase;
  final FoodClassificationRepository repository;

  const MyApp({
    super.key,
    required this.classifyFoodUseCase,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ClassificationProvider(
            classifyFoodUseCase: classifyFoodUseCase,
            repository: repository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Minang Food Classifier',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryColor: Colors.orange[700],
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
            accentColor: Colors.orangeAccent,
            backgroundColor: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
          
          // App Bar Theme
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          
          // Text Theme
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            headlineSmall: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            titleLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
            ),
          ),
          
          // Card Theme
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
          ),
          
          // Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.orange[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          
          // Dialog Theme
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        
        // Customize page transitions
        onGenerateRoute: (settings) {
          // You can add custom route transitions here if needed
          return MaterialPageRoute(
            builder: (context) {
              switch (settings.name) {
                case '/':
                  return const HomeScreen();
                default:
                  return const HomeScreen();
              }
            },
          );
        },
      ),
    );
  }
}

