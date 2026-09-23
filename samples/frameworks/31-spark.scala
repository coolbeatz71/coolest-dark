package frameworktour.spark

import org.apache.spark.sql.{DataFrame, Dataset, SparkSession}
import org.apache.spark.sql.functions.*
import org.apache.spark.sql.types.{IntegerType, StringType, StructField, StructType, TimestampType}
import org.apache.spark.storage.StorageLevel

/** Apache Spark framework tour (Scala).
  *
  * Covers SparkSession, schemas, Datasets, DataFrames, typed
  * transformations, window functions, UDFs, joins and caching.
  */
object ArticleAnalytics:

  /** Typed row for the strongly-typed Dataset API. */
  final case class Article(
      id: Long,
      title: String,
      severity: String,
      likeCount: Int,
      authorId: Long
  )

  final case class AuthorSummary(authorId: Long, total: Long, avgLikes: Double)

  /** Explicit schema avoids an inference pass over the input. */
  val articleSchema: StructType = StructType(
    Seq(
      StructField("id", IntegerType, nullable = false),
      StructField("title", StringType, nullable = false),
      StructField("severity", StringType, nullable = false),
      StructField("like_count", IntegerType, nullable = true),
      StructField("created_at", TimestampType, nullable = true)
    )
  )

  /** A user defined function registered with the SQL engine. */
  val describe: org.apache.spark.sql.expressions.UserDefinedFunction =
    udf { (count: Int, severity: String) =>
      (count, severity) match
        case (0, _)              => "empty"
        case (_, "error")        => "failing"
        case (n, _) if n > 100   => "busy"
        case _                   => "ok"
    }

  def main(args: Array[String]): Unit =
    given spark: SparkSession = SparkSession
      .builder()
      .appName("article-analytics")
      .config("spark.sql.shuffle.partitions", "200")
      .config("spark.sql.adaptive.enabled", value = true)
      .getOrCreate()

    import spark.implicits.*

    spark.udf.register("describe", describe)

    val raw: DataFrame = spark.read
      .schema(articleSchema)
      .option("header", value = true)
      .option("mode", "PERMISSIVE")
      .csv(args.headOption.getOrElse("s3a://logs/articles/*.csv"))

    val articles: Dataset[Article] = raw
      .withColumnRenamed("like_count", "likeCount")
      .na.fill(Map("likeCount" -> 0))
      .withColumn("authorId", lit(0L))
      .as[Article] // inline comment: typed from here on

    val severe = articles
      .filter(a => a.severity == "error" || a.severity == "warning")
      .persist(StorageLevel.MEMORY_AND_DISK)

    // Window function: rank articles within each severity bucket.
    val window = org.apache.spark.sql.expressions.Window
      .partitionBy($"severity")
      .orderBy($"likeCount".desc)

    val ranked = severe
      .withColumn("rank", row_number().over(window))
      .withColumn("state", describe($"likeCount", $"severity"))
      .filter($"rank" <= 10)

    val summaries: Dataset[AuthorSummary] = articles
      .groupBy($"authorId")
      .agg(count("*").as("total"), avg($"likeCount").as("avgLikes"))
      .as[AuthorSummary]

    ranked
      .join(broadcast(summaries), Seq("authorId"), "left_outer")
      .orderBy($"severity", $"rank")
      .write
      .mode("overwrite")
      .partitionBy("severity")
      .parquet("s3a://warehouse/article_ranked/")

    severe.unpersist()
    spark.stop()
