import std/times
import pkg/mike

import ../db
import ../utils

import ./profile

type
  Tag = distinct string
  ArticleResp = object
    slug: string
    title: string
    description: string
    body: string
    tagList: seq[Tag]
    createdAt: DateTime
    updatedAt: DateTime
    favorited: bool
    favoritesCount: int
    author: Profile
  Articles = object
    articles: seq[ArticleResp]
    articlesCount: int
  NewArticle = object
    title: string
    description: string
    body: string
    tagList: seq[Tag]
  UpdateArticle = object
    title: string
    description: string
    body: string

"/articles/feed" -> get(
    offset: Query[Option[int]],
    limit: Query[Option[int]],
    user: User
):
  ## Get most recent articles from users you follow.
  ## Use query parameters to limit.

"/articles" -> get(
    offset: Query[Option[int]],
    limit: Query[Option[int]],
    user: Option[User]
):
  ## Get most recent articles globally.
  ## Use query parameters to filter results.

"/articles" -> post(user: User, data: Json[NewArticle]):
  ## Create an article.

"/articles/:slug" -> get(user: Option[User], slug: string):
  ## Get an article

"/articles/:slug" -> put(
    user: Option[User], slug: string, data: Json[UpdateArticle]
):
  ## Update an article.

"/articles/:slug" -> delete(user: Option[User], slug: string):
  ## Delete an article.
