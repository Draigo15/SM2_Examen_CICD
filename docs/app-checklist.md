# EnglishApp – Checklist de Funcionalidades y Estado de Tareas

Este checklist resume todo lo que hace la app (más allá de las HU) y el estado de cada tarea con evidencia técnica y breve explicación de cómo está implementado.

## Cómo usar este checklist
- [x] Completado: Implementado y funcional
- [~] Parcial: Implementado parcialmente o con brechas
- [ ] Pendiente: No implementado o sin evidencia

## Checklist de Funcionalidades (Backend y Frontend)

### Autenticación y Seguridad
- [x] Registro y Login con JWT y Refresh Tokens
  - Cómo: `AuthModule`, `UserAuthController` (`/register`, `/login`, `/refresh`, `/logout`), casos de uso (`RegisterUserUseCase`, `LoginUserUseCase`, etc.). Refresh tokens en cookies HttpOnly.
- [~] Endurecimiento de seguridad (CSRF, rate limiting, rotación)
  - Cómo: Rate limiting y guards presentes; cookies HttpOnly para refresh; documento `Backend/docs/refresh-token-rotation-service.md`. Falta CSRF token explícito en flujos POST.

### Sistema de Vidas
- [x] Validación de vidas por solicitud
  - Cómo: `lives-validation.middleware.ts` bloquea acciones si usuario no tiene vidas.
- [x] Endpoints de estado y consumo de vida
  - Cómo: `daily-lives.controller.ts` (obtener estado y consumir vida).
- [x] Reseteo diario de vidas por cron
  - Cómo: `cron.module.ts` + `daily-lives-reset.service.ts` (reseteo a la 1 AM UTC), `cron-monitor.controller.ts` para monitoreo/manual.

### Progreso del Usuario
- [x] CRUD de progreso y repetición de capítulos
  - Cómo: `ProgressModule`, controladores y casos (`CreateProgress`, `GetUserProgress`, `UpdateProgress`, `RepeatChapter`, repos `UserProgressRepository`, `ChapterRepetitionRepository`). Validaciones para acceso seguro.
- [~] Autosave uniforme en frontend (lectura, vocabulario, entrevista)
  - Cómo: `ProgressProvider` y `integration_test/autosave_test.dart`. Falta confirmar cobertura uniforme en todas las pantallas.

### Capítulos de Vocabulario
- [x] Consulta de vocabulario por capítulo con paginación
  - Cómo: `ChaptersController` expone `/vocab/chapters`; entidades `Chapter`, `VocabularyItem`; repos y seeders.
- [~] Desbloqueo visual y reglas en UI
  - Cómo: `vocabulary_screen.dart` maneja navegación y marcado de aprendizaje; falta surfacing claro de bloqueo/desbloqueo basado en aprobación.

### Lectura con Glosario
- [x] Lectura con palabras resaltadas y definiciones
  - Cómo: Backend `ReadingContent` incluye `highlightedWords` (seeder `reading-seeder.ts`); frontend `reading_content_screen.dart` y `reading_screen.dart` con `HighlightedText`/`HighlightedTextWidget` y `onWordTap` (dialogo de definición).
- [~] Integración con diccionario interno para búsqueda en tiempo real
  - Cómo: Backend `TranslationController` `/vocabulary/search`; falta integrar en FE cuando una palabra no tenga `definition` precargada.
- [x] Lectura en voz alta (TTS)
  - Cómo: `flutter_tts` y `audioplayers` en `audio_service.dart`.

### Quiz posterior a lectura
- [x] Entidades y repos de quiz de lectura
  - Cómo: `ReadingQuiz`, `QuizQuestion`; repos `reading-quiz.repository.ts`, `quiz-question.repository.ts`.
- [x] Endpoints y casos de uso del quiz
  - Cómo: `ReadingModule` con `GetQuizQuestionsUseCase`, `SubmitQuizAnswerUseCase`, `CompleteReadingChapterUseCase`; `reading.controller.ts` `GET /reading/chapters/:id/quiz`.
- [x] Migraciones de tablas de lectura y quiz
  - Cómo: `1759000000000-CreateReadingTables.ts` (contenido y preguntas), `1759850000000-CreateReadingQuizTable.ts` (tabla de quizzes). Seeders `reading-quiz-seeder.ts`.

### Reglas de Aprobación de Capítulos
- [x] Motor de reglas con umbrales (80% general, 100% capítulos 4 y 5)
  - Cómo: `evaluate-approval.use-case.ts` aplica umbrales, `approval.constants.ts` define críticos; validaciones en `configure-approval-rule.use-case.ts` y `update-approval-rule.use-case.ts`.
- [x] Pruebas de aprobación y casos borde
  - Cómo: `approval-engine.service.spec.ts` y `evaluate-approval-edge-cases.spec.ts` (80% exacto, 100% requerido, rechazo 99% en capítulo 4).
- [~] UI de resultado de aprobación (threshold/score/status)
  - Cómo: FE muestra estados de lectura/quiz, falta vista consolidada de aprobación por capítulo.

### Entrevista tipo Chat
- [~] Flujo de entrevista con preguntas, envío de respuestas y evaluación
  - Cómo: Backend `InterviewPractice` con `conversationFlow` y métricas; controlador `interview-practice.controller.ts` (`:id/answer-question`, `:id/update-conversation`, `:id/ai-evaluation`); FE `interview_screen.dart` y `interview_practice_service.dart`.
- [ ] Streaming de respuestas del asistente (SSE/WebSockets)
  - Cómo: No se observa SSE/WebSocket en BE/FE.
- [ ] STT y evaluación de pronunciación
  - Cómo: FE muestra controles de grabación; falta servicio de reconocimiento/evaluación y endpoints BE.

### Traducción y Diccionario
- [x] Búsqueda en diccionario interno
  - Cómo: Backend `TranslationController` `/vocabulary/search`.
- [~] Servicio de traducción externa
  - Cómo: `TranslationService` usa Google Translate para traducción de texto. Falta mapeo FE UI directo a esos endpoints.

### Audio (TTS/STT)
- [x] TTS en lectura
  - Cómo: `flutter_tts` y `audioplayers` (`audio_service.dart`).
- [ ] STT / Reconocimiento de voz
  - Cómo: No hay implementación directa encontrada en FE/BE.
- [ ] Evaluación de pronunciación (RF-10)
  - Cómo: Falta endpoint BE y lógica de análisis; FE con UI de grabación sin procesamiento.

### Estado, Offline y Providers
- [~] Gestión de estado con Provider
  - Cómo: Providers para progreso, lectura, vocabulario, entrevista; cobertura estable.
- [~] Soporte offline / caching
  - Cómo: No hay evidencia clara de caching persistente offline; considerar integración.

### Testing y QA
- [~] Pruebas unitarias e integración
  - Cómo: Buenas pruebas en aprobación; FE tiene `integration_test` (autosave, login/logout, session resumption, quiz); faltan E2E completos para streaming/STT/lives.

### Operación y Monitoreo
- [~] Monitoreo de cron y jobs
  - Cómo: `cron-monitor.controller.ts` permite disparar/monitorear; falta observabilidad/alertas.

## Cobertura por HU (Resumen)
- HU-001 Autenticación: [x] Implementado con observaciones (CSRF/documentación/QA).
- HU-002 Guardar progreso: [x] BE completo; [~] FE autosave uniforme.
- HU-003 Sistema de vidas: [x] Implementado (middleware, cron, endpoints).
- HU-004 Capítulos de vocabulario: [x] BE completo; [~] UI desbloqueo.
- HU-005 Repetición de capítulos: [~] Parcial (BE preparado; mejorar UX/QA).
- HU-006 Reglas de aprobación: [x] BE completo y probado; [~] UI pendiente.
- HU-007 Lectura con glosario: [x] Implementado; [~] integración diccionario en tiempo real.
- HU-008 Quiz posterior a lectura: [x] Implementado.
- HU-009 Entrevista tipo chat: [~] Parcial (falta streaming y STT/evaluación).

## Tareas Completadas y Cómo
- Autenticación con JWT/refresh: casos de uso y controlador (`AuthModule`, `UserAuthController`).
- Sistema de vidas: middleware, endpoints y cron (`daily-lives.*`, `cron.*`).
- Progreso del usuario: CRUD y repetición (`ProgressModule` y casos).
- Lectura con glosario: `ReadingContent` + FE `HighlightedText`/TTS.
- Quiz de lectura: `ReadingQuiz`/`QuizQuestion`, seeders y endpoints (`reading.controller.ts`).
- Motor de aprobación: umbrales y pruebas (capítulos 4/5 a 100%).
- Entrevista: flujo de preguntas y conversación (`InterviewPractice`, endpoints y FE UI).

## Tareas Pendientes y Próximos Pasos
- Integrar STT y evaluación de pronunciación (RF-10)
  - FE: `speech_to_text`/permisos; carga de audio.
  - BE: endpoints para audio, proveedor externo (Whisper/Google), persistencia y métricas.
- Añadir streaming en chat de entrevista (SSE/WebSockets)
  - BE/FE: canal de streaming, reconexión y manejo de estados.
- Surface de aprobación en FE
  - Mostrar `threshold`, `score` y `status` al finalizar capítulos/quiz; destacar 4/5.
- Uniformar autosave FE y reanudación granular
  - Lectura (página/párrafo), vocabulario (ítem), entrevista (pregunta).
- Fortalecer QA y E2E
  - Login/logout/refresh, 0 vidas y reset, aprobación capítulos, chat streaming, STT.
- Documentación y operación
  - Runbook de seguridad y RF-10; monitoreo cron y alertas.

## Funcionalidades Transversales (no explicitadas en HU)

- [x] Cambio de idioma y localización
  - Cómo: `l10n.yaml` + `lib/l10n/app_localizations.dart` con `supportedLocales` (`en`, `es`, `pt`, `qu`, `ru`); `MaterialApp` configura `localizationsDelegates` y `supportedLocales` (`main.dart`); selector en `SettingsScreen` usando `LocaleProvider` con persistencia en `SharedPreferences`.
  - Observación: el selector (`LocaleProvider.supportedLocales`) expone `en/es/pt/ru` pero el sistema también soporta `qu`; alinear listas para habilitar Quechua.

- [x] Tema claro/oscuro
  - Cómo: `ThemeProvider.toggleTheme()` y `MaterialApp.themeMode` aplican el modo; estado persistido en `SharedPreferences`.

- [x] Paletas de color y color personalizado
  - Cómo: selector en `SettingsScreen` (`_showColorPaletteSelector`) con paletas `AppColorPalettes`; personalización vía `ColorPickerWidget`; `ThemeProvider.setColorPalette` y `setCustomColor` con persistencia.

- [~] Preferencia de notificaciones (UI)
  - Cómo: `SettingsSwitch` en `SettingsScreen` mantiene estado local.
  - Observación: no está conectado a un servicio de notificaciones push; integrar proveedor (p.ej., Firebase Messaging) y autorización para hacerlo efectivo.

- [x] Confirmación de cierre de sesión
  - Cómo: `AlertDialog` en `_handleLogout` confirma antes de ejecutar `logout` y redirigir a `LoginScreen`.

- [x] Lectura en voz alta (TTS) en frontend
  - Cómo: botón de TTS en pantalla de lectura; `flutter_tts` y `audioplayers` en `audio_service.dart`.

- [x] Favoritos y panel de traducción en frontend
  - Cómo: `favorites_screen.dart` con `TranslationPanelWidget` y soporte de audio mediante `AudioService`.

- [x] Persistencia de preferencias de usuario
  - Cómo: `SharedPreferences` para `ThemeMode`, paleta de colores y `locale` gestionados por `ThemeProvider` y `LocaleProvider`.

- [ ] Alinear locales del selector con los soportados por localización
  - Cómo: añadir `Locale('qu')` en `LocaleProvider.supportedLocales` y nombre en `localeNames`.