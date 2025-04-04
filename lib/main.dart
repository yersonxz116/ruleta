import 'package:flutter/material.dart';
import 'models/user.dart';
import 'screens/game_screen.dart';
import 'screens/user_profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruleta Rusa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  // Usuarios predefinidos
  final User user1 = User(
    id: '1',
    name: 'Usuario 1',
    wins: 0,
    losses: 0,
    avatarUrl: null,
    lives: 2,
    heartColor: Colors.red, // Corazones rojos para Usuario 1
  );

  final User user2 = User(
    id: '2',
    name: 'Usuario 2',
    wins: 0,
    losses: 0,
    avatarUrl: null,
    lives: 2,
    heartColor: Colors.blue, // Corazones azules para Usuario 2
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruleta Rusa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ruleta Rusa',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Image.asset(
              'assets/revolver.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(user1: user1, user2: user2),
                  ),
                );
              },
              child: Text('Iniciar Juego'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(user: user1),
                      ),
                    );
                  },
                  child: Text('Perfil Usuario 1'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(user: user2),
                      ),
                    );
                  },
                  child: Text('Perfil Usuario 2'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}