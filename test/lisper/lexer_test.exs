defmodule Lisper.Test do
  use ExUnit.Case

  alias Lisper.Lexer
  alias Lisper.Token

  test "converts a string to a list of tokens" do
    input = "=+()/=<= >="

    expected = [
      %Token{type: :equal, literal: "=", line: 1},
      %Token{type: :plus, literal: "+", line: 1},
      %Token{type: :lparen, literal: "(", line: 1},
      %Token{type: :rparen, literal: ")", line: 1},
      %Token{type: :not_eq, literal: "/=", line: 1},
      %Token{type: :lt_eq, literal: "<=", line: 1},
      %Token{type: :gt_eq, literal: ">=", line: 1},
      %Token{type: :eof, literal: "", line: 1}
    ]

    tokens = Lexer.tokenize(input)

    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&assert elem(&1, 0) == elem(&1, 1))
  end

  test "converts real lisp code into tokens" do
    input = """
    (defvar a 10)
    (defvar b 15)
    (if (>= a b)
        (incf b 1)
        (decf a 1))
    """

    expected = [
      %Token{type: :lparen, literal: "(", line: 1},
      %Token{type: :defvar, literal: "defvar", line: 1},
      %Token{type: :atom, literal: "a", line: 1},
      %Token{type: :int, literal: "10", line: 1},
      %Token{type: :rparen, literal: ")", line: 1},
      %Token{type: :lparen, literal: "(", line: 2},
      %Token{type: :defvar, literal: "defvar", line: 2},
      %Token{type: :atom, literal: "b", line: 2},
      %Token{type: :int, literal: "15", line: 2},
      %Token{type: :rparen, literal: ")", line: 2},
      %Token{type: :lparen, literal: "(", line: 3},
      %Token{type: :if, literal: "if", line: 3},
      %Token{type: :lparen, literal: "(", line: 3},
      %Token{type: :gt_eq, literal: ">=", line: 3},
      %Token{type: :atom, literal: "a", line: 3},
      %Token{type: :atom, literal: "b", line: 3},
      %Token{type: :rparen, literal: ")", line: 3},
      %Token{type: :lparen, literal: "(", line: 4},
      %Token{type: :incf, literal: "incf", line: 4},
      %Token{type: :atom, literal: "b", line: 4},
      %Token{type: :int, literal: "1", line: 4},
      %Token{type: :rparen, literal: ")", line: 4},
      %Token{type: :lparen, literal: "(", line: 5},
      %Token{type: :decf, literal: "decf", line: 5},
      %Token{type: :atom, literal: "a", line: 5},
      %Token{type: :int, literal: "1", line: 5},
      %Token{type: :rparen, literal: ")", line: 5},
      %Token{type: :rparen, literal: ")", line: 5},
      %Token{type: :eof, literal: "", line: 6}
    ]

    tokens = Lexer.tokenize(input)

    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&assert elem(&1, 0) == elem(&1, 1))
  end
end
