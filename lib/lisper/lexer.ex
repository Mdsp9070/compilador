defmodule Lisper.Lexer do
  alias Lisper.Token

  def tokenize(input) do
    chars = String.split(input, "", trim: true)
    tokenize(chars, [])
  end

  defp tokenize(_chars = [], tokens) do
    Enum.reverse([Token.new(type: :eof, literal: "") | tokens])
  end

  defp tokenize(chars = [ch | rest], tokens) do
    cond do
      is_whitespace(ch) -> tokenize(rest, tokens)
      is_letter(ch) -> read_identifier(chars, tokens)
      is_quote(ch) -> read_string(chars, tokens)
      is_int(chars) -> read_int(chars, tokens)
      is_float_number(chars) -> read_float(chars, tokens)
      is_binary_operator(chars) -> read_binary_operator(chars, tokens)
      true -> read_next_char(chars, tokens)
    end
  end

  defp read_identifier(chars, tokens) do
    {identifier, rest} = Enum.split_while(chars, &is_letter/1)

    identifier = Enum.join(identifier)
    token = Token.new(type: Token.lookup_ident(identifier), literal: identifier)

    tokenize(rest, [token | tokens])
  end

  defp read_int(chars, tokens) do
    {number, rest} = Enum.split_while(chars, &is_digit/1)

    number = Enum.join(number)
    token = Token.new(type: :atom, literal: number)

    tokenize(rest, [token | tokens])
  end

  defp read_float(chars, tokens) do
    with {number, rest} <- Enum.split(chars, 2),
         {decimal, _rest} <- Enum.split_while(rest, &is_digit/1) do
      number = "#{number}#{decimal}"
      token = Token.new(type: :atom, literal: number)

      tokenize(rest, [token | tokens])
    end
  end

  defp read_binary_operator(chars, tokens) do
    {literal, rest} = Enum.split(chars, 2)

    literal = Enum.join(literal)

    token =
      case literal do
        "/=" -> Token.new(type: :not_eq, literal: literal)
        ">=" -> Token.new(type: :gt_eq, literal: literal)
        "<=" -> Token.new(type: :lt_eq, literal: literal)
      end

    tokenize(rest, [token | tokens])
  end

  defp read_string([_quote | rest], tokens) do
    {string, [_quote | rest]} = Enum.split_while(rest, &(!is_quote(&1)))

    string = Enum.join(string)
    token = Token.new(type: :string, literal: string)

    tokenize(rest, [token | tokens])
  end

  defp read_next_char(_chars = [ch | rest], tokens) do
    token =
      case ch do
        "=" -> Token.new(type: :equal, literal: ch)
        "*" -> Token.new(type: :asterisk, literal: ch)
        "+" -> Token.new(type: :plus, literal: ch)
        "-" -> Token.new(type: :minus, literal: ch)
        "/" -> Token.new(type: :slash, literal: ch)
        "<" -> Token.new(type: :lt, literal: ch)
        ">" -> Token.new(type: :gt, literal: ch)
        "(" -> Token.new(type: :lparen, literal: ch)
        ")" -> Token.new(type: :rparen, literal: ch)
        _ -> Token.new(type: :illegal, literal: "X")
      end

    tokenize(rest, [token | tokens])
  end

  defp is_whitespace(ch) do
    ch == " " or ch == "\n" or ch == "\r" or ch == "\t"
  end

  defp is_binary_operator(chars) do
    curr = Enum.at(chars, 0)
    next = Enum.at(chars, 1)

    (curr == ">" or curr == "<" or curr == "/") and next == "="
  end

  defp is_digit(ch) do
    "0" <= ch && ch <= "9"
  end

  defp is_float_number(chars) do
    curr = hd(chars)

    is_digit(curr) and Enum.at(chars, 1) == "."
  end

  defp is_int(chars) do
    curr = hd(chars)

    is_digit(curr) and not is_float_number(chars)
  end

  defp is_letter(ch) do
    ("a" <= ch && ch <= "z") || ("A" <= ch && ch <= "Z") || ch == "_"
  end

  defp is_quote(ch), do: ch == "\""
end
