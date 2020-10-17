defmodule Lisper.Token do
  @enforce_keys [:type, :literal]
  defstruct [:type, :literal]

  @keywords %{
    "defun" => :function,
    "lambda" => :lambda,
    "if" => :if,
    "setq" => :setq,
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
    "not" => :not
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
    setq: "ASSIGN"
  }

  def new(type: type, literal: literal) when is_atom(type) and is_binary(literal) do
    if Map.has_key?(@types, type) do
      %__MODULE__{type: type, literal: literal}
    else
      raise "Token with type #{inspect(type)} is not defined!"
    end
  end

  def lookup_ident(ident) do
    Map.get(@keywords, ident, :atom)
  end
end
