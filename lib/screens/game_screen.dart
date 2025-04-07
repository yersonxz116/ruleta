import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/user.dart';
import '../models/game_state.dart';
import '../models/questions/question.dart';
import '../models/questions/question_repository.dart';
import 'user_profile_screen.dart';

class GameScreen extends StatefulWidget {
  final User user1;
  final User user2;
  final int bullets; // Nuevo parámetro para las balas

  const GameScreen({
    Key? key, 
    required this.user1, 
    required this.user2,
    required this.bullets, // Requerido
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shootingAnimation;
  
  late GameState gameState;
  Question? currentQuestion;
  bool showingQuestion = false;
  int? selectedAnswer;
  
  // Resultado de la pregunta
  bool? questionAnsweredCorrectly;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar el estado del juego
    gameState = GameState(user1: widget.user1, user2: widget.user2);
    
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    _shootingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    // Inicializar el tambor con el número de balas seleccionado
    gameState.initChamber(widget.bullets);
  }

  void girarRevolver() {
    if (!gameState.isSpinning && !gameState.isShooting && !showingQuestion) {
      setState(() {
        gameState.isSpinning = true;
      });

      // Girar el tambor y el cañón
      gameState.spin();

      // Calcular el ángulo de rotación para el tambor
      double vueltasCompletas = 3.0; // 3 vueltas completas
      
      // Ángulo final del cañón (0 o 0.5 vueltas)
      double canonFinalAngle = gameState.getCanonAngle();
      
      // El ángulo final debe ser 0 (arriba) o 0.5 (abajo) vueltas
      // Añadimos las vueltas completas al ángulo final del cañón
      double targetAngle = vueltasCompletas + canonFinalAngle;

      _controller.reset();
      _controller.duration = Duration(seconds: 3);
      
      _rotationAnimation = Tween<double>(
        begin: 0,
        end: targetAngle,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _controller.forward().then((_) {
        setState(() {
          gameState.isSpinning = false;
          // Mostrar pregunta después de girar al usuario que tiene el cañón apuntando
          mostrarPregunta();
        });
      });
    }
  }

  void mostrarPregunta() {
    // Obtener una pregunta aleatoria
    currentQuestion = QuestionRepository.getRandomQuestion();
    
    setState(() {
      showingQuestion = true;
      selectedAnswer = null;
      questionAnsweredCorrectly = null;
    });
    
    // Obtener el usuario al que apunta el cañón
    User targetUser = gameState.getTargetUser();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Pregunta para ${targetUser.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currentQuestion!.text, style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ...List.generate(4, (index) {
                String option = String.fromCharCode(65 + index); // A, B, C, D
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RadioListTile<int>(
                    title: Text('$option. ${currentQuestion!.options[index]}'),
                    value: index,
                    groupValue: selectedAnswer,
                    onChanged: questionAnsweredCorrectly != null ? null : (value) {
                      setDialogState(() {
                        selectedAnswer = value;
                      });
                    },
                  ),
                );
              }),
              if (questionAnsweredCorrectly != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    questionAnsweredCorrectly! 
                        ? '¡Respuesta correcta!' 
                        : '¡Respuesta incorrecta!',
                    style: TextStyle(
                      color: questionAnsweredCorrectly! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            if (questionAnsweredCorrectly == null)
              ElevatedButton(
                onPressed: selectedAnswer != null ? () {
                  // Verificar si la respuesta es correcta
                  bool isCorrect = currentQuestion!.isCorrect(selectedAnswer!);
                  
                  setDialogState(() {
                    questionAnsweredCorrectly = isCorrect;
                  });
                  
                  // Esperar un momento para mostrar el resultado
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.of(context).pop();
                    setState(() {
                      showingQuestion = false;
                    });
                    
                    // Decidir qué hacer según la respuesta
                    if (isCorrect) {
                      // Si responde correctamente, puede elegir disparar a sí mismo o al oponente
                      mostrarOpcionesDisparo(targetUser);
                    } else {
                      // Si responde incorrectamente, debe dispararse a sí mismo
                      dispararRevolver(targetUser: targetUser);
                    }
                  });
                } : null,
                child: Text('Responder'),
              ),
            if (questionAnsweredCorrectly != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    showingQuestion = false;
                  });
                  
                  // Decidir qué hacer según la respuesta
                  if (questionAnsweredCorrectly!) {
                    // Si responde correctamente, puede elegir disparar a sí mismo o al oponente
                    mostrarOpcionesDisparo(targetUser);
                  } else {
                    // Si responde incorrectamente, debe dispararse a sí mismo
                    dispararRevolver(targetUser: targetUser);
                  }
                },
                child: Text('Continuar'),
              ),
          ],
        ),
      ),
    );
  }

  void mostrarOpcionesDisparo(User targetUser) {
    User otherUser = targetUser == widget.user1 ? widget.user2 : widget.user1;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('¡Respuesta correcta!'),
        content: Text('${targetUser.name}, puedes elegir a quién disparar:'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Disparar a sí mismo
              dispararRevolver(targetUser: targetUser);
            },
            child: Text('Disparar a mí mismo'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Disparar al oponente
              dispararRevolver(targetUser: otherUser);
            },
            child: Text('Disparar a ${otherUser.name}'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void dispararRevolver({required User targetUser}) {
    if (!gameState.isSpinning && !gameState.isShooting) {
      setState(() {
        gameState.isShooting = true;
      });

      // Simular el disparo
      _controller.reset();
      _controller.duration = Duration(milliseconds: 500);
      
      _controller.forward().then((_) {
        // Verificar si hay una bala en la recámara
        bool hasBullet = gameState.shoot();
        
        setState(() {
          gameState.isShooting = false;
          
          if (hasBullet) {
            // Si hay bala, el usuario pierde una vida
            targetUser.lives--;
            
            // Verificar si el juego ha terminado
            if (targetUser.lives <= 0) {
              // El usuario ha perdido
              User winner = targetUser == widget.user1 ? widget.user2 : widget.user1;
              winner.wins++;
              targetUser.losses++;
              
              // Mostrar mensaje de fin de juego
              mostrarFinJuego(winner);
            }
          }
        });
      });
    }
  }

  void mostrarFinJuego(User winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('¡Fin del juego!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¡${winner.name} ha ganado!'),
            SizedBox(height: 20),
            Text('Estadísticas:'),
            SizedBox(height: 10),
            Text('${widget.user1.name}: ${widget.user1.wins} victorias, ${widget.user1.losses} derrotas'),
            Text('${widget.user2.name}: ${widget.user2.wins} victorias, ${widget.user2.losses} derrotas'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver al menú principal
            },
            child: Text('Volver al menú'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reiniciar el juego
              setState(() {
                widget.user1.lives = 2;
                widget.user2.lives = 2;
                gameState = GameState(user1: widget.user1, user2: widget.user2);
                gameState.initChamber(widget.bullets);
              });
            },
            child: Text('Jugar de nuevo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario al que apunta el cañón
    User targetUser = gameState.getTargetUser();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruleta Rusa con Preguntas'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: widget.user1),
                ),
              );
            },
            tooltip: 'Perfil de ${widget.user1.name}',
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: widget.user2),
                ),
              );
            },
            tooltip: 'Perfil de ${widget.user2.name}',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vidas del Usuario 1
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.user1.name}: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...List.generate(2, (index) {
                  return Icon(
                    Icons.favorite,
                    color: index < widget.user1.lives ? widget.user1.heartColor : Colors.grey,
                    size: 30,
                  );
                }),
              ],
            ),
            SizedBox(height: 10),
            // Vidas del Usuario 2
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.user2.name}: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...List.generate(2, (index) {
                  return Icon(
                    Icons.favorite,
                    color: index < widget.user2.lives ? widget.user2.heartColor : Colors.grey,
                    size: 30,
                  );
                }),
              ],
            ),
            SizedBox(height: 40),
            // Revólver
            Stack(
              alignment: Alignment.center,
              children: [
                // Tambor del revólver
                RotationTransition(
                  turns: _rotationAnimation,
                  child: Image.asset(
                    'assets/img/revolver.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Indicador de turno
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: targetUser == widget.user1 ? widget.user1.heartColor : widget.user2.heartColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Turno de ${targetUser.name}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40),
            // Botón para girar
            ElevatedButton(
              onPressed: gameState.isSpinning || gameState.isShooting || showingQuestion ? null : girarRevolver,
              child: Text('Girar Tambor'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}