defmodule Lisper.Ast.NumberLiteral do
  @moduledoc """
  Defines a number literal, like:

  1, 2.3, 9.99
  """

  alias Lisper.Ast.Node

  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression), do: expression.token.value
  end
end
