import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/user.dart';
import '../models/game_state.dart';
import '../models/questions/question.dart';
import '../models/questions/question_repository.dart';
import 'user_profile_screen.dart';
import 'bullet_selection_dialog.dart';

class GameScreen extends StatefulWidget {
  final User user1;
  final User user2;

  const GameScreen({Key? key, required this.user1, required this.user2}) : super(key: key);

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
    
    // Mostrar diu00e1logo de selecciu00f3n de balas despuu00e9s de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BulletSelectionDialog(
          onBulletsSelected: (bullets) {
            setState(() {
              gameState.initChamber(bullets);
            });
          },
        ),
      );
    });
  }

  void girarRevolver() {
    if (!gameState.isSpinning && !gameState.isShooting && !showingQuestion) {
      setState(() {
        gameState.isSpinning = true;
      });

      // Girar el tambor y el cañón
      gameState.spin();

      // Calcular el ángulo de rotación para el tambor
      double vueltasCompletas = 3 * 2 * math.pi; // 3 vueltas completas
      
      // Ángulo final del cañón (90 o 270 grados)
      double canonFinalAngle = gameState.getCanonAngle();
      
      // El ángulo final debe ser un múltiplo exacto de 90 grados (90 o 270)
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
    
    // Obtener el usuario al que apunta el cau00f1u00f3n
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
                        ? 'u00a1Respuesta correcta!' 
                        : 'u00a1Respuesta incorrecta!',
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
                    
                    // Decidir quu00e9 hacer segu00fan la respuesta
                    if (isCorrect) {
                      // Si responde correctamente, puede elegir disparar a su00ed mismo o al oponente
                      mostrarOpcionesDisparo(targetUser);
                    } else {
                      // Si responde incorrectamente, debe dispararse a su00ed mismo
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
                  
                  // Decidir quu00e9 hacer segu00fan la respuesta
                  if (questionAnsweredCorrectly!) {
                    // Si responde correctamente, puede elegir disparar a su00ed mismo o al oponente
                    mostrarOpcionesDisparo(targetUser);
                  } else {
                    // Si responde incorrectamente, debe dispararse a su00ed mismo
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
        title: Text('u00a1Respuesta correcta!'),
        content: Text('${targetUser.name}, puedes elegir a quiu00e9n disparar:'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Disparar a su00ed mismo
              dispararRevolver(targetUser: targetUser);
            },
            child: Text('Disparar a mu00ed mismo'),
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

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario al que apunta el cau00f1u00f3n
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (int i = 0; i < widget.user1.maxLives; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      i < widget.user1.lives ? Icons.favorite : Icons.favorite_border,
                      color: widget.user1.heartColor,
                      size: 24,
                    ),
                  ),
              ],
            ),
            
            // Vidas del Usuario 2
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.user2.name}: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (int i = 0; i < widget.user2.maxLives; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      i < widget.user2.lives ? Icons.favorite : Icons.favorite_border,
                      color: widget.user2.heartColor,
                      size: 24,
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Mostrar a quiu00e9n apunta el cau00f1u00f3n
            Text(
              'Cau00f1u00f3n apuntando a: ${targetUser.name}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: gameState.isShooting 
                      ? Offset(-30 * _shootingAnimation.value.clamp(0.0, 1.0), 0) 
                      : Offset.zero,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Image.asset(
                      'assets/revolver.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                );
              },
            ),
            if (gameState.isShooting)
              AnimatedBuilder(
                animation: _shootingAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _shootingAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      margin: EdgeInsets.only(left: 180),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.yellow,
                            Colors.orange,
                            Colors.red.withOpacity(0.0),
                          ],
                          stops: [0.2, 0.5, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (gameState.isSpinning || gameState.isShooting || showingQuestion) 
                      ? null 
                      : girarRevolver,
                  child: Text(gameState.isSpinning ? 'Girando...' : 'Girar Tambor'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
            
            // Mostrar informaciu00f3n sobre el tambor (para depuraciu00f3n)
            SizedBox(height: 20),
            Text('Posiciu00f3n actual: ${gameState.currentChamberPosition + 1}/6',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(
              'Balas: ' + gameState.chamber.map((hasBullet) => hasBullet ? 'u2022' : 'o').join(' '),
              style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'monospace'),
            ),
            Text(
              'Nu00famero de balas: ${gameState.numBullets}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
  
  void dispararRevolver({required User targetUser}) {
    setState(() {
      gameState.isShooting = true;
    });
    
    // Configurar la animaciu00f3n de disparo
    _controller.reset();
    _controller.duration = Duration(milliseconds: 800);
    
    // Reiniciar la animaciu00f3n de disparo
    _shootingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward().then((_) {
      setState(() {
        gameState.isShooting = false;
        
        // Verificar si hay bala en la posiciu00f3n actual
        bool disparado = gameState.hasBulletInCurrentPosition();
        
        mostrarResultado(disparado, targetUser);
      });
    });
  }
  
  void mostrarResultado(bool disparado, User targetUser) {
    User otherUser = targetUser == widget.user1 ? widget.user2 : widget.user1;
    bool gameOver = false;
    
    if (disparado) {
      // El usuario objetivo pierde una vida
      gameOver = targetUser.loseLife();
      
      if (gameOver) {
        // Si se quedu00f3 sin vidas, pierde el juego
        targetUser.addLoss();
        otherUser.addWin();
      }
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(disparado ? 'u00a1BANG!' : 'Click...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(disparado 
                ? gameOver 
                    ? '${targetUser.name} ha perdido todas sus vidas' 
                    : '${targetUser.name} ha perdido una vida' 
                : 'El arma no tenu00eda bala en esta posiciu00f3n'),
            SizedBox(height: 10),
            if (disparado) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < targetUser.maxLives; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      i < targetUser.lives ? Icons.favorite : Icons.favorite_border,
                      color: targetUser.heartColor,
                      size: 24,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            if (gameOver)
              Text('Fin del juego', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (gameOver) {
                // Reiniciar juego
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => BulletSelectionDialog(
                    onBulletsSelected: (bullets) {
                      setState(() {
                        // Reiniciar vidas
                        widget.user1.resetLives();
                        widget.user2.resetLives();
                        
                        // Inicializar el tambor con el nu00famero de balas seleccionado
                        gameState.initChamber(bullets);
                      });
                    },
                  ),
                );
              } else {
                // Avanzar a la siguiente posiciu00f3n del tambor
                gameState.moveToNextChamberPosition();
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}