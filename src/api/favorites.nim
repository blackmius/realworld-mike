import std/times
import pkg/mike

import ../db
import ../utils

"/articles/:slug/favorite" -> post(user: User, slug: string):
  ## Favorite an article

"/articles/:slug/favorite" -> delete(user: User, slug: string):
  ## Unfavorite an article
