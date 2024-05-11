import pkg/mike
import ./db

proc getUserByToken(token: string): Option[User] {.inline.} =
  return dbConn.find(Option[User],
    sql"SELECT * FROM User WHERE token = ?", token)

proc fromRequest*[T: User](ctx: Context, name: string, _: typedesc[T]): T =
  if not ctx.hasHeader("Authorization"):
    raise (ref BadRequestError)(
      msg: "autherization header required", status: Http401)
  let auth = ctx.getHeader("Authorization")
  let existed = getUserByToken(auth)
  if existed.isNone:
    raise (ref BadRequestError)(msg: "bad token", status: Http401)
  return existed.get()

proc fromRequest*[T: Option[User]](ctx: Context, name: string, _: typedesc[T]): T =
  if not ctx.hasHeader("Authorization"):
    return none(User)
  let auth = ctx.getHeader("Authorization")
  return getUserByToken(auth)
