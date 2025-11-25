/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  ReadingPracticeResponseDto,
  BookmarkDto,
  VocabularyWordDto,
} from '../dtos/reading-practice.dto';
import { ReadingPractice } from '../../domain/entities/reading-practice.entity';

export class ReadingPracticeMapper {
  static toResponseDto(practice: ReadingPractice): ReadingPracticeResponseDto {
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
      textId: practice.textId,
      textTitle: practice.textTitle,
      totalWords: practice.totalWords,
      wordsRead: practice.wordsRead,
      readingProgress:
        practice.totalWords > 0 ? (practice.wordsRead / practice.totalWords) * 100 : 0,
      readingSpeedWpm: practice.readingSpeedWpm ? Number(practice.readingSpeedWpm) : undefined,
      comprehensionQuestionsTotal: practice.comprehensionQuestionsTotal,
      comprehensionQuestionsCorrect: practice.comprehensionQuestionsCorrect,
      comprehensionScore:
        practice.comprehensionQuestionsTotal > 0
          ? (practice.comprehensionQuestionsCorrect / practice.comprehensionQuestionsTotal) * 100
          : 0,
      readingTimeSeconds: practice.readingTimeSeconds,
      difficultyLevel: practice.difficultyLevel,
      textCategory: practice.textCategory,
      lastPosition: practice.lastPosition,
      estimatedTimeToComplete:
        practice.readingSpeedWpm && practice.totalWords > 0
          ? Math.ceil((practice.totalWords - practice.wordsRead) / Number(practice.readingSpeedWpm))
          : 0,
      bookmarks: (practice.bookmarks || []) as BookmarkDto[],
      vocabularyEncountered: (practice.vocabularyEncountered || []) as VocabularyWordDto[],
    };

    return dto;
  }

  static toResponseDtoArray(practices: ReadingPractice[]): ReadingPracticeResponseDto[] {
    return practices.map(practice => this.toResponseDto(practice));
  }
}
