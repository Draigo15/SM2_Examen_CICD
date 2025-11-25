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
  CreateVocabularyPracticeDto,
  UpdateVocabularyPracticeDto,
  VocabularyPracticeResponseDto,
  VocabularyStatsDto,
  StudyWordDto,
  ReviewWordDto,
} from '../../../application/dtos/vocabulary-practice.dto';

// Use Cases
import {
  CreateVocabularyPracticeUseCase,
  GetVocabularyPracticeUseCase,
  StudyWordUseCase,
  ReviewWordUseCase,
  GetVocabularySessionsUseCase,
} from '../../../application/use-cases/practices/vocabulary';
import { VocabularyPracticeMapper } from '../../../application/mappers/vocabulary-practice.mapper';

@ApiTags('Practices - Vocabulary')
@Controller('practices/vocabulary')
@UseGuards(ThrottlerGuard, EnhancedJwtGuard)
@ApiBearerAuth()
@ApiExtraModels(
  CreateVocabularyPracticeDto,
  UpdateVocabularyPracticeDto,
  VocabularyPracticeResponseDto,
  VocabularyStatsDto,
)
export class VocabularyPracticeController {
  private readonly logger = new Logger(VocabularyPracticeController.name);

  constructor(
    private readonly createVocabularyPracticeUseCase: CreateVocabularyPracticeUseCase,
    private readonly getVocabularyPracticeUseCase: GetVocabularyPracticeUseCase,
    private readonly studyWordUseCase: StudyWordUseCase,
    private readonly reviewWordUseCase: ReviewWordUseCase,
    private readonly getVocabularySessionsUseCase: GetVocabularySessionsUseCase,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create new vocabulary practice session',
    description: 'Start a new vocabulary practice session for the authenticated user',
  })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Vocabulary practice session created successfully',
    schema: {
      $ref: getSchemaPath(VocabularyPracticeResponseDto),
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
  async createVocabularyPractice(
    @Request() req: AuthenticatedRequest,
    @Body() createDto: CreateVocabularyPracticeDto,
  ): Promise<VocabularyPracticeResponseDto> {
    this.logger.log(`Creating vocabulary practice for user: ${req.user.userId}`);

    const practice = await this.createVocabularyPracticeUseCase.execute(req.user.userId as string, createDto);
    return VocabularyPracticeMapper.toResponseDto(practice);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get vocabulary practice session',
    description: 'Retrieve a specific vocabulary practice session by ID',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Vocabulary practice session retrieved successfully',
    schema: {
      $ref: getSchemaPath(VocabularyPracticeResponseDto),
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
  async getVocabularyPractice(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<VocabularyPracticeResponseDto> {
    this.logger.log(`Getting vocabulary practice ${id} for user: ${req.user.userId}`);

    const practice = await this.getVocabularyPracticeUseCase.execute(id, req.user.userId as string);
    return VocabularyPracticeMapper.toResponseDto(practice);
  }

  @Post(':id/study-word')
  @ApiOperation({
    summary: 'Record word study activity',
    description: 'Record that a word has been studied in the vocabulary practice session',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Word study recorded successfully',
    schema: {
      $ref: getSchemaPath(VocabularyPracticeResponseDto),
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
  async studyWord(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() studyWordDto: StudyWordDto,
  ): Promise<VocabularyPracticeResponseDto> {
    this.logger.log(`Recording word study for practice ${id}, user: ${req.user.userId}`);

    const practice = await this.studyWordUseCase.execute(id, req.user.userId as string, studyWordDto);
    return VocabularyPracticeMapper.toResponseDto(practice);
  }

  @Post(':id/review-word')
  @ApiOperation({
    summary: 'Record word review activity',
    description: 'Record that a word has been reviewed in the vocabulary practice session',
  })
  @ApiParam({
    name: 'id',
    description: 'Practice session ID',
    type: 'string',
    format: 'uuid',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Word review recorded successfully',
    schema: {
      $ref: getSchemaPath(VocabularyPracticeResponseDto),
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
  async reviewWord(
    @Request() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() reviewWordDto: ReviewWordDto,
  ): Promise<VocabularyPracticeResponseDto> {
    this.logger.log(`Recording word review for practice ${id}, user: ${req.user.userId}`);

    const practice = await this.reviewWordUseCase.execute(id, req.user.userId as string, reviewWordDto);
    return VocabularyPracticeMapper.toResponseDto(practice);
  }

  @Get('user/:userId/sessions')
  @ApiOperation({
    summary: 'Get user vocabulary practice sessions',
    description: 'Retrieve all vocabulary practice sessions for a specific user',
  })
  @ApiParam({
    name: 'userId',
    description: 'User ID',
    type: 'string',
    format: 'uuid',
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
    description: 'User vocabulary practice sessions retrieved successfully',
    schema: {
      type: 'array',
      items: {
        $ref: getSchemaPath(VocabularyPracticeResponseDto),
      },
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'User not authenticated',
  })
  async getUserVocabularySessions(
    @Request() _req: AuthenticatedRequest,
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number,
  ): Promise<VocabularyPracticeResponseDto[]> {
    this.logger.log(`Getting vocabulary sessions for user: ${userId}`);

    const filters: any = {};
    if (limit !== undefined) filters.limit = limit;
    if (offset !== undefined) filters.offset = offset;

    const practices = await this.getVocabularySessionsUseCase.execute(userId, filters);
    return VocabularyPracticeMapper.toResponseDtoArray(practices);
  }
}
