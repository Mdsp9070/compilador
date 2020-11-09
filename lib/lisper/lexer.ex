defmodule Lisper.Lexer do
  @moduledoc """
  Implementation of Lisp lexer, or lexical analysis
  """

  alias Lisper.Token

  @doc """
  When we receive raw input, like:
  (defvar b 10)
  then, we split this input into a list of chars
  and call tokenize again
  """
  @spec tokenize(String.t()) :: [Token]
  def tokenize(input) do
    chars = String.split(input, "", trim: true)
    tokenize(chars, [], 1)
  end

  # when we do not have any more chars, that's the end of file
  # or 'EOF', so we could add the eof token to the list end
  defp tokenize([] = _chars, tokens, line) do
    Enum.reverse([Token.new(type: :eof, literal: "", line: line) | tokens])
  end

  # here we do some conditionals:
  # if it'is a new line, then we increase the line number
  # we skip whitespaces
  # it's a letter? so it's a identifier
  # a quote? it's a string
  # a digit could be either an int or a float
  # maybe a two digit operator (>= or /=)
  # none of these? well, let's try to read the next char
  defp tokenize([ch | rest] = chars, tokens, num_lines) do
    cond do
      is_newline?(ch) -> tokenize(rest, tokens, num_lines + 1)
      is_whitespace?(ch) -> tokenize(rest, tokens, num_lines)
      is_letter?(ch) -> read_identifier(chars, tokens, num_lines)
      is_quote?(ch) -> read_string(chars, tokens, num_lines)
      is_int?(chars) -> read_int(chars, tokens, num_lines)
      is_float_number?(chars) -> read_float(chars, tokens, num_lines)
      is_two_digit_operator?(chars) -> read_two_digit_operator(chars, tokens, num_lines)
      true -> read_next_char(chars, tokens, num_lines)
    end
  end

  # we read until we find something that is not a letter
  # then, we lookup on our tokens table if there's any match
  # if match it, then this identifier is a keyword
  # else is a variable or a function defined by the user
  defp read_identifier(chars, tokens, line) do
    {identifier, rest} = Enum.split_while(chars, &is_letter?/1)

    identifier = Enum.join(identifier)
    token = Token.new(type: Token.lookup_ident(identifier), literal: identifier, line: line)

    tokenize(rest, [token | tokens], line)
  end

  # it's simple: the integer number is the whole
  # string of chars that're alse a digit
  defp read_int(chars, tokens, line) do
    {number, rest} = Enum.split_while(chars, &is_digit?/1)

    number = Enum.join(number)
    token = Token.new(type: :int, literal: number, line: line)

    tokenize(rest, [token | tokens], line)
  end

  # a float number is a number that is compounded of two parts:
  # the integer and the decimal part, like:
  # 1.98
  # 1 -> integer
  # .98 -> decimal
  defp read_float(chars, tokens, line) do
    with {number, rest} <- Enum.split(chars, 2),
         {decimal, _rest} <- Enum.split_while(rest, &is_digit?/1) do
      number = "#{number}#{decimal}"
      token = Token.new(type: :float, literal: number, line: line)

      tokenize(rest, [token | tokens], line)
    end
  end

  # oh, so it's a two digit operator?
  # so we split one more char and then try to match
  # with one of the grammar
  defp read_two_digit_operator(chars, tokens, line) do
    {literal, rest} = Enum.split(chars, 2)

    literal = Enum.join(literal)

    token =
      case literal do
        "/=" -> Token.new(type: :not_eq, literal: literal, line: line)
        ">=" -> Token.new(type: :gt_eq, literal: literal, line: line)
        "<=" -> Token.new(type: :lt_eq, literal: literal, line: line)
      end

    tokenize(rest, [token | tokens], line)
  end

  # well, a string starts with a double quote and also ends with it
  # so we can split until we find the last quote
  defp read_string([_quote | rest], tokens, line) do
    {string, [_quote | rest]} = Enum.split_while(rest, &(!is_quote?(&1)))

    string = Enum.join(string)
    token = Token.new(type: :string, literal: string, line: line)

    tokenize(rest, [token | tokens], line)
  end

  # none of above?
  # no problem, we have a token for you!
  # maybe one of these:
  defp read_next_char([ch | rest] = _chars, tokens, line) do
    token =
      case ch do
        "=" -> Token.new(type: :equal, literal: ch, line: line)
        "*" -> Token.new(type: :asterisk, literal: ch, line: line)
        "+" -> Token.new(type: :plus, literal: ch, line: line)
        "-" -> Token.new(type: :minus, literal: ch, line: line)
        "/" -> Token.new(type: :slash, literal: ch, line: line)
        "<" -> Token.new(type: :lt, literal: ch, line: line)
        ">" -> Token.new(type: :gt, literal: ch, line: line)
        "(" -> Token.new(type: :lparen, literal: ch, line: line)
        ")" -> Token.new(type: :rparen, literal: ch, line: line)
        _ -> Token.new(type: :illegal, literal: "X", line: line)
      end

    tokenize(rest, [token | tokens], line)
  end

  defp is_whitespace?(ch), do: ch == " "

  defp is_newline?(ch) do
    ch == "\n" or ch == "\r" or ch == "\t"
  end

  defp is_two_digit_operator?(chars) do
    curr = Enum.at(chars, 0)
    next = Enum.at(chars, 1)

    (curr == ">" or curr == "<" or curr == "/") and next == "="
  end

  defp is_digit?(ch) do
    "0" <= ch && ch <= "9"
  end

  defp is_float_number?(chars) do
    curr = hd(chars)

    is_digit?(curr) and Enum.at(chars, 1) == "."
  end

  defp is_int?(chars) do
    curr = hd(chars)

    is_digit?(curr) and not is_float_number?(chars)
  end

  defp is_letter?(ch) do
    ("a" <= ch && ch <= "z") || ("A" <= ch && ch <= "Z") || ch == "_"
  end

  defp is_quote?(ch), do: ch == "\""
end
