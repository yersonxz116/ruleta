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
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/portada.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'RULETA RUSA',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Image.asset(
                'assets/img/revolver.png',
                width: 180,
                height: 180,
              ),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  _showBulletsDialog(context);
                },
                child: Text('JUGAR', style: TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Aquí iría la navegación a la pantalla de opciones
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Opciones'),
                        content: Text('Opciones del juego (en desarrollo)'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('OPCIONES', style: TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulletsDialog(BuildContext context) {
    int selectedBullets = 1;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Selecciona la cantidad de balas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Número de balas: $selectedBullets'),
                  Slider(
                    value: selectedBullets.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: selectedBullets.toString(),
                    onChanged: (double value) {
                      setState(() {
                        selectedBullets = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          user1: user1,
                          user2: user2,
                          bullets: selectedBullets, // Pasar el número de balas seleccionado
                        ),
                      ),
                    );
                  },
                  child: Text('Comenzar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}