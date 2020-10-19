defmodule Lisper.Ast.Identifier do
  alias Lisper.Ast.Node

  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  defimpl Node, for: __MODULE__ do
    def token_literal(ident), do: ident.token.literal

    def node_type(_), do: :expression

    def to_string(ident), do: ident.value
  end
end
