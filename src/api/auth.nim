import std/[sysrand, base64]

import pkg/mike

import ../db
import ../utils

type
  UserResp = object
    email: string
    token: string
    username: string
    bio: string
    image: string
  LoginUser = object
    username: string
    password: string
  NewUser = object
    username: string
    email: string
    password: string
  UpdateUser = object
    email: Option[string]
    password: Option[string]
    username: Option[string]
    bio: Option[string]
    image: Option[string]

proc updateToken(user: var User) =
  user.token = base64.encode(urandom(16))
  dbConn.exec(
    sql"UPDATE User SET token = ? where id = ?",
    user.token, user.id)

"/users/login" -> post(data: Json[LoginUser]):
  ## Login for existing user

  let existed = dbConn.find(Option[User],
    sql"SELECT * FROM User WHERE username = ? and password = ?",
    data.username, data.password)

  if existed.isNone:
    raise (ref BadRequestError)(
      msg: "username or password is incorrect", status: Http401)
  var user = existed.get()
  user.updateToken()

  ctx.send(UserResp(
    username: user.username,
    email: user.email,
    token: user.token,
    bio: user.bio,
    image: user.image), Http200)

"/users" -> post(data: Json[NewUser]):
  ## Register a new user
  
  if data.username == "":
    raise (ref BadRequestError)(
      msg: "username cannot be empty", status: Http422)
  if data.password == "":
    raise (ref BadRequestError)(
      msg: "password cannot be empty", status: Http422)
  if data.email == "":
    raise (ref BadRequestError)(
      msg: "email cannot be empty", status: Http422)

  let existed = dbConn.find(Option[User],
    sql"SELECT * FROM User WHERE username = ?", data.username)
  if existed.isSome:
    raise (ref BadRequestError)(
      msg: "User with such username has already existed", status: Http422)

  var user = User(
    username: data.username,
    email: data.email,
    password: data.password)
  user.id = dbConn.insertId(user)
  user.updateToken()

  ctx.send(UserResp(
    username: user.username,
    email: user.email,
    token: user.token), Http201)

"/user" -> get(user: User):
  ## Gets the currently logged-in user
  ctx.send(UserResp(
    username: user.username,
    email: user.email,
    token: user.token,
    bio: user.bio,
    image: user.image))

"/user" -> put(u: User, data: Json[UpdateUser]):
  ## Updated user information for current user
  var user = u  # hack because `u: var User` not working
  if data.username.isSome:
    user.username = data.username.get()
  if data.password.isSome:
    user.password = data.password.get()
  if data.email.isSome:
    user.email = data.email.get()
  if data.bio.isSome:
    user.bio = data.bio.get()
  if data.image.isSome:
    user.image = data.image.get()
  dbConn.upsert(user)
  ctx.send(UserResp(
    username: user.username,
    email: user.email,
    token: user.token,
    bio: user.bio,
    image: user.image))