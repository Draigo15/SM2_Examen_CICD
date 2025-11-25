import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import { PracticeSession } from '../../domain/entities/practice-session.entity';
import { VocabularyPractice } from '../../domain/entities/vocabulary-practice.entity';
import { ReadingPractice } from '../../domain/entities/reading-practice.entity';
import { QuizPractice } from '../../domain/entities/quiz-practice.entity';
import { Chapter } from '../../domain/entities/chapter.entity';
import { UserProgress } from '../../domain/entities/user-progress.entity';
import { VocabularyItem } from '../../domain/entities/vocabulary-item.entity';

// Repositories
import { PracticeSessionRepository } from '../../infrastructure/repositories/practice-session.repository';
import { VocabularyPracticeRepository } from '../../infrastructure/repositories/vocabulary-practice.repository';
import { ReadingPracticeRepository } from '../../infrastructure/repositories/reading-practice.repository';
import { QuizPracticeRepository } from '../../infrastructure/repositories/quiz-practice.repository';
import { ChapterRepository } from '../../infrastructure/repositories/chapter.repository';
import { UserProgressRepository } from '../../infrastructure/repositories/user-progress.repository';
import { VocabularyItemRepository } from '../../infrastructure/repositories/vocabulary-item.repository';

// Vocabulary Use Cases
import {
  CreateVocabularyPracticeUseCase,
  GetVocabularyPracticeUseCase,
  StudyWordUseCase,
  ReviewWordUseCase,
  GetVocabularySessionsUseCase,
} from '../../application/use-cases/practices/vocabulary';

// Reading Use Cases
import {
  CreateReadingPracticeUseCase,
  GetReadingPracticeUseCase,
  UpdateReadingProgressUseCase,
  AnswerComprehensionUseCase,
  AddBookmarkUseCase,
  AddVocabularyUseCase,
  GetReadingSessionsUseCase,
} from '../../application/use-cases/practices/reading';

// Quiz Use Cases
import {
  CreateQuizPracticeUseCase,
  GetQuizPracticeUseCase,
  AnswerQuestionUseCase,
  GetQuizSessionsUseCase,
  GetQuizCategoriesUseCase,
} from '../../application/use-cases/practices/quiz';

// Controllers
import { VocabularyPracticeController } from '../controllers/practices/vocabulary-practice.controller';
import { ReadingPracticeController } from '../controllers/practices/reading-practice.controller';
import { QuizPracticeController } from '../controllers/practices/quiz-practice.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PracticeSession,
      VocabularyPractice,
      ReadingPractice,
      QuizPractice,
      Chapter,
      UserProgress,
      VocabularyItem,
    ]),
  ],
  controllers: [VocabularyPracticeController, ReadingPracticeController, QuizPracticeController],
  providers: [
    // Repositories
    {
      provide: 'IPracticeSessionRepository',
      useClass: PracticeSessionRepository,
    },
    {
      provide: 'IVocabularyPracticeRepository',
      useClass: VocabularyPracticeRepository,
    },
    {
      provide: 'IReadingPracticeRepository',
      useClass: ReadingPracticeRepository,
    },
    {
      provide: 'IQuizPracticeRepository',
      useClass: QuizPracticeRepository,
    },
    {
      provide: 'IChapterRepository',
      useClass: ChapterRepository,
    },
    {
      provide: 'IUserProgressRepository',
      useClass: UserProgressRepository,
    },
    {
      provide: 'IVocabularyItemRepository',
      useClass: VocabularyItemRepository,
    },
    // Vocabulary Use Cases
    CreateVocabularyPracticeUseCase,
    GetVocabularyPracticeUseCase,
    StudyWordUseCase,
    ReviewWordUseCase,
    GetVocabularySessionsUseCase,
    // Reading Use Cases
    CreateReadingPracticeUseCase,
    GetReadingPracticeUseCase,
    UpdateReadingProgressUseCase,
    AnswerComprehensionUseCase,
    AddBookmarkUseCase,
    AddVocabularyUseCase,
    GetReadingSessionsUseCase,
    // Quiz Use Cases
    CreateQuizPracticeUseCase,
    GetQuizPracticeUseCase,
    AnswerQuestionUseCase,
    GetQuizSessionsUseCase,
    GetQuizCategoriesUseCase,
  ],
  exports: [
    // Vocabulary
    CreateVocabularyPracticeUseCase,
    GetVocabularyPracticeUseCase,
    StudyWordUseCase,
    ReviewWordUseCase,
    GetVocabularySessionsUseCase,
    // Reading
    CreateReadingPracticeUseCase,
    GetReadingPracticeUseCase,
    UpdateReadingProgressUseCase,
    AnswerComprehensionUseCase,
    AddBookmarkUseCase,
    AddVocabularyUseCase,
    GetReadingSessionsUseCase,
    // Quiz
    CreateQuizPracticeUseCase,
    GetQuizPracticeUseCase,
    AnswerQuestionUseCase,
    GetQuizSessionsUseCase,
    GetQuizCategoriesUseCase,
  ],
})
export class PracticesModule {}
