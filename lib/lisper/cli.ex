defmodule Lisper.CLI do
  alias Lisper.Lexer
  alias Lisper.Parser

  def main(args \\ []) do
    {:ok, input} = File.read(List.first(args))

    {parser, program} =
      input |> Lexer.tokenize() |> Parser.from_tokens() |> Parser.parse_program()

    case length(parser.errors) do
      0 -> IO.inspect(program)
      _ -> print_parser_errors(parser.errors)
    end
  end

  defp print_parser_errors(errors) do
    IO.puts("Woops! We ran into some lisp business here!")
    IO.puts("Parser Errors:")
    Enum.each(errors, &IO.puts/1)
  end
end
