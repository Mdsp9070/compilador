defmodule Lisper.Ast.CallExpression do
  @moduledoc """
  Defines a function call expression, like:

  (defun sum (a b)
    (+ a b)
  )
  (sum (1 2))
  """

  alias Lisper.Ast.Node

  @enforce_keys [:token, :function, :arguments]
  defstruct [:token, :function, :arguments]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      function = Node.to_string(expression.function)

      arguments =
        expression.arguments
        |> Enum.map(&Node.to_string/1)
        |> Enum.join(" ")

      "(#{function} (#{arguments}))"
    end
  end
end
