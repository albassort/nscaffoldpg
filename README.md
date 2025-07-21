# nscaffolderpg
This is a simple tool that helped me develop faster with postgres; its specifically designed with [cheapormPG](https://github.com/albassort/cheapormPG) in mind. 

This is a database scaffolder, it takes in a postgres schema and attempts to output Nim object classes. This is useful, so specifically, your type definitions does not conflict with the schema itself, potentially causing type casting issues.

# Usage 
```
usage:
  Param 1: Databse Location
  Param 2: Username
  Param 3: Database Password
  Param 4: Database
  Param 5: Schema (e.g public; etc;)
```
e.g 
```sh
# Using unix-sockets
$: nscaffolderpg /run/postgresql/ user password mydatabase public > public.nim
```

output example:


```nim
type
  users* = object
    rowid*: int64
    userid*: string
    displayname*: string
    username*: string
    password*: seq[byte]
    saltiv*: seq[byte]
    accountcreationtime*: DateTime
    email*: string
    idverified*: bool
    isactive*: bool
    isadminprotected*: bool
    pgppubkey*: Option[string]
    specialroles*: seq[string]
    promocodesowned*: seq[string]
    promocode*: Option[string]
    influencer*: bool
    influencerlinks*: JsonNode

```

NOTE: the specific formatting will not be kept because postgres currently does not keep them!

# Warning
This wont install currently if you just download the git and run nimble install, because the dependencies are currently not on nimble, you will need to go to my github and get the deps. 
