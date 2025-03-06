import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'pages/homePage.dart';
import 'services/preferences_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefsService = PreferencesService();
  await prefsService.init();

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: prefsService),
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(prefsService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather App',
          theme: themeProvider.themeData,
          home: const Homepage(),
        );
      },
    );
  }
}
