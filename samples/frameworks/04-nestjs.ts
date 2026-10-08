import {
  Body,
  Controller,
  Get,
  HttpStatus,
  Inject,
  Injectable,
  NotFoundException,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from "@nestjs/common";
import { ApiOperation, ApiResponse, ApiTags } from "@nestjs/swagger";
import { IsInt, IsOptional, IsString, Min } from "class-validator";

/**
 * NestJS framework tour.
 *
 * Covers modules, controllers, providers, DTOs with validation,
 * guards, decorators, dependency injection and Swagger metadata.
 */

export class CreateArticleDto {
  @IsString()
  readonly title!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  readonly likeCount?: number;
}

export interface Article {
  id: number;
  title: string;
  likeCount: number;
}

export const ARTICLE_STORE = Symbol("ARTICLE_STORE");

@Injectable()
export class ArticleService {
  constructor(@Inject(ARTICLE_STORE) private readonly store: Map<number, Article>) {}

  /**
   * Finds one article.
   * @param id - the identifier to look up
   * @throws {NotFoundException} when nothing matches
   */
  async findById(id: number): Promise<Article> {
    const article = this.store.get(id);
    if (!article) throw new NotFoundException(`article ${id} not found`); // inline comment
    return article;
  }

  async findAll(limit = 20): Promise<Article[]> {
    return [...this.store.values()].slice(0, limit);
  }

  async create(dto: CreateArticleDto): Promise<Article> {
    const id = this.store.size + 1;
    const article: Article = { id, title: dto.title, likeCount: dto.likeCount ?? 0 };
    this.store.set(id, article);
    return article;
  }
}

@ApiTags("articles")
@Controller("articles")
export class ArticleController {
  constructor(private readonly service: ArticleService) {}

  @Get()
  @ApiOperation({ summary: "List articles" })
  @ApiResponse({ status: HttpStatus.OK, description: "The articles." })
  findAll(@Query("limit", ParseIntPipe) limit = 20): Promise<Article[]> {
    return this.service.findAll(limit);
  }

  @Get(":id")
  findOne(@Param("id", ParseIntPipe) id: number): Promise<Article> {
    return this.service.findById(id);
  }

  @Post()
  create(@Body() dto: CreateArticleDto): Promise<Article> {
    return this.service.create(dto);
  }
}
