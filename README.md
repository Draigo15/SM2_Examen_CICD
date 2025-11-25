# SM2 Examen CI/CD – EnglishApp (Flutter)

![CI](https://github.com/Draigo15/SM2_Examen_CICD/actions/workflows/ci-pipeline.yml/badge.svg)

## Datos del Alumno
- Nombre: Nombre Apellido
- Tecnología usada: Proyecto en Flutter

## Enlace al Repositorio
- https://github.com/Draigo15/SM2_Examen_CICD

## Descripción del Pipeline
- Verifica lógica de negocio con `flutter test` (5 pruebas de utilidades).
- Audita calidad del código con `flutter analyze`.
- Compila y genera APK Android con `flutter build apk` y lo sube como Artifact.

## Evidencias
- Tests: captura del paso "Run Unit Tests" mostrando 5 tests en verde.
- Construcción: captura de la sección "Artifacts" mostrando el APK listo para descargar.

## Instrucciones de uso
- Repositorio público `SM2_Examen_CICD` en rama `main`.
- El workflow está en `.github/workflows/ci-pipeline.yml` y se ejecuta en cada `push` y `pull_request` a `main`.

## Lógica Validada (Parte 1)
- Archivo: `Frontend/lib/utils/validators.dart` con 5 funciones:
  - Validar Email
  - Seguridad Contraseña
  - Calculadora Descuento
  - Rango Válido
  - Texto a Mayúsculas
- Pruebas: `Frontend/test/validators_test.dart` (5 tests).

## Rutas de Artefactos
- APK: `Frontend/build/app/outputs/flutter-apk/*.apk`
