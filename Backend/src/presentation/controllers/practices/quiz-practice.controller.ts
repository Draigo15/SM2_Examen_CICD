/* eslint-disable */
import {
  Controller,
  Post,
  Get,
  Param,
  Body,
  UseGuards,
  Request,
  Logger,
  HttpStatus,
  HttpCode,
  ParseUUIDPipe,
  Query,
} from '@nestjs/common';

import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiExtraModels,
  getSchemaPath,
} from '@nestjs/swagger';
import { ThrottlerGuard } from '@nestjs/throttler';
import { EnhancedJwtGuard } from '../../../shared/guards/enhanced-jwt.guard';
import { AuthenticatedRequest } from '../../../shared/types/request.types';

// DTOs
import {
  CreateQuizPracticeDto,
  UpdateQuizPracticeDto,
  QuizPracticeResponseDto,
  QuizStatsDto,
  AnswerQuizQuestionDto,
} from '../../../application/dtos/quiz-practice.dto';

// Use Cases
import {
  CreateQuizPracticeUseCase,
  GetQuizPracticeUseCase,
  AnswerQuestionUseCase,
  GetQuizSessionsUseCase,
  GetQuizCategoriesUseCase,
} from '../../../application/use-cases/practices/quiz';
import { QuizPracticeMapper } from '../../../application/mappers/quiz-practice.mapper';

@ApiTags('Practices - Quiz')
@Controller('practices/quiz')
@UseGuards(ThrottlerGuard, EnhancedJwtGuard)
@ApiBearerAuth()
@ApiExtraModels(CreateQuizPracticeDto, UpdateQuizPracticeDto, QuizPracticeResponseDto, QuizStatsDto)
export class QuizPracticeController {
  private readonly logger = new Logger(QuizPracticeController.name);

  constructor(
    private readonly createQuizPracticeUseCase: CreateQuizPracticeUseCase,
    private readonly getQuizPracticeUseCase: GetQuizPracticeUseCase,
    private readonly answerQuestionUseCase: AnswerQuestionUseCase,
    private readonly getQuizSessionsUseCase: GetQuizSessionsUseCase,
    private readonly getQuizCategoriesUseCase: GetQuizCategoriesUseCase,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create new quiz practice session',
    description: 'Start a new quiz practice session for the authenticated user',
  })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Quiz practice session created successfully',
    schema: {
      $ref: getSchemaPath(QuizPracticeResponseDto),
    },
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Invalid input data',
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'User not authenticated',
  })
  async createQuizPractice(
    @Request() req: AuthenticatedRequest,
    @Body() createDto: CreateQuizPracticeDto,
  ): Promise<QuizPracticeResponseDto> {
    this.logger.log(`Creating quiz practice for user: ${req.user.userId}`);

    const practice = await this.createQuizPracticeUseCase.execute(req.user.userId as string, createDto);
    return QuizPracticeMapper.toResponseDto(practice);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get quiz practice session',
    description: 'Retrieve a specific quiz practice session by ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Quiz practice session retrieved successfully',
    schema: {
      $ref: getSchemaPath(QuizPracticeResponseDto),
    },
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Practice session not found',
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'User not authenticated',
  })
  async getQuizPractice(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<QuizPracticeResponseDto> {
    this.logger.log(`Getting quiz practice ${id} for user: ${req.user.userId}`);

    const practice = await this.getQuizPracticeUseCase.execute(id, req.user.userId as string);
    return QuizPracticeMapper.toResponseDto(practice);
  }

  @Post(':id/answer-question')
  @ApiOperation({
    summary: 'Answer quiz question',
    description: 'Record an answer to a quiz question and update practice progress',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Question answer recorded successfully',
    schema: {
      $ref: getSchemaPath(QuizPracticeResponseDto),
    },
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Practice session not found',
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Invalid question data or quiz already completed',
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'User not authenticated',
  })
  async answerQuestion(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() answerDto: AnswerQuizQuestionDto,
  ): Promise<QuizPracticeResponseDto> {
    this.logger.log(
      `Recording answer for quiz ${id}, question ${answerDto.questionIndex}, user: ${req.user.userId}`,
    );

    const practice = await this.answerQuestionUseCase.execute(id, req.user.userId as string, answerDto);
    return QuizPracticeMapper.toResponseDto(practice);
  }

  @Get('user/:userId/sessions')
  @ApiOperation({
    summary: 'Get user quiz practice sessions',
    description: 'Retrieve all quiz practice sessions for a specific user',
  })
  @ApiParam({
    name: 'userId',
    description: 'User ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiQuery({
    name: 'category',
    description: 'Filter by quiz category',
    type: 'string',
    required: false,
  })
  @ApiQuery({
    name: 'difficulty',
    description: 'Filter by difficulty level',
    type: 'string',
    required: false,
  })
  @ApiQuery({
    name: 'limit',
    description: 'Number of sessions to retrieve',
    type: 'number',
    required: false,
    example: 10,
  })
  @ApiQuery({
    name: 'offset',
    description: 'Number of sessions to skip',
    type: 'number',
    required: false,
    example: 0,
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'User quiz practice sessions retrieved successfully',
    schema: {
      type: 'array',
      items: {
        $ref: getSchemaPath(QuizPracticeResponseDto),
      },
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'User not authenticated',
  })
  async getUserQuizSessions(
    @Request() _req: AuthenticatedRequest,
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query('category') category?: string,
    @Query('difficulty') difficultyLevel?: string,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number,
  ): Promise<QuizPracticeResponseDto[]> {
    this.logger.log(`Getting quiz sessions for user: ${userId}`);

    const filters: any = {};
    if (category) filters.category = category;
    if (difficultyLevel) filters.difficultyLevel = difficultyLevel;
    if (limit !== undefined) filters.limit = limit;
    if (offset !== undefined) filters.offset = offset;

    const practices = await this.getQuizSessionsUseCase.execute(userId, filters);
    return QuizPracticeMapper.toResponseDtoArray(practices);
  }

  @Get('categories')
  @ApiOperation({
    summary: 'Get available quiz categories',
    description: 'Retrieve list of available quiz categories',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Quiz categories retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          category: {
            type: 'string',
            example: 'grammar',
          },
          displayName: {
            type: 'string',
            example: 'Grammar',
          },
          description: {
            type: 'string',
            example: 'English grammar exercises',
          },
          totalQuizzes: {
            type: 'number',
            example: 25,
          },
        },
      },
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'User not authenticated',
  })
  async getQuizCategories(@Request() _req: AuthenticatedRequest): Promise<
    Array<{
      category: string;
      displayName: string;
      description: string;
      totalQuizzes: number;
    }>
  > {
    this.logger.log(`Getting quiz categories`);

    return this.getQuizCategoriesUseCase.execute();
  }
}
