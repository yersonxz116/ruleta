import 'dart:io';
import 'dart:math';

// Models
class User {
  final String id;
  final String name;
  int wins;
  int losses;
  int lives;
  final int maxLives = 2;
  
  User({
    required this.id,
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.lives = 2,
  });

  void addWin() {
    wins++;
  }

  void addLoss() {
    losses++;
  }

  bool loseLife() {
    if (lives > 0) {
      lives--;
      return lives == 0; // Returns true if no lives left
    }
    return true; // Already no lives
  }

  void resetLives() {
    lives = maxLives;
  }

  double getWinRate() {
    if (wins + losses == 0) return 0.0;
    return (wins / (wins + losses)) * 100;
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  bool isCorrect(int selectedOptionIndex) {
    return selectedOptionIndex == correctOptionIndex;
  }
}

class QuestionRepository {
  static final List<Question> _questions = [
    Question(
      text: '¿Cuál es la capital de Francia?',
      options: ['Madrid', 'París', 'Roma', 'Berlín'],
      correctOptionIndex: 1,
    ),
    Question(
      text: '¿Cuántos lados tiene un hexágono?',
      options: ['5', '6', '7', '8'],
      correctOptionIndex: 1,
    ),
    Question(
      text: '¿Qué planeta es conocido como el planeta rojo?',
      options: ['Venus', 'Júpiter', 'Marte', 'Saturno'],
      correctOptionIndex: 2,
    ),
    Question(
      text: '¿Cuál es el elemento químico con símbolo H?',
      options: ['Helio', 'Hidrógeno', 'Hierro', 'Hafnio'],
      correctOptionIndex: 1,
    ),
    Question(
      text: '¿En qué año comenzó la Segunda Guerra Mundial?',
      options: ['1939', '1941', '1945', '1938'],
      correctOptionIndex: 0,
    ),
    Question(
      text: '¿Quién pintó La Mona Lisa?',
      options: ['Vincent van Gogh', 'Pablo Picasso', 'Leonardo da Vinci', 'Miguel Ángel'],
      correctOptionIndex: 2,
    ),
    Question(
      text: '¿Cuál es el río más largo del mundo?',
      options: ['Nilo', 'Amazonas', 'Misisipi', 'Yangtsé'],
      correctOptionIndex: 1,
    ),
    Question(
      text: '¿Cuál es el hueso más largo del cuerpo humano?',
      options: ['Fémur', 'Húmero', 'Tibia', 'Radio'],
      correctOptionIndex: 0,
    ),
    Question(
      text: '¿Cuál es el animal terrestre más grande?',
      options: ['Elefante africano', 'Jirafa', 'Hipopótamo', 'Rinoceronte'],
      correctOptionIndex: 0,
    ),
    Question(
      text: '¿Cuál es el metal más caro del mundo?',
      options: ['Oro', 'Platino', 'Rodio', 'Paladio'],
      correctOptionIndex: 2,
    ),
  ];

  static Question getRandomQuestion() {
    final random = Random();
    return _questions[random.nextInt(_questions.length)];
  }
}

class GameState {
  final User user1;
  final User user2;
  
  final List<bool> chamber = List.filled(6, false);
  int currentChamberPosition = 0;
  
  bool gameOver = false;
  int numBullets = 1;
  int canonPosition = 0;
  
  GameState({
    required this.user1,
    required this.user2,
  });
  
  void initChamber(int bullets) {
    numBullets = bullets.clamp(1, 5);
    resetChamber();
  }
  
  void resetChamber() {
    for (int i = 0; i < chamber.length; i++) {
      chamber[i] = false;
    }
    
    final random = Random();
    List<int> positions = List.generate(6, (index) => index);
    positions.shuffle(random);
    
    for (int i = 0; i < numBullets; i++) {
      chamber[positions[i]] = true;
    }
    
    currentChamberPosition = 0;
    canonPosition = random.nextInt(2);
  }
  
  void spin() {
    final random = Random();
    int steps = random.nextInt(5) + 1;
    currentChamberPosition = (currentChamberPosition + steps) % 6;
    canonPosition = random.nextInt(2);
  }
  
  bool hasBulletInCurrentPosition() {
    return chamber[currentChamberPosition];
  }
  
  void moveToNextChamberPosition() {
    currentChamberPosition = (currentChamberPosition + 1) % 6;
  }
  
  User getTargetUser() {
    return canonPosition == 0 ? user1 : user2;
  }
  
  User getNonTargetUser() {
    return canonPosition == 0 ? user2 : user1;
  }
}

// Terminal UI helpers
void clearScreen() {
  if (Platform.isWindows) {
    stdout.write('\x1B[2J\x1B[0f');
  } else {
    stdout.write('\x1B[2J\x1B[H');
  }
}

String readLine() {
  return stdin.readLineSync() ?? '';
}

int? readInt() {
  final input = readLine();
  return int.tryParse(input);
}

void printCentered(String text) {
  final width = 80;
  final padding = (width - text.length) ~/ 2;
  if (padding > 0) {
    stdout.write(' ' * padding);
  }
  stdout.writeln(text);
}

void printHearts(User user) {
  String hearts = '';
  for (int i = 0; i < user.maxLives; i++) {
    hearts += (i < user.lives) ? '♥ ' : '♡ ';
  }
  stdout.writeln('${user.name}: $hearts');
}

void printSeparator() {
  stdout.writeln('─' * 80);
}

void printTitle(String title) {
  printSeparator();
  printCentered(title);
  printSeparator();
}

void printChamber(GameState gameState) {
  String chamberStr = '';
  for (int i = 0; i < gameState.chamber.length; i++) {
    if (i == gameState.currentChamberPosition) {
      chamberStr += '[${gameState.chamber[i] ? '•' : 'o'}]';
    } else {
      chamberStr += ' ${gameState.chamber[i] ? '•' : 'o'} ';
    }
  }
  stdout.writeln('Tambor: $chamberStr');
  stdout.writeln('Posición actual: ${gameState.currentChamberPosition + 1}/6');
  stdout.writeln('Número de balas: ${gameState.numBullets}');
}

// Game logic
void main() async {
  clearScreen();
  printTitle('RULETA RUSA - VERSIÓN TERMINAL');
  
  stdout.writeln('Bienvenido a Ruleta Rusa - Versión Terminal');
  stdout.writeln();
  
  // Create users
  final user1 = User(id: '1', name: 'Usuario 1');
  final user2 = User(id: '2', name: 'Usuario 2');
  
  bool playAgain = true;
  
  while (playAgain) {
    // Reset lives at the start of each game
    user1.resetLives();
    user2.resetLives();
    
    // Initialize game state
    final gameState = GameState(user1: user1, user2: user2);
    
    // Select number of bullets
    stdout.writeln('Selecciona el número de balas (1-5):');
    int? bullets;
    do {
      bullets = readInt();
      if (bullets == null || bullets < 1 || bullets > 5) {
        stdout.writeln('Por favor, ingresa un número entre 1 y 5.');
      }
    } while (bullets == null || bullets < 1 || bullets > 5);
    
    gameState.initChamber(bullets);
    
    bool gameOver = false;
    
    while (!gameOver) {
      clearScreen();
      printTitle('RULETA RUSA');
      
      // Show lives
      printHearts(user1);
      printHearts(user2);
      
      // Show chamber info
      printChamber(gameState);
      
      // Show whose turn it is
      User targetUser = gameState.getTargetUser();
      stdout.writeln();
      stdout.writeln('Cañón apuntando a: ${targetUser.name}');
      stdout.writeln();
      
      // Spin the chamber
      stdout.writeln('Presiona ENTER para girar el tambor...');
      readLine();
      
      stdout.writeln('Girando el tambor...');
      await Future.delayed(Duration(seconds: 1));
      
      gameState.spin();
      
      stdout.writeln('El tambor se ha detenido.');
      stdout.writeln('Cañón apuntando a: ${gameState.getTargetUser().name}');
      stdout.writeln();
      
      // Update target user after spin
      targetUser = gameState.getTargetUser();
      
      // Show question
      Question question = QuestionRepository.getRandomQuestion();
      stdout.writeln('Pregunta para ${targetUser.name}:');
      stdout.writeln(question.text);
      
      for (int i = 0; i < question.options.length; i++) {
        String option = String.fromCharCode(65 + i); // A, B, C, D
        stdout.writeln('$option. ${question.options[i]}');
      }
      
      // Get answer
      stdout.writeln();
      stdout.writeln('Selecciona tu respuesta (A, B, C, D):');
      
      int? selectedOptionIndex;
      do {
        final answer = readLine().toUpperCase();
        if (answer.length == 1 && answer.codeUnitAt(0) >= 65 && answer.codeUnitAt(0) <= 68) {
          selectedOptionIndex = answer.codeUnitAt(0) - 65;
        } else {
          stdout.writeln('Por favor, ingresa A, B, C o D.');
        }
      } while (selectedOptionIndex == null);
      
      // Check answer
      bool isCorrect = question.isCorrect(selectedOptionIndex);
      
      if (isCorrect) {
        stdout.writeln('¡Respuesta correcta!');
        
        // If correct, choose who to shoot
        stdout.writeln();
        stdout.writeln('¿A quién quieres disparar?');
        stdout.writeln('1. A mí mismo');
        stdout.writeln('2. A ${gameState.getNonTargetUser().name}');
        
        int? choice;
        do {
          choice = readInt();
          if (choice != 1 && choice != 2) {
            stdout.writeln('Por favor, ingresa 1 o 2.');
          }
        } while (choice != 1 && choice != 2);
        
        User shootTarget = choice == 1 ? targetUser : gameState.getNonTargetUser();
        
        // Shoot
        stdout.writeln();
        stdout.writeln('Disparando a ${shootTarget.name}...');
        await Future.delayed(Duration(seconds: 1));
        
        bool hasBullet = gameState.hasBulletInCurrentPosition();
        
        if (hasBullet) {
          stdout.writeln('¡BANG!');
          bool noLivesLeft = shootTarget.loseLife();
          
          if (noLivesLeft) {
            stdout.writeln('${shootTarget.name} ha perdido todas sus vidas.');
            shootTarget.addLoss();
            (shootTarget == user1 ? user2 : user1).addWin();
            gameOver = true;
          } else {
            stdout.writeln('${shootTarget.name} ha perdido una vida.');
          }
        } else {
          stdout.writeln('Click... El arma no tenía bala en esta posición.');
        }
      } else {
        stdout.writeln('¡Respuesta incorrecta!');
        stdout.writeln('La respuesta correcta era: ${String.fromCharCode(65 + question.correctOptionIndex)}. ${question.options[question.correctOptionIndex]}');
        
        // If incorrect, must shoot self
        stdout.writeln();
        stdout.writeln('Debes dispararte a ti mismo...');
        await Future.delayed(Duration(seconds: 1));
        
        bool hasBullet = gameState.hasBulletInCurrentPosition();
        
        if (hasBullet) {
          stdout.writeln('¡BANG!');
          bool noLivesLeft = targetUser.loseLife();
          
          if (noLivesLeft) {
            stdout.writeln('${targetUser.name} ha perdido todas sus vidas.');
            targetUser.addLoss();
            gameState.getNonTargetUser().addWin();
            gameOver = true;
          } else {
            stdout.writeln('${targetUser.name} ha perdido una vida.');
          }
        } else {
          stdout.writeln('Click... El arma no tenía bala en esta posición.');
        }
      }
      
      if (!gameOver) {
        gameState.moveToNextChamberPosition();
        
        stdout.writeln();
        stdout.writeln('Presiona ENTER para continuar...');
        readLine();
      }
    }
    
    // Game over
    clearScreen();
    printTitle('FIN DEL JUEGO');
    
    User winner = user1.lives > 0 ? user1 : user2;
    User loser = winner == user1 ? user2 : user1;
    
    stdout.writeln('¡${winner.name} ha ganado!');
    stdout.writeln();
    
    // Show stats
    printTitle('ESTADÍSTICAS');
    
    stdout.writeln('${user1.name}:');
    stdout.writeln('Victorias: ${user1.wins}');
    stdout.writeln('Derrotas: ${user1.losses}');
    stdout.writeln('Porcentaje de Victoria: ${user1.getWinRate().toStringAsFixed(1)}%');
    stdout.writeln();
    
    stdout.writeln('${user2.name}:');
    stdout.writeln('Victorias: ${user2.wins}');
    stdout.writeln('Derrotas: ${user2.losses}');
    stdout.writeln('Porcentaje de Victoria: ${user2.getWinRate().toStringAsFixed(1)}%');
    stdout.writeln();
    
    // Ask to play again
    stdout.writeln('¿Quieres jugar de nuevo? (s/n):');
    String answer;
    do {
      answer = readLine().toLowerCase();
      if (answer != 's' && answer != 'n') {
        stdout.writeln('Por favor, ingresa s o n.');
      }
    } while (answer != 's' && answer != 'n');
    
    playAgain = answer == 's';
  }
  
  stdout.writeln('¡Gracias por jugar!');
}