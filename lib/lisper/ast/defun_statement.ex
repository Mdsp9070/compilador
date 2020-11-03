defmodule Lisper.Ast.DeFunStatement do
  @moduledoc """
  Defines a defun statement, like:

  (defun sum (a, b)
    (+ a b)
  )
  """

  alias Lisper.Ast.Node

  @enforce_keys [:token, :name, :parameters, :body]
  @defstruct [:token, :name, :parameters, :body]

  defimpl Node, for: __MODULE__ do
    def token_literal(statement), do: statement.token.literal

    def node_type(_), do: :statement

    def to_string(statement) do
      params = statement.parameters |> Enum.map(&Node.to_string/1) |> Enum.join(" ")
      body = Node.to_string(statement.body)

      out = [
        "(",
        Node.token_literal(statement),
        " ",
        Node.to_string(statement.name),
        " ",
        "(",
        params,
        ")",
        " ",
        "(",
        body,
        ")",
        ")"
      ]

      Enum.join(out)
    end
  end
end
