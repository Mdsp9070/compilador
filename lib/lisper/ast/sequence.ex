defmodule Lisper.Ast.Sequence do
  @moduledoc """
  Defines a vector structure, like:

  (setq v1 (vector 1 2 3 4 5 6))
  """

  alias Lisper.Ast.Node

  @enforce_keys [:token, :elements]
  defstruct [:token, :elements]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      elements = expression.elements |> Enum.map(&Node.to_string/1) |> Enum.join(" ")
      literal = token_literal(expression)

      "(#{literal} #{elements})"
    end
  end
end
