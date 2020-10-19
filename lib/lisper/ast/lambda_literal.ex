defmodule Lisper.Ast.LambdaLiteral do
  alias Lisper.Ast.Node

  @enforce_keys [:token, :parameters, :body]
  defstruct [
    :token,
    :parameters,
    :body
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(exp), do: exp.token.literal

    def node_type(_), do: :expression

    def to_string(exp) do
      literal = Node.token_literal(exp)
      body = Node.to_string(exp.body)

      params =
        exp.parameters
        |> Enum.map(&Node.to_string/1)
        |> Enum.join(" ")

      "(#{literal} (#{params}) (#{body}))"
    end
  end
end
