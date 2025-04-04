import 'dart:math';
import 'user.dart';

class GameState {
  final User user1;
  final User user2;
  
  // Tambor con 6 posiciones (0-5)
  final List<bool> chamber = List.filled(6, false); // false = vacío, true = bala
  int currentChamberPosition = 0; // Posición actual del tambor (0-5)
  
  // Estado del juego
  bool isSpinning = false;
  bool isShooting = false;
  bool gameOver = false;
  
  // Número de balas en el tambor (configurable)
  int numBullets = 1;
  
  // Posición del cañón (0 = apunta a user1, 1 = apunta a user2)
  // Solo hay dos posiciones posibles: 90 grados (posición 0) y 270 grados (posición 1)
  int canonPosition = 0;
  
  GameState({
    required this.user1,
    required this.user2,
  }) {
    // La inicialización del tambor se hará cuando el usuario elija el número de balas
  }
  
  // Inicializar el tambor con el número de balas especificado
  void initChamber(int bullets) {
    numBullets = bullets.clamp(1, 5); // Limitar entre 1 y 5 balas
    resetChamber();
  }
  
  // Reiniciar el tambor con el número de balas configurado
  void resetChamber() {
    // Limpiar el tambor
    for (int i = 0; i < chamber.length; i++) {
      chamber[i] = false;
    }
    
    // Colocar balas aleatorias según el número configurado
    final random = Random();
    List<int> positions = List.generate(6, (index) => index);
    positions.shuffle(random); // Mezclar posiciones aleatoriamente
    
    // Colocar las balas en posiciones aleatorias
    for (int i = 0; i < numBullets; i++) {
      chamber[positions[i]] = true; // Colocar bala
    }
    
    // Posición inicial aleatoria
    currentChamberPosition = 0; // Siempre empezar desde la posición 0
    
    // Posición inicial del cañón aleatoria (0 o 1)
    canonPosition = random.nextInt(2); // 0 = 90 grados (derecha), 1 = 270 grados (izquierda)
  }
  
  // Girar el tambor a una posición aleatoria y el cañón
  void spin() {
    final random = Random();
    // Avanzar a una posición aleatoria entre 1 y 5 posiciones
    int steps = random.nextInt(5) + 1;
    currentChamberPosition = (currentChamberPosition + steps) % 6;
    
    // Cambiar aleatoriamente a quién apunta el cañón (solo 2 posiciones)
    canonPosition = random.nextInt(2); // 0 = 90 grados (derecha), 1 = 270 grados (izquierda)
  }
  
  // Verificar si hay una bala en la posición actual
  bool hasBulletInCurrentPosition() {
    return chamber[currentChamberPosition];
  }
  
  // Avanzar a la siguiente posición del tambor
  void moveToNextChamberPosition() {
    currentChamberPosition = (currentChamberPosition + 1) % 6;
  }
  
  // Obtener el usuario al que apunta el cañón
  User getTargetUser() {
    return canonPosition == 0 ? user1 : user2;
  }
  
  // Obtener el usuario que no está en la mira
  User getNonTargetUser() {
    return canonPosition == 0 ? user2 : user1;
  }
  
  // Obtener el ángulo de rotación del cañón en radianes
  double getCanonAngle() {
    return canonPosition == 0 ? 1.5708 : 4.71239; // PI/2 (90 grados) o 3*PI/2 (270 grados)
  }
}