lexer = require('../lib/lexer')

describe "SQL Lexer", ->
  it "eats select queries", ->
    tokens = lexer.tokenize("select * from my_table")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["EOF", "", 1]
    ]

  it "eats select queries with named values", ->
    tokens = lexer.tokenize("select foo , bar from my_table")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["LITERAL", "foo", 1]
      ["SEPARATOR", ",", 1]
      ["LITERAL", "bar", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["EOF", "", 1]
    ]

  it "eats select queries with named typed values", ->
    tokens = lexer.tokenize("select foo:boolean, bar:number from my_table")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["LITERAL", "foo:boolean", 1]
      ["SEPARATOR", ",", 1]
      ["LITERAL", "bar:number", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["EOF", "", 1]
    ]

  it "eats select queries with with parameter", ->
    tokens = lexer.tokenize("select * from my_table where a = $foo")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["WHERE", "where", 1]
      ["LITERAL", "a", 1]
      ["OPERATOR", "=", 1]
      ["PARAMETER", "foo", 1]
      ["EOF", "", 1]
    ]

  it "eats select queries with with parameter and type", ->
    tokens = lexer.tokenize("select * from my_table where a = $foo:number")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["WHERE", "where", 1]
      ["LITERAL", "a", 1]
      ["OPERATOR", "=", 1]
      ["PARAMETER", "foo:number", 1]
      ["EOF", "", 1]
    ]

  it "eats select queries with stars and multiplication", ->
    tokens = lexer.tokenize("select * from my_table where foo = 1 * 2")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["WHERE", "where", 1]
      ["LITERAL", "foo", 1]
      ["OPERATOR", "=", 1]
      ["NUMBER", "1", 1]
      ["MATH_MULTI", "*", 1]
      ["NUMBER", "2", 1]
      ["EOF", "", 1]
    ]


  it "eats sub selects", ->
    tokens = lexer.tokenize("select * from (select * from my_table) t")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'SELECT', 'select', 1 ]
      [ 'STAR', '*', 1 ]
      [ 'FROM', 'from', 1 ]
      [ 'LITERAL', 'my_table', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      ["LITERAL", "t", 1]
      ["EOF", "", 1]
    ]

  it "eats joins", ->
    tokens = lexer.tokenize("select * from a join b on a.id = b.id")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      [ 'LITERAL', 'a', 1 ]
      [ 'JOIN', 'join', 1 ]
      [ 'LITERAL', 'b', 1 ]
      [ 'ON', 'on', 1 ]
      [ 'LITERAL', 'a', 1 ]
      [ 'DOT', '.', 1 ]
      [ 'LITERAL', 'id', 1 ]
      [ 'OPERATOR', '=', 1 ]
      [ 'LITERAL', 'b', 1 ]
      [ 'DOT', '.', 1 ]
      [ 'LITERAL', 'id', 1 ]
      ["EOF", "", 1]
    ]

  it "eats insert queries", ->
    tokens = lexer.tokenize("insert into my_table values ('a',1)")
    tokens.should.eql [
      ["INSERT", "insert", 1]
      ["INTO", "into", 1]
      ["LITERAL", "my_table", 1]
      ["VALUES", "values", 1]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'STRING', 'a', 1 ]
      [ 'SEPARATOR', ',', 1 ]
      [ 'NUMBER', '1', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      ["EOF", "", 1]
    ]

  it "eats insert queries with default values", ->
    tokens = lexer.tokenize("insert into my_table default values")
    tokens.should.eql [
      ["INSERT", "insert", 1]
      ["INTO", "into", 1]
      ["LITERAL", "my_table", 1]
      ["DEFAULT", "default", 1]
      ["VALUES", "values", 1]
      ["EOF", "", 1]
    ]

  it "eats insert queries with multiple rows", ->
    tokens = lexer.tokenize("insert into my_table values ('a'),('b')")
    tokens.should.eql [
      ["INSERT", "insert", 1]
      ["INTO", "into", 1]
      ["LITERAL", "my_table", 1]
      ["VALUES", "values", 1]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'STRING', 'a', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      [ 'SEPARATOR', ',', 1 ]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'STRING', 'b', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      ["EOF", "", 1]
    ]

  it "eats insert queries with multiple rows and column names", ->
    tokens = lexer.tokenize("insert into my_table (foo) values ('a'),('b')")
    tokens.should.eql [
      ["INSERT", "insert", 1]
      ["INTO", "into", 1]
      ["LITERAL", "my_table", 1]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'LITERAL', 'foo', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      ["VALUES", "values", 1]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'STRING', 'a', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      [ 'SEPARATOR', ',', 1 ]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'STRING', 'b', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      ["EOF", "", 1]
    ]