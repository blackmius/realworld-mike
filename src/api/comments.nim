import std/times
import pkg/mike

import ../db
import ../utils

import ./profile

type
  Comment = object
    id: int64
    createdAt: DateTime
    updatedAt: DateTime
    body: string
    author: Profile
  NewComment = object
    body: string

"/articles/:slug/comments" -> get(user: Option[User], slug: string):
  ## Get the comments for an article.

"/articles/:slug/comments" -> post(
    user: User, data: Json[NewComment], slug: string
):
  ## Create a comment for an article.

"/articles/:slug/comments/:id" -> delete(
    user: User, slug: string, id: string
):
  ## Delete a comment for an article. 