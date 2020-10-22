defmodule Lisper.Lexer do
  alias Lisper.Token

  @spec tokenize(String.t()) :: [Token]
  def tokenize(input) do
    chars = String.split(input, "", trim: true)
    tokenize(chars, [], 1)
  end

  @spec tokenize([], [Token], integer) :: [Token]
  defp tokenize(_chars = [], tokens, line) do
    Enum.reverse([Token.new(type: :eof, literal: "", line: line) | tokens])
  end

  @spec tokenize([String.t()], [Token], integer) :: [Token]
  defp tokenize(chars = [ch | rest], tokens, num_lines) do
    cond do
      is_newline(ch) -> tokenize(rest, tokens, num_lines + 1)
      is_whitespace(ch) -> tokenize(rest, tokens, num_lines)
      is_letter(ch) -> read_identifier(chars, tokens, num_lines)
      is_quote(ch) -> read_string(chars, tokens, num_lines)
      is_int(chars) -> read_int(chars, tokens, num_lines)
      is_float_number(chars) -> read_float(chars, tokens, num_lines)
      is_binary_operator(chars) -> read_binary_operator(chars, tokens, num_lines)
      true -> read_next_char(chars, tokens, num_lines)
    end
  end

  @spec read_identifier([String.t()], [Token], integer) :: Token
  defp read_identifier(chars, tokens, line) do
    {identifier, rest} = Enum.split_while(chars, &is_letter/1)

    identifier = Enum.join(identifier)
    token = Token.new(type: Token.lookup_ident(identifier), literal: identifier, line: line)

    tokenize(rest, [token | tokens], line)
  end

  @spec read_int([String.t()], [Token], integer) :: Token
  defp read_int(chars, tokens, line) do
    {number, rest} = Enum.split_while(chars, &is_digit/1)

    number = Enum.join(number)
    token = Token.new(type: :atom, literal: number, line: line)

    tokenize(rest, [token | tokens], line)
  end

  @spec read_float([String.t()], [Token], integer) :: Token
  defp read_float(chars, tokens, line) do
    with {number, rest} <- Enum.split(chars, 2),
         {decimal, _rest} <- Enum.split_while(rest, &is_digit/1) do
      number = "#{number}#{decimal}"
      token = Token.new(type: :atom, literal: number, line: line)

      tokenize(rest, [token | tokens], line)
    end
  end

  @spec read_binary_operator([String.t()], [Token], integer) :: Token
  defp read_binary_operator(chars, tokens, line) do
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

  @spec read_string([String.t()], [Token], integer) :: Token
  defp read_string([_quote | rest], tokens, line) do
    {string, [_quote | rest]} = Enum.split_while(rest, &(!is_quote(&1)))

    string = Enum.join(string)
    token = Token.new(type: :string, literal: string, line: line)

    tokenize(rest, [token | tokens], line)
  end

  @spec read_next_char([String.t()], [Token], integer) :: Token
  defp read_next_char(_chars = [ch | rest], tokens, line) do
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

  @spec is_whitespace(String.t()) :: boolean
  defp is_whitespace(ch), do: ch == " "

  @spec is_newline(String.t()) :: boolean
  defp is_newline(ch) do
    ch == "\n" or ch == "\r" or ch == "\t"
  end

  @spec is_binary_operator([String.t()]) :: boolean
  defp is_binary_operator(chars) do
    curr = Enum.at(chars, 0)
    next = Enum.at(chars, 1)

    (curr == ">" or curr == "<" or curr == "/") and next == "="
  end

  @spec is_digit(String.t()) :: boolean
  defp is_digit(ch) do
    "0" <= ch && ch <= "9"
  end

  @spec is_float_number([String.t()]) :: boolean
  defp is_float_number(chars) do
    curr = hd(chars)

    is_digit(curr) and Enum.at(chars, 1) == "."
  end

  @spec is_int([String.t()]) :: boolean
  defp is_int(chars) do
    curr = hd(chars)

    is_digit(curr) and not is_float_number(chars)
  end

  @spec is_letter(String.t()) :: boolean
  defp is_letter(ch) do
    ("a" <= ch && ch <= "z") || ("A" <= ch && ch <= "Z") || ch == "_"
  end

  @spec is_quote(String.t()) :: boolean
  defp is_quote(ch), do: ch == "\""
end
