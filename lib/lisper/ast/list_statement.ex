defmodule Lisper.Ast.ListStatement do
  @moduledoc """
  Defines a list statement, like:
  (> 7 6), (defun div (a b)
              (/ a b)
            )
  """

  alias Lisper.Ast.Node

  @enforce_keys [:token, :statements]
  defstruct [:token, :statements]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :statement

    def to_string(expression),
      do: expression.statements |> Enum.map(&Node.to_string/1) |> Enum.join()
  end
end
