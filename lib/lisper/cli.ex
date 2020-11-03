defmodule Lisper.CLI do
  @moduledoc """
  Main program to run
  """

  alias Lisper.Lexer

  def main(args \\ []) do
    {:ok, input} = File.read(List.first(args))

    result = input |> Lexer.tokenize()

    IO.inspect(result)
  end
end
