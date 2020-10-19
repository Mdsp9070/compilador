defmodule Lisper.Ast.DefStatement do
  alias Lisper.Ast.Node

  @enforce_keys [:token, :name, :value]
  defstruct [
    :token,
    :name,
    :value
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(stmt), do: stmt.token.literal

    def node_type(_), do: :statement

    def to_string(stmt) do
      out = [
        Node.token_literal(stmt),
        " ",
        Node.to_string(stmt.name),
        " "
      ]

      out = if stmt.value, do: out ++ [Node.to_string(stmt.value)], else: out

      Enum.join(out)
    end
  end
end
