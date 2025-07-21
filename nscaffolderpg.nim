import tables
import sugar
import sequtils
import cheapormPG
import groupby
import strformat
import pretty
import std/algorithm
import sets
import strutils
import std/cmdline
import db_connector/db_postgres

const help = """
usage:
  Param 1: Databse Location
  Param 2: Username
  Param 3: Database Password
  Param 4: Database
  Param 5: Schema (e.g public; etc;)
"""

let params =  commandLineParams()
if params.len != 5: 
  stderr.write "Invalid number of paramaters"
  stderr.write help
  quit(1)

let dbLocation = params[0]
let userName = params[1]
let dbPassword = params[2]
let database = params[3]
let schema = params[4]

let db = 
  try:
    db_postgres.open(dbLocation, userName, dbPassword, database)
  except: 
    stderr.write "Failed to connect to the database. Make sure you're using the CLI params correctly" 
    stderr.write help   
    quit(1)


let tableInfo = fastRowsTyped[(string, string, string, bool, int)](db, sql"""
SELECT table_name, column_name, data_type, is_nullable, ordinal_position
  FROM information_schema.columns
  WHERE table_schema = ? ;
""", schema).toSeq().map(x=> x.get()).groupBy(x=> x[0], x=> (x[1], x[2], x[3], x[4]))

let oneWordTypes =
  {"ARRAY" : "seq[string]", "text" : "string", "json" : "JsonNode", "inet" : "string", "bytea" : "seq[byte]", "boolean" : "bool", "integer" : "int64",  "decimal" : "float64", "uuid" : "string", "numeric" : "float64", "token" : "string", "character varying" : "string", "timestamp without time zone" : "DateTime"}.toTable()
let importsTable = {"DateTime" : "import std/times", "JsonNode" : "import std/json" }.toTable()
let restrictedNameConvert = {"type" : "typeOf"}.toTable()
var imports : HashSet[string]
var result = @["type"]
for (table, data) in tableInfo.pairs:
  let ordered = data.sorted((x,y)=> system.cmp(x[3], y[3]))
  result.add &"  {table}* = object"
  for column in ordered:
    let colName =
      if column[0] in restrictedNameConvert:
        restrictedNameConvert[column[0]]
      else:
        column[0]

    if column[1] in oneWordTypes:
      let ormType = oneWordtypes[column[1]]
      if ormType in importsTable:
        imports.incl importsTable[ormType]
      if column[2] == true:
        imports.incl("import std/options")
        result.add &"    {colName}*: Option[{oneWordTypes[column[1]]}]"
      else:
        result.add &"    {colName}*: {oneWordTypes[column[1]]}"
    else:
      echo "NOT FOUND:"
      echo column[1]

if result.len == 1:
  stderr.write "it seems we've failed to read any results. Make sure that you're correctly using the CLI"
  stderr.write help
  quit(1)

echo imports.toSeq().join("\n")

echo result.join("\n")

