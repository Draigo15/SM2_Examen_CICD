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
  CreateReadingPracticeDto,
  UpdateReadingPracticeDto,
  ReadingPracticeResponseDto,
  ReadingStatsDto,
  UpdateReadingProgressDto,
  AnswerComprehensionQuestionDto,
  AddBookmarkDto,
  AddVocabularyWordDto,
} from '../../../application/dtos/reading-practice.dto';

// Use Cases
import {
  CreateReadingPracticeUseCase,
  GetReadingPracticeUseCase,
  UpdateReadingProgressUseCase,
  AnswerComprehensionUseCase,
  AddBookmarkUseCase,
  AddVocabularyUseCase,
  GetReadingSessionsUseCase,
} from '../../../application/use-cases/practices/reading';
import { ReadingPracticeMapper } from '../../../application/mappers/reading-practice.mapper';

@ApiTags('Practices - Reading')
@Controller('practices/reading')
@UseGuards(ThrottlerGuard, EnhancedJwtGuard)
@ApiBearerAuth()
@ApiExtraModels(
  CreateReadingPracticeDto,
  UpdateReadingPracticeDto,
  ReadingPracticeResponseDto,
  ReadingStatsDto,
)
export class ReadingPracticeController {
  private readonly logger = new Logger(ReadingPracticeController.name);

  constructor(
    private readonly createReadingPracticeUseCase: CreateReadingPracticeUseCase,
    private readonly getReadingPracticeUseCase: GetReadingPracticeUseCase,
    private readonly updateReadingProgressUseCase: UpdateReadingProgressUseCase,
    private readonly answerComprehensionUseCase: AnswerComprehensionUseCase,
    private readonly addBookmarkUseCase: AddBookmarkUseCase,
    private readonly addVocabularyUseCase: AddVocabularyUseCase,
    private readonly getReadingSessionsUseCase: GetReadingSessionsUseCase,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create new reading practice session',
    description: 'Start a new reading practice session for the authenticated user',
  })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Reading practice session created successfully',
    schema: {
      $ref: getSchemaPath(ReadingPracticeResponseDto),
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
  async createReadingPractice(
    @Request() req: AuthenticatedRequest,
    @Body() createDto: CreateReadingPracticeDto,
  ): Promise<ReadingPracticeResponseDto> {
    this.logger.log(`Creating reading practice for user: ${req.user.userId}`);

    const practice = await this.createReadingPracticeUseCase.execute(req.user.userId as string, createDto);
    return ReadingPracticeMapper.toResponseDto(practice);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get reading practice session',
    description: 'Retrieve a specific reading practice session by ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Reading practice session retrieved successfully',
    schema: {
      $ref: getSchemaPath(ReadingPracticeResponseDto),
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
  async getReadingPractice(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ReadingPracticeResponseDto> {
    this.logger.log(`Getting reading practice ${id} for user: ${req.user.userId}`);

    const practice = await this.getReadingPracticeUseCase.execute(id, req.user.userId as string);
    return ReadingPracticeMapper.toResponseDto(practice);
  }

  @Post(':id/update-progress')
  @ApiOperation({
    summary: 'Update reading progress',
    description: 'Update the reading progress including words read and time spent',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Reading progress updated successfully',
    schema: {
      $ref: getSchemaPath(ReadingPracticeResponseDto),
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
  async updateReadingProgress(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() progressDto: UpdateReadingProgressDto,
  ): Promise<ReadingPracticeResponseDto> {
    this.logger.log(`Updating reading progress for practice ${id}, user: ${req.user.userId}`);

    const practice = await this.updateReadingProgressUseCase.execute(id, req.user.userId as string, progressDto);
    return ReadingPracticeMapper.toResponseDto(practice);
  }

  @Post(':id/answer-comprehension')
  @ApiOperation({
    summary: 'Answer comprehension question',
    description: 'Record an answer to a reading comprehension question',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Comprehension answer recorded successfully',
    schema: {
      $ref: getSchemaPath(ReadingPracticeResponseDto),
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
  async answerComprehensionQuestion(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() answerDto: AnswerComprehensionQuestionDto,
  ): Promise<ReadingPracticeResponseDto> {
    this.logger.log(`Recording comprehension answer for practice ${id}, user: ${req.user.userId}`);

    const practice = await this.answerComprehensionUseCase.execute(id, req.user.userId as string, answerDto);
    return ReadingPracticeMapper.toResponseDto(practice);
  }

  @Post(':id/add-bookmark')
  @ApiOperation({
    summary: 'Add bookmark',
    description: 'Add a bookmark to the reading practice session',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Bookmark added successfully',
    schema: {
      $ref: getSchemaPath(ReadingPracticeResponseDto),
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
  async addBookmark(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() bookmarkDto: AddBookmarkDto,
  ): Promise<ReadingPracticeResponseDto> {
    this.logger.log(`Adding bookmark for practice ${id}, user: ${req.user.userId}`);

    const practice = await this.addBookmarkUseCase.execute(id, req.user.userId as string, bookmarkDto);
    return ReadingPracticeMapper.toResponseDto(practice);
  }

  @Post(':id/add-vocabulary')
  @ApiOperation({
    summary: 'Add vocabulary word',
    description: 'Add a vocabulary word encountered during reading',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Vocabulary word added successfully',
    schema: {
      $ref: getSchemaPath(ReadingPracticeResponseDto),
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
  async addVocabularyWord(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() vocabularyDto: AddVocabularyWordDto,
  ): Promise<ReadingPracticeResponseDto> {
    this.logger.log(`Adding vocabulary word for practice ${id}, user: ${req.user.userId}`);

    const practice = await this.addVocabularyUseCase.execute(id, req.user.userId as string, vocabularyDto as any);
    return ReadingPracticeMapper.toResponseDto(practice);
  }

  @Get('user/:userId/sessions')
  @ApiOperation({
    summary: 'Get user reading practice sessions',
    description: 'Retrieve all reading practice sessions for a specific user',
  })
  @ApiParam({
    name: 'userId',
    description: 'User ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiQuery({
    name: 'category',
    description: 'Filter by text category',
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
    name: 'completed',
    description: 'Filter by completion status',
    type: 'boolean',
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
    description: 'User reading practice sessions retrieved successfully',
    schema: {
      type: 'array',
      items: {
        $ref: getSchemaPath(ReadingPracticeResponseDto),
      },
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'User not authenticated',
  })
  async getUserReadingSessions(
    @Request() _req: AuthenticatedRequest,
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query('category') textCategory?: string,
    @Query('difficulty') difficultyLevel?: string,
    @Query('completed') completed?: boolean,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number,
  ): Promise<ReadingPracticeResponseDto[]> {
    this.logger.log(`Getting reading sessions for user: ${userId}`);

    const filters: any = {};
    if (textCategory) filters.textCategory = textCategory;
    if (difficultyLevel) filters.difficultyLevel = difficultyLevel;
    if (completed !== undefined) filters.completed = completed;
    if (limit !== undefined) filters.limit = limit;
    if (offset !== undefined) filters.offset = offset;

    const result = await this.getReadingSessionsUseCase.execute(userId, filters);
    return ReadingPracticeMapper.toResponseDtoArray(result.sessions);
  }
}
