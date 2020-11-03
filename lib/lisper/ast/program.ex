defmodule Lisper.Ast.Program do
  @moduledoc """
  Defines a Program, that is the AST
  """

  alias Lisper.Ast.Node

  @enforce_keys [:statements]
  defstruct [:statements]

  def token_literal(program) when length(program.statements) > 0 do
    program.statements |> List.first() |> Node.token_literal()
  end

  def token_literal(_program), do: ""

  def to_string(program), do: program.statements |> Enum.map(&Node.to_string/1) |> Enum.join()
end
