defmodule Lisper.Ast.ExpressionStmt do
  alias Lisper.Ast.Node

  @enforce_keys [:token, :expression]
  defstruct [:token, :expression]

  defimpl Node, for: __MODULE__ do
    def token_literal(stmt), do: stmt.token.literal

    def node_type(_), do: :statement

    def to_string(%{expression: nil}), do: ""
    def to_string(stmt), do: Node.to_string(stmt.expression)
  end
end
