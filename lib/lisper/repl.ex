defmodule Lisper.Repl do
  alias Lisper.Lexer

  @prompt ">> "

  def loop() do
    input = IO.gets(@prompt)
    tokens = Lexer.tokenize(input)

    IO.inspect(tokens)

    loop()
  end
end
