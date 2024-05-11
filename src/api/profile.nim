import pkg/mike

import ../db
import ../utils

type Profile* = object
  username*: string
  bio*: string
  image*: string
  following*: bool

proc findFollowe(username: string): User =
  let u = dbConn.find(Option[User],
    sql"SELECT * from User WHERE username = ?", username)
  if u.isNone:
    raise (ref NotFoundError)(msg: "profile not found")
  let uu = u.get()

"/profiles/:username" -> get(username: string, user: User):
  ## Get a profile of a user of the system.
  let u = findFollowe(username)
  let following = dbConn.exists(Follow(user: u.id, follower: user.id))
  ctx.send Profile(
    username: username,
    bio: u.bio,
    image: u.image,
    following: following)

"/profiles/:username/follow" -> post(username: string, user: User):
  ## Follow a user by username
  let u = findFollowe(username)
  dbConn.upsert(Follow(user: u.id, follower: user.id))
  ctx.send Profile(
    username: username,
    bio: u.bio,
    image: u.image,
    following: true)

"/profiles/:username/unfollow" -> delete(username: string, user: User):
  ## Unfollow a user by username
  let u = findFollowe(username)
  dbConn.delete(Follow(user: u.id, follower: user.id))
  ctx.send Profile(
    username: username,
    bio: u.bio,
    image: u.image,
    following: false)