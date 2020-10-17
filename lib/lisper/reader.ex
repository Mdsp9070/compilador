defmodule Lisper.Reader do
  alias Lisper.Lexer

  def read(path) do
    {:ok, input} = File.read(path)
    tokens = Lexer.tokenize(input)

    inspect(tokens)
  end
end
