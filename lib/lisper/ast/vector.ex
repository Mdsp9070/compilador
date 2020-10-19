defmodule Lisper.Vector do
  alias Lisper.Ast.Node

  @enforce_keys [:token, :elements]
  defstruct [:token, :elements]

  defimpl Node, for: __MODULE__ do
    def token_literal(exp), do: exp.token.literal

    def node_type(_), do: :expression

    def to_string(exp) do
      elements =
        exp.elements
        |> Enum.map(&Node.to_string/1)
        |> Enum.join(" ")

      "([#{elements}])"
    end
  end
end
