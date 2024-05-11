import pkg/mike
import pkg/ponairi

type User* = object
  id* {.primary, autoIncrement.}: int64
  email*: string
  username*: string
  password*: string
  token*: string
  bio*: string
  image*: string

type Follow* = object
  user* {.primary, references: User.id.}: int64
  follower* {.primary, references: User.id.}: int64

let dbConn* = newConn(":memory:")
dbConn.create(User, Follow)

export ponairi
export User