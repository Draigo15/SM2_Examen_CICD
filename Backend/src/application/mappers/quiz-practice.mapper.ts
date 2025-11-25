/* eslint-disable @typescript-eslint/no-explicit-any */
import { QuizPractice } from '../../domain/entities/quiz-practice.entity';
import { QuizPracticeResponseDto } from '../dtos/quiz-practice.dto';

export class QuizPracticeMapper {
  static toResponseDto(practice: QuizPractice): QuizPracticeResponseDto {
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
      totalQuestions: practice.totalQuestions,
      questionsAnswered: practice.questionsAnswered,
      correctAnswers: practice.correctAnswers,
      wrongAnswers: practice.wrongAnswers,
      accuracyPercentage:
        practice.questionsAnswered > 0
          ? (practice.correctAnswers / practice.questionsAnswered) * 100
          : 0,
      completionPercentage:
        practice.totalQuestions > 0 ? (practice.questionsAnswered / practice.totalQuestions) * 100 : 0,
      lastQuestionIndex: practice.lastQuestionIndex,
      averageTimePerQuestion: practice.averageTimePerQuestion
        ? Number(practice.averageTimePerQuestion)
        : undefined,
      quizCategory: practice.quizCategory,
      difficultyLevel: practice.difficultyLevel,
      timePerQuestion: practice.timePerQuestion,
      questionResults: practice.questionResults,
    };

    return dto;
  }

  static toResponseDtoArray(practices: QuizPractice[]): QuizPracticeResponseDto[] {
    return practices.map(practice => this.toResponseDto(practice));
  }
}
