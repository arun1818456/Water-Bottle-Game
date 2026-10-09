import 'exports.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splashScreen,
      defaultTransition: Transition.cupertino,
      getPages: AppPages.getPages,
    );
  }
}
