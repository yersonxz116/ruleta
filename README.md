# Ruleta Rusa - Aplicación Flutter

Una aplicación de Ruleta Rusa con perfiles de usuario y animaciones de disparo.

## Características

- Juego de Ruleta Rusa para dos jugadores
- Perfiles de usuario con estadísticas (victorias y derrotas)
- Animación de rotación del revólver
- Animación de disparo con efecto visual
- Interfaz de usuario intuitiva

## Requisitos

- Flutter 3.0 o superior
- Dart 2.17 o superior

## Instalación

1. Clona este repositorio
2. Ejecuta `flutter pub get` para instalar las dependencias
3. Asegúrate de tener la imagen del revólver en la carpeta `assets`:
   - `revolver.png` - Imagen del revólver

## Cómo jugar

1. Inicia la aplicación
2. Pulsa "Iniciar Juego" en la pantalla principal
3. El juego alternará entre los dos jugadores
4. Pulsa "Girar Tambor" para girar el revólver
5. Después de girar, el revólver disparará automáticamente
6. Si el jugador pierde, el juego se reinicia
7. Si el jugador sobrevive, el turno pasa al siguiente jugador

## Perfiles de usuario

Puedes acceder a los perfiles de usuario desde:
- La pantalla principal (botones "Perfil Usuario 1" y "Perfil Usuario 2")
- La pantalla de juego (iconos de persona en la barra superior)

Los perfiles muestran:
- Nombre del usuario
- Número de victorias
- Número de derrotas
- Porcentaje de victorias