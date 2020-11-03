defmodule Lisper.Ast.Atom do
  @moduledoc """
  Defines an atom, like:

  (defvar a 10) -> a is an atom
  """

  alias Lisper.Ast.Node

  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  defimpl Node, for: __MODULE__ do
    def token_literal(atom), do: atom.token.literal

    def node_type(_), do: :expression

    def to_string(atom), do: atom.token.value
  end
end
