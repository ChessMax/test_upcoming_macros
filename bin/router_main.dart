import 'package:test_upcoming_macros/route.dart';

@Route(path: '/profile/:profileId?tab=:tab', returnType: 'bool')
class ProfileScreen extends StatelessWidget {
  final int profileId;
  final String? tab;

  @override
  Widget build(BuildContext context) {
    return Button(onPressed: () {
      print('onSaveButton clicked (profileId: $profileId, tab: $tab)');
      // close current screen
      pop(context, true);
    });
  }
}

@Route(path: '/login')
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Button(onPressed: () {
      print('On logged in button pressed');
      pop(context);
    });
  }
}

void main() async {
  final r = LoginScreen.buildLoginRoute('/login');
  (r as LoginScreen)?.greet();

  final routeBuilders = [
    LoginScreen.buildLoginRoute,
    ProfileScreen.buildProfileRoute,
  ];
  final app = MaterialApp(onGenerateRoute: (route, [arguments]) {
    print('onGenerateRoute: $route');
    for (final builder in routeBuilders) {
      final screen = builder(route, arguments);
      if (screen != null) return screen;
    }
    throw 'Failed to generate route for $route.';
  });

  final context = app.context;
  final hasChanges =
      await context.navigator.pushProfile(profileId: 15, tab: 'settings');
  print('Has changes: $hasChanges');

  await context.navigator.pushLogin();
  print('Login screen closed');
}
