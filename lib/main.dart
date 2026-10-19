import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Pages/recipe.dart';
import 'Pages/shopping.dart';
import 'Pages/foodie.dart';
import 'Pages/user.dart';
import 'Pages/pantry.dart';
import 'Pages/Provider/shopping_list.dart';
import 'Pages/Credentials/log_in.dart';
import 'Pages/Credentials/sign_up.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);  // Ensure Firebase is initialized
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }

  FirebaseAuth.instance
      .userChanges()
      .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShoppingListProvider()),
      ],
      child: const FoodInventoryApp(),
    ),
  );
}

void _logError(String code, String? description) {
  if (kDebugMode) {
    print('Error: $code\nError Message: $description');
  }
}



class FoodInventoryApp extends StatelessWidget {
  const FoodInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PanVi',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Set default page to Pantry

  static final List<Widget> _widgetOptions = <Widget>[
    const RecipePage(),
    const ShoppingListPage(),
    PantryPage(userName: FirebaseAuth.instance.currentUser?.displayName ?? 'Guest'),
    const FoodiePage(),
    UserProfilePage(userName: FirebaseAuth.instance.currentUser?.displayName ?? 'Guest'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded, color: Color(0xFF459433)),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFF459433)),
            label: 'Shopping Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_rounded, color: Color(0xFF459433)),
            label: 'Pantry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_3_rounded, color: Color(0xFF459433)),
            label: 'Foodies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_rounded, color: Color(0xFF459433)),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF459433),
        onTap: _onItemTapped,
      ),
    );
  }
}