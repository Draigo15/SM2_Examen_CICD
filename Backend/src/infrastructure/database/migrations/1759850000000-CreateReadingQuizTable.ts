import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReadingQuizTable1759850000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "reading_quizzes" (
        "id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
        "reading_content_id" uuid NOT NULL,
        "title" varchar(255) NOT NULL,
        "description" text,
        "total_questions" integer NOT NULL DEFAULT 0,
        "passing_score" integer NOT NULL DEFAULT 0,
        "questions" jsonb NOT NULL DEFAULT '[]'::jsonb,
        "is_active" boolean NOT NULL DEFAULT true,
        "time_limit" integer NOT NULL DEFAULT 0,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT "FK_reading_quizzes_contents" FOREIGN KEY ("reading_content_id")
          REFERENCES "reading_contents"("id") ON DELETE CASCADE
      );
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_reading_quizzes_contentId" ON "reading_quizzes" ("reading_content_id");
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_reading_quizzes_contentId"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "reading_quizzes"`);
  }
}
