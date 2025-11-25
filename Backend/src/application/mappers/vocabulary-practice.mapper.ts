/* eslint-disable @typescript-eslint/no-explicit-any */
import { VocabularyPractice } from '../../domain/entities/vocabulary-practice.entity';
import { VocabularyPracticeResponseDto } from '../dtos/vocabulary-practice.dto';

export class VocabularyPracticeMapper {
  static toResponseDto(practice: VocabularyPractice): VocabularyPracticeResponseDto {
    const session = practice.practiceSession;

    const dto: any = {
      id: session.id,
      userId: session.userId,
      chapterId: session.chapterId,
      practiceType: session.practiceType,
      status: session.status,
      score: Number(session.score),
      progress: Number(session.progress),
      maxScore: Number(session.maxScore || 0),
      startedAt: session.startedAt,
      endedAt: session.completedAt,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      wordsStudied: practice.wordsStudied,
      wordsLearned: practice.wordsLearned,
      correctAnswers: practice.correctAnswers,
      totalAttempts: practice.totalAttempts,
      accuracyPercentage:
        practice.totalAttempts > 0 ? (practice.correctAnswers / practice.totalAttempts) * 100 : 0,
      lastWordStudied: practice.lastWordStudied,
      wordsReviewed: practice.wordsReviewed,
      streakCount: practice.streakCount,
      difficultyLevel: practice.difficultyLevel,
      learningRate: practice.wordsLearned > 0 ? practice.wordsLearned / practice.wordsStudied : 0,
      currentWordIndex: practice.currentWordIndex,
      studiedWords: practice.studiedWords,
      reviewedWords: practice.reviewedWords,
      incorrectAnswers: practice.incorrectAnswers,
    };

    return dto;
  }

  static toResponseDtoArray(practices: VocabularyPractice[]): VocabularyPracticeResponseDto[] {
    return practices.map(practice => this.toResponseDto(practice));
  }
}
