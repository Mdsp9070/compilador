defmodule Lisper.Token do
  @enforce_keys [:type, :literal, :line]
  defstruct [:type, :literal, :line]

  @keywords %{
    "defun" => :function,
    "lambda" => :lambda,
    "if" => :if,
    "t" => true,
    "nil" => nil,
    "max" => :max,
    "min" => :min,
    "mod" => :mod,
    "rem" => :rem,
    "incf" => :incf,
    "decf" => :decf,
    "and" => :and,
    "or" => :or,
    "not" => :not,
    "defvar" => :defvar,
    "write" => :write,
    "vector" => :vector
  }

  @types %{
    illegal: "ILLEGAL",
    eof: "EOF",
    # identifiers
    string: "STRING",
    atom: "ATOM",
    # operators
    plus: "+",
    minus: "-",
    asterisk: "*",
    slash: "/",
    equal: "=",
    not_eq: "/=",
    gt: ">",
    lt: "<",
    gt_eq: ">=",
    lt_eq: "<=",
    max: "MAX",
    min: "MIN",
    mod: "MODULUS",
    rem: "REMAINDER",
    incf: "INCREMENT",
    decf: "DECREMENT",
    and: "AND",
    or: "OR",
    not: "NOT",
    # delimiters
    dot: ".",
    lparen: "(",
    rparen: ")",
    # keywords
    function: "FUNCTION",
    t: "TRUE",
    nil: "NIL",
    if: "IF",
    lambda: "LAMBDA",
    setq: "ASSIGN",
    defvar: "DEFVAR",
    write: "WRITE",
    vector: "VECTOR"
  }

  def new(type: type, literal: literal, line: line) when is_atom(type) and is_binary(literal) do
    if Map.has_key?(@types, type) do
      %__MODULE__{type: type, literal: literal, line: line}
    else
      raise "Token with type #{inspect(type)} is not defined!"
    end
  end

  def lookup_ident(ident) do
    Map.get(@keywords, ident, :atom)
  end
end
