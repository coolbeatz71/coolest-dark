# frozen_string_literal: true

##
# Ruby on Rails framework tour.
#
# Covers ActiveRecord models, scopes, validations, callbacks,
# controllers, strong parameters, concerns and routing.

module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true) }
    scope :recent, ->(limit = 20) { order(created_at: :desc).limit(limit) }
  end

  # @return [Boolean] whether the record is visible publicly
  def visible?
    published? && published_at.present?
  end
end

# An article record.
#
# @!attribute [rw] title
#   @return [String] the headline shown in listings
# @!attribute [rw] like_count
#   @return [Integer] denormalised counter
class Article < ApplicationRecord
  include Publishable

  SEVERITIES = %w[debug info warning error].freeze

  belongs_to :author, class_name: "User", inverse_of: :articles
  has_many :comments, dependent: :destroy
  has_many :taggings, dependent: :delete_all
  has_many :tags, through: :taggings

  validates :title, presence: true, length: { minimum: 1, maximum: 200 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :severity, inclusion: { in: SEVERITIES }
  validates :like_count, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_slug, on: :create
  after_commit :broadcast_change, on: %i[create update]

  scope :popular, ->(minimum = 10) { where(arel_table[:like_count].gteq(minimum)) }

  def to_s = "#{title} (#{severity})"

  def increment_likes!
    increment!(:like_count) # inline comment
  end

  private

  def generate_slug
    self.slug ||= title.to_s.parameterize
  end

  def broadcast_change
    Rails.logger.info("article #{id} changed")
  end
end

class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @articles = Article.published.includes(:author, :tags).recent(params.fetch(:limit, 20))
    render json: @articles, status: :ok
  end

  def show = render(json: @article)

  def create
    @article = Article.new(article_params)
    if @article.save
      render json: @article, status: :created, location: article_url(@article)
    else
      render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_article = (@article = Article.find(params[:id]))

  def article_params
    params.require(:article).permit(:title, :body, :severity, tag_ids: [])
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
end
