defmodule Lisper.Ast.IfExp do
  alias Lisper.Ast.Node

  @enforce_keys [:token, :condition, :consequence]
  defstruct [
    :token,
    :condition,
    :consequence,
    :alternative
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(exp), do: exp.token.literal

    def node_type(_), do: :expression

    def to_string(exp) do
      condition = Node.to_string(exp.condition)
      consequence = Node.to_string(exp.consequence)
      alternative = alternative_to_string(exp.alternative)

      "if (#{condition}) (#{consequence}) (#{alternative})"
    end

    def alternative_to_string(alt) do
      string = Node.to_string(alt)

      "#{string}"
    end
  end
end
