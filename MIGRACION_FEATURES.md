# Guía de Migración - Features Faltantes

## 📋 Objetivo
Migrar las funcionalidades implementadas en este repositorio al repositorio oficial sin causar conflictos ni corrupciones.

---

## 🎯 Features a Migrar

### 1. **Módulo de Quiz Independiente** ⭐ NUEVO
Actualmente en el repo oficial, Quiz solo existe dentro de Reading. Necesitas crear un módulo independiente.

#### Archivos a copiar:
```
✅ Backend/src/presentation/controllers/practices/quiz-practice.controller.ts
✅ Backend/src/application/use-cases/practices/quiz/
   ├── create-quiz-practice.use-case.ts
   ├── get-quiz-practice.use-case.ts
   ├── answer-question.use-case.ts
   ├── get-quiz-sessions.use-case.ts
   └── get-quiz-categories.use-case.ts
✅ Backend/src/presentation/mappers/quiz-practice.mapper.ts
✅ Frontend/lib/screens/quiz_screen.dart (VERIFICAR que tenga la versión con categorías)
```

#### Pasos de integración:
1. **Backend:**
   ```bash
   # En tu repo oficial
   cd Backend/src/application/use-cases/practices/
   mkdir -p quiz
   # Copiar los 5 archivos .use-case.ts
   
   # Agregar al module
   cd ../../presentation/modules/
   # Editar practices.module.ts
   ```

2. **Agregar decoradores @Inject:**
   ```typescript
   // En cada use case de quiz, asegurar:
   import { Injectable, Inject } from '@nestjs/common';
   
   @Injectable()
   export class CreateQuizPracticeUseCase {
     constructor(
       @Inject('IPracticeSessionRepository')
       private readonly practiceSessionRepository: IPracticeSessionRepository,
       // ... otros repositorios
     ) {}
   }
   ```

3. **Frontend:**
   ```bash
   # Copiar QuizScreen actualizado
   cp Frontend/lib/screens/quiz_screen.dart TU_REPO/Frontend/lib/screens/
   ```

---

### 2. **Estructura de Bottom Navigation Corregida** 🔄

#### Cambio necesario en `home_screen.dart`:

**ANTES (en repo oficial):**
```dart
final List<int> _navigableIndices = [0, 1, 2, 3]; // 4 botones + settings aparte

Widget _getCurrentScreenByIndex(int index) {
  switch (index) {
    case 0: return _buildHomeContent();
    case 1: return const VocabularyChaptersScreen();
    case 2: return const ReadingChaptersScreen();
    case 3: return const InterviewTopicsScreen();
    case 4: // Settings abre nueva pantalla
  }
}
```

**DESPUÉS (estructura correcta):**
```dart
final List<int> _navigableIndices = [0, 1, 2, 3, 4]; // 5 botones en PageView

Widget _getCurrentScreenByIndex(int index) {
  switch (index) {
    case 0: return _buildHomeContent();
    case 1: return const VocabularyChaptersScreen();
    case 2: return const ReadingChaptersScreen();
    case 3: return const QuizScreen(); // ← NUEVO
    case 4: return const InterviewScreen(); // ← Movido de index 3
    default: return _buildHomeContent();
  }
}

// Eliminar la lógica especial para Settings
bottomNavigationBar: CustomBottomNavigation(
  currentIndex: _currentIndex,
  onTap: (index) {
    _navigateToIndex(index); // Ya no hay caso especial para index 4
  },
),
```

#### Cambio en `bottom_navigation.dart`:

```dart
// CAMBIAR el último ícono de Settings a Interview
_buildNavItem(
  context,
  icon: Icons.chat_bubble_outline,  // ← Cambiar de settings_outlined
  activeIcon: Icons.chat_bubble,    // ← Cambiar de settings
  index: 4,
),
```

#### Agregar Settings al Dashboard:

**Editar `app_banner.dart`:**
```dart
class AppBanner extends StatelessWidget {
  final VoidCallback? onSettingsTap; // ← Agregar parámetro

  const AppBanner({
    required this.title,
    this.subtitle,
    required this.livesText,
    this.onSettingsTap, // ← Nuevo
  });

  // En el build, después del badge de vidas:
  if (onSettingsTap != null) ...[
    const SizedBox(width: 8),
    IconButton(
      icon: Icon(Icons.settings_outlined),
      onPressed: onSettingsTap,
    ),
  ],
}
```

**En `home_screen.dart` del Dashboard:**
```dart
AppBanner(
  title: 'Hi, ${authProvider.user?.name}',
  subtitle: 'Welcome back',
  livesText: livesProvider.currentLives.toString(),
  onSettingsTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  },
),
```

---

### 3. **Corregir Cards del Dashboard** 🏠

#### Problema actual:
```dart
// Card 1 → ChapterEpisodesScreen (sistema antiguo)
// Card 2 → ReadingChaptersScreen (duplica navegación)
// Card 3 → ChapterResultsScreen
```

#### Solución propuesta:
```dart
Widget _buildHomeContent() {
  return Column(
    children: [
      AppBanner(...),
      
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Card 1: Vocabulary
              CustomCard(
                title: 'English Basics',
                subtitle: 'Continue',
                description: 'Vocabulary',
                icon: CustomIcons.vocabularyIcon(),
                onTap: () {
                  // Navegar a Vocabulary (index 1)
                  _navigateToIndex(1);
                },
              ),
              
              const SizedBox(height: 8),
              
              // Card 2: Reading
              CustomCard(
                title: 'Software Texts',
                subtitle: 'Continue',
                description: 'Reading',
                icon: CustomIcons.readingIcon(),
                onTap: () {
                  // Navegar a Reading (index 2)
                  _navigateToIndex(2);
                },
              ),
              
              const SizedBox(height: 8),
              
              // Card 3: Quiz
              CustomCard(
                title: 'Test Your Knowledge',
                subtitle: 'Start',
                description: 'Quiz',
                icon: Icons.help_outline,
                onTap: () {
                  // Navegar a Quiz (index 3)
                  _navigateToIndex(3);
                },
              ),
              
              const SizedBox(height: 8),
              
              // Card 4: Interview (opcional)
              CustomCard(
                title: 'Practice Speaking',
                subtitle: 'Continue',
                description: 'Interview',
                icon: Icons.chat_bubble_outline,
                onTap: () {
                  // Navegar a Interview (index 4)
                  _navigateToIndex(4);
                },
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
```

---

### 4. **Migración de Base de Datos - Tabla Practices** 💾

#### Archivo a copiar:
```
Backend/src/infrastructure/database/migrations/1763621992929-CreatePracticesTables.ts
```

#### Pasos:
1. **Copiar el archivo de migración al repo oficial:**
   ```bash
   cp Backend/src/infrastructure/database/migrations/1763621992929-CreatePracticesTables.ts \
      TU_REPO_OFICIAL/Backend/src/infrastructure/database/migrations/
   ```

2. **Verificar que las entidades estén en `ormconfig.ts`:**
   ```typescript
   entities: [
     // ... otras entidades
     'src/domain/entities/practice-session.entity.ts',
     'src/domain/entities/vocabulary-practice.entity.ts',
     'src/domain/entities/reading-practice.entity.ts',
     'src/domain/entities/quiz-practice.entity.ts',
   ],
   ```

3. **Agregar entidades a `app.module.ts`:**
   ```typescript
   TypeOrmModule.forRoot({
     entities: [
       // ... otras
       PracticeSession,
       VocabularyPractice,
       ReadingPractice,
       QuizPractice,
     ],
   }),
   ```

4. **Ejecutar migración:**
   ```bash
   cd Backend
   npm run migration:run
   ```

---

### 5. **Entidades del Dominio** 📦

#### Verificar que existan estas entidades:

```bash
Backend/src/domain/entities/
├── practice-session.entity.ts        # Tabla principal
├── vocabulary-practice.entity.ts     # Relación 1:1
├── reading-practice.entity.ts        # Relación 1:1
└── quiz-practice.entity.ts          # Relación 1:1
```

#### Si faltan, copiarlas desde este repo.

---

### 6. **PracticesModule Completo** 🎯

#### Archivo crítico:
```
Backend/src/presentation/modules/practices.module.ts
```

#### Estructura que debe tener:

```typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([
      PracticeSession,
      VocabularyPractice,
      ReadingPractice,
      QuizPractice,
      Chapter,
      UserProgress,
      VocabularyItem, // ← IMPORTANTE para dependencias
    ]),
  ],
  controllers: [
    VocabularyPracticeController,
    ReadingPracticeController,
    QuizPracticeController, // ← NUEVO
  ],
  providers: [
    // Repositorios (7 total)
    { provide: 'IPracticeSessionRepository', useClass: PracticeSessionRepository },
    { provide: 'IVocabularyPracticeRepository', useClass: VocabularyPracticeRepository },
    { provide: 'IReadingPracticeRepository', useClass: ReadingPracticeRepository },
    { provide: 'IQuizPracticeRepository', useClass: QuizPracticeRepository },
    { provide: 'IChapterRepository', useClass: ChapterRepository },
    { provide: 'IUserProgressRepository', useClass: UserProgressRepository },
    { provide: 'IVocabularyItemRepository', useClass: VocabularyItemRepository },
    
    // Use Cases de Vocabulary (5)
    CreateVocabularyPracticeUseCase,
    GetVocabularyPracticeUseCase,
    StudyWordUseCase,
    ReviewWordUseCase,
    GetVocabularySessionsUseCase,
    
    // Use Cases de Reading (7)
    CreateReadingPracticeUseCase,
    GetReadingPracticeUseCase,
    UpdateReadingProgressUseCase,
    AnswerComprehensionUseCase,
    AddBookmarkUseCase,
    AddVocabularyUseCase,
    GetReadingSessionsUseCase,
    
    // Use Cases de Quiz (5) ← NUEVOS
    CreateQuizPracticeUseCase,
    GetQuizPracticeUseCase,
    AnswerQuestionUseCase,
    GetQuizSessionsUseCase,
    GetQuizCategoriesUseCase,
  ],
})
export class PracticesModule {}
```

---

## 🔄 Proceso de Migración Paso a Paso

### Fase 1: Backend (30-45 min)

```bash
# 1. Copiar entidades si faltan
cp -r Backend/src/domain/entities/practice-*.entity.ts TU_REPO/Backend/src/domain/entities/

# 2. Copiar use cases de Quiz
cp -r Backend/src/application/use-cases/practices/quiz TU_REPO/Backend/src/application/use-cases/practices/

# 3. Copiar controlador de Quiz
cp Backend/src/presentation/controllers/practices/quiz-practice.controller.ts \
   TU_REPO/Backend/src/presentation/controllers/practices/

# 4. Copiar mapper de Quiz
cp Backend/src/presentation/mappers/quiz-practice.mapper.ts \
   TU_REPO/Backend/src/presentation/mappers/

# 5. Copiar migración
cp Backend/src/infrastructure/database/migrations/1763621992929-CreatePracticesTables.ts \
   TU_REPO/Backend/src/infrastructure/database/migrations/

# 6. Actualizar practices.module.ts (ver sección 6 arriba)

# 7. Actualizar app.module.ts y ormconfig.ts con las nuevas entidades

# 8. Ejecutar migración
cd TU_REPO/Backend
npm run migration:run

# 9. Iniciar servidor
npm run start:dev
```

### Fase 2: Frontend (15-20 min)

```bash
# 1. Copiar QuizScreen si no existe o está desactualizado
cp Frontend/lib/screens/quiz_screen.dart TU_REPO/Frontend/lib/screens/

# 2. Actualizar home_screen.dart con los cambios de navegación (ver sección 2)

# 3. Actualizar bottom_navigation.dart con el ícono de chat (ver sección 2)

# 4. Actualizar app_banner.dart con botón de settings (ver sección 2)

# 5. Actualizar cards del Dashboard (ver sección 3)

# 6. Hot restart
cd TU_REPO/Frontend
flutter run
# Presiona 'R' para hot restart
```

---

## ⚠️ PRECAUCIONES ANTI-CORRUPCIÓN

### ❌ NO HAGAS ESTO:
1. ❌ **NO copies archivos masivamente sin revisar**
   - Pueden haber configuraciones específicas de cada repo

2. ❌ **NO ejecutes migraciones sin backup**
   ```bash
   # ANTES de migrar, hacer backup:
   pg_dump -U tu_usuario -d english_app > backup_antes_migracion.sql
   ```

3. ❌ **NO olvides los decoradores @Inject**
   - Cada use case DEBE tener `@Inject('InterfaceName')` en el constructor

4. ❌ **NO agregues providers sin agregar las entidades a TypeORM**
   - Orden: Entidades → TypeORM.forFeature → Providers

5. ❌ **NO cambies index de navegación sin actualizar todos los lugares**
   - Si Quiz es index 3, actualiza: switch case, cards del dashboard, y cualquier navegación directa

### ✅ SÍ HAZLO ASÍ:

1. ✅ **Prueba cada fase por separado:**
   ```bash
   # Backend primero
   npm run start:dev
   # Verifica que compile y arranque
   
   # Luego Frontend
   flutter run
   ```

2. ✅ **Verifica endpoints en Swagger:**
   ```
   http://localhost:3000/api/docs
   Busca: /api/v1/practices/quiz/*
   ```

3. ✅ **Usa git para trackear cambios:**
   ```bash
   git checkout -b feature/quiz-module
   git add .
   git commit -m "Add Quiz module - Phase 1: Backend"
   
   # Si algo falla, puedes revertir:
   git checkout main
   ```

4. ✅ **Prueba navegación después de cada cambio:**
   - Tap en cada botón del bottom nav
   - Verifica que las screens correctas se cargan
   - Prueba swipe horizontal

---

## 🧪 Testing Post-Migración

### Backend:
```bash
# 1. Verifica que el servidor inicie
npm run start:dev

# 2. Busca en los logs:
[RouterExplorer] Mapped {/api/v1/practices/quiz, POST} route
[RouterExplorer] Mapped {/api/v1/practices/quiz/:id, GET} route
[RouterExplorer] Mapped {/api/v1/practices/quiz/:id/answer-question, POST} route
[RouterExplorer] Mapped {/api/v1/practices/quiz/categories, GET} route
[RouterExplorer] Mapped {/api/v1/practices/quiz/user/:userId/sessions, GET} route

# 3. Prueba con curl o Postman:
curl http://localhost:3000/api/v1/practices/quiz/categories
```

### Frontend:
```bash
# 1. Hot restart
flutter run
# Presiona 'R'

# 2. Verifica en logs:
USE_TUNNEL: false
API Base URL: http://10.0.2.2:3000

# 3. Navegación manual:
- Tap en cada ícono del bottom nav
- Verifica que Quiz aparece en index 3
- Verifica que Interview aparece en index 4
- Verifica que Settings aparece en el banner del Dashboard
```

---

## 📝 Checklist Final

### Backend:
- [ ] Entidades copiadas y registradas en TypeORM
- [ ] Use cases de Quiz con decoradores @Inject
- [ ] QuizPracticeController agregado al module
- [ ] QuizPracticeMapper creado
- [ ] Migración ejecutada sin errores
- [ ] PracticesModule registrado en app.module.ts
- [ ] Servidor inicia sin errores
- [ ] Endpoints de Quiz aparecen en logs

### Frontend:
- [ ] QuizScreen actualizado o creado
- [ ] home_screen.dart con 5 índices en PageView
- [ ] bottom_navigation.dart con ícono de chat
- [ ] app_banner.dart con botón de settings
- [ ] Cards del Dashboard apuntan a índices correctos
- [ ] Hot restart ejecutado
- [ ] Navegación funciona (swipe + tap)
- [ ] Settings accesible desde Dashboard

### Testing:
- [ ] Backend responde en /api/v1/practices/quiz/categories
- [ ] Frontend conecta con backend (localhost configurado)
- [ ] Bottom nav tiene 5 botones funcionales
- [ ] Dashboard muestra 4 cards
- [ ] Settings accesible desde ícono en banner

---

## 🆘 Troubleshooting

### Error: "Nest can't resolve dependencies"
```bash
# Causa: Falta decorador @Inject
# Solución: Agregar en el use case:
import { Inject } from '@nestjs/common';
@Inject('IRepositoryName')
```

### Error: "Entity not found in TypeORM"
```bash
# Causa: Entidad no registrada
# Solución: Agregar en app.module.ts:
TypeOrmModule.forRoot({
  entities: [QuizPractice, /* otros */],
})
```

### Error: "Navigation index out of range"
```bash
# Causa: _navigableIndices no actualizado
# Solución: Cambiar a [0, 1, 2, 3, 4]
```

### Error: "Hot reload no refleja cambios"
```bash
# Solución: Hot RESTART (mayúscula R)
flutter run
# Presiona 'R' (mayúscula)
```

---

## 📚 Referencias

- **CAMBIOS_IMPLEMENTADOS.md** - Documentación completa de este repo
- **Swagger UI:** http://localhost:3000/api/docs
- **Flutter DevTools:** http://127.0.0.1:9100

---

**Fecha de creación:** 20 de noviembre de 2025  
**Versión:** 1.0  
**Estado:** Listo para migración
