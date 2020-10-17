defmodule Lisper.Token do
  @enforce_keys [:type, :literal]
  defstruct [:type, :literal]

  @keywords %{
    "defun" => :function,
    "lambda" => :lambda,
    "if" => :if,
    "define" => :define,
    "t" => true,
    "nil" => nil
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
    # delimiters
    dot: ".",
    lparen: "(",
    rparen: ")",
    # keywords
    function: "FUNCTION",
    t: "TRUE",
    nil: "NIL",
    if: "IF",
    lambda: "LAMBDA"
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
