defmodule Lisper.CLI do
  alias Lisper.Lexer
  alias Lisper.Parser

  def main(args \\ []) do
    {:ok, input} = File.read(List.first(args))

    la = input |> Lexer.tokenize() |> Parser.parse()

    IO.inspect(la)
  end
end
