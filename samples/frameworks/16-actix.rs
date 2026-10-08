//! Actix Web framework tour.
//!
//! Covers handlers, extractors, application state, middleware,
//! error types, JSON serialisation and scoped routing.

use actix_web::{
    error::ResponseError, get, http::StatusCode, middleware::Logger, post, web, App, HttpResponse,
    HttpServer, Responder,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::RwLock;
use thiserror::Error;

/// The API representation of an article.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Article {
    pub id: u32,
    pub title: String,
    #[serde(default)]
    pub like_count: u32,
    #[serde(skip_serializing_if = "Vec::is_empty", default)]
    pub tags: Vec<String>,
}

/// Errors this API can return.
#[derive(Debug, Error)]
pub enum ApiError {
    #[error("article {id} not found")]
    NotFound { id: u32 },
    #[error("invalid payload: {0}")]
    Invalid(String),
}

impl ResponseError for ApiError {
    fn status_code(&self) -> StatusCode {
        match self {
            ApiError::NotFound { .. } => StatusCode::NOT_FOUND,
            ApiError::Invalid(_) => StatusCode::UNPROCESSABLE_ENTITY,
        }
    }
}

/// Shared application state.
pub struct AppState {
    store: RwLock<HashMap<u32, Article>>,
}

/// Fetch one article by id.
///
/// # Errors
/// Returns [`ApiError::NotFound`] when nothing matches.
#[get("/articles/{id}")]
async fn find_article(
    path: web::Path<u32>,
    state: web::Data<AppState>,
) -> Result<impl Responder, ApiError> {
    let id = path.into_inner();
    let store = state.store.read().unwrap(); // inline comment

    store
        .get(&id)
        .cloned()
        .map(|article| HttpResponse::Ok().json(article))
        .ok_or(ApiError::NotFound { id })
}

#[post("/articles")]
async fn create_article(
    payload: web::Json<Article>,
    state: web::Data<AppState>,
) -> Result<impl Responder, ApiError> {
    if payload.title.trim().is_empty() {
        return Err(ApiError::Invalid("title required".into()));
    }

    let mut store = state.store.write().unwrap();
    let id = store.len() as u32 + 1;
    let article = Article { id, ..payload.into_inner() };
    store.insert(id, article.clone());

    Ok(HttpResponse::Created().json(article))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init();

    let state = web::Data::new(AppState { store: RwLock::new(HashMap::new()) });

    HttpServer::new(move || {
        App::new()
            .app_data(state.clone())
            .wrap(Logger::default())
            .service(web::scope("/api/v1").service(find_article).service(create_article))
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
