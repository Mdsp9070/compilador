defmodule Lisper.Ast.PrefixExpression do
  alias Lisper.Ast.Node

  @enforce_keys [:token, :operator, :right, :left]
  defstruct [
    # the prefix token
    :token,
    :operator,
    # expression
    :right,
    :left
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(exp) do
      left = Node.to_string(exp.left)
      operator = exp.operator
      right = Node.to_string(exp.right)

      "(#{operator} (#{right} #{left}))"
    end
  end
end
