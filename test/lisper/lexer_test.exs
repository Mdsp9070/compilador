defmodule Lisper.Test do
  use ExUnit.Case

  alias Lisper.Token
  alias Lisper.Lexer

  test "converts a string to a list of tokens" do
    input = "=+()/=<= >="

    expected = [
      %Token{type: :equal, literal: "="},
      %Token{type: :plus, literal: "+"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :not_eq, literal: "/="},
      %Token{type: :lt_eq, literal: "<="},
      %Token{type: :gt_eq, literal: ">="},
      %Token{type: :eof, literal: ""}
    ]

    tokens = Lexer.tokenize(input)

    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&assert elem(&1, 0) == elem(&1, 1))
  end

  test "converts real lisp code into tokens" do
    input = """
    (setq a 10)
    (setq b 15)
    (if (>= a b)
        (incf b 1)
        (decf a 1))
    """

    expected = [
      %Token{type: :lparen, literal: "("},
      %Token{type: :setq, literal: "setq"},
      %Token{type: :atom, literal: "a"},
      %Token{type: :atom, literal: "10"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :setq, literal: "setq"},
      %Token{type: :atom, literal: "b"},
      %Token{type: :atom, literal: "15"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :if, literal: "if"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :gt_eq, literal: ">="},
      %Token{type: :atom, literal: "a"},
      %Token{type: :atom, literal: "b"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :incf, literal: "incf"},
      %Token{type: :atom, literal: "b"},
      %Token{type: :atom, literal: "1"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :decf, literal: "decf"},
      %Token{type: :atom, literal: "a"},
      %Token{type: :atom, literal: "1"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :eof, literal: ""}
    ]

    tokens = Lexer.tokenize(input)

    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&assert elem(&1, 0) == elem(&1, 1))
  end
end
