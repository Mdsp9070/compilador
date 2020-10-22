defmodule Lisper.CLI do
  alias Lisper.Lexer

  def main(args \\ []) do
    {:ok, input} = File.read(List.first(args))

    input |> Lexer.tokenize() |> IO.inspect()
  end
end
