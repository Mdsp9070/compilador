defmodule Lisper.Parser do
  alias Lisper.Ast.{
    BooleanLiteral,
    CallExpression,
    DefStatement,
    Atom,
    IfExpression,
    LambdaLiteral,
    PrefixExpression,
    ExpressionStatement,
    Program,
    StringLiteral,
    NilLiteral,
    Vector
  }

  alias Lisper.Parser
  alias Lisper.Token

  # specify required keys when creating a Parser struct
  @enforce_keys [:curr, :peek, :tokens, :errors]
  # define the struct itself
  defstruct [:curr, :peek, :tokens, :errors]

  @spec from_tokens([Token]) :: Parser
  def from_tokens(tokens) do
    [_lparen | [curr | [peek | rest]]] = tokens

    %Parser{curr: curr, peek: peek, tokens: rest, errors: []}
  end

  # function to start parsing, have a default param of an empty list
  def parse_program(p, stmts \\ []), do: do_parse_program(p, stmts)

  # pattern matching
  # if the p (parser) arg is a Parser with curr_token of type eof
  # we create a program with all statements parsed
  defp do_parse_program(%Parser{curr: %Token{type: :eof}} = p, stmts) do
    stmts = Enum.reverse(stmts)
    program = %Program{statements: stmts}

    {p, program}
  end

  # if p is a default Parser
  # means that we didn't finished the tokens yet
  # so we need to parse all remainning statements
  defp do_parse_program(%Parser{} = p, stmts) do
    {p, stmt} = parse_statement(p)

    stmts =
      case stmt do
        nil -> stmts
        stmt -> [stmt | stmts]
      end

    p = next_token(p)

    do_parse_program(p, stmts)
  end

  # if there're no reamaining tokens
  # that means that the current is last token
  # and there isn't any other next
  defp next_token(%Parser{tokens: []} = p) do
    %{p | curr: p.peek, peek: nil}
  end

  # however, if p is a default Parser
  # we get the next_peek (next_next_token)
  # and advance one token,so current is the next
  # and next is the next_next_token
  defp next_token(%Parser{} = p) do
    [next_peek | rest] = p.tokens

    %{p | curr: p.peek, peek: next_peek, tokens: rest}
  end

  defp parse_statement(p) do
    case p.curr.type do
      :defun -> parse_def_statement(p)
      :defvar -> parse_def_statement(p)
      _ -> parse_expression_statement(p)
    end
  end

  defp parse_def_statement(p) do
    def_token = p.curr

    with {:ok, p, atom_token} <- expect_peek(p, :atom),
         {:ok, p, value} <- parse_expression(p) do
      atom = %Atom{token: atom_token, value: atom_token.literal}
      statement = %DefStatement{token: def_token, name: atom, value: value}

      p = skip_paren(p)

      {p, statement}
    else
      _ -> {p, nil}
    end
  end

  defp parse_expression_statement(p) do
    token = p.curr

    {_, p, expression} = parse_expression(p)

    statement = %ExpressionStatement{token: token, expression: expression}

    p = skip_paren(p)

    {p, statement}
  end

  defp parse_expression(p) do
    case parse_fns(p.curr.type, p) do
      {p, nil} -> {:error, p, nil}
      {p, expression} -> {:ok, p, expression}
    end
  end

  defp parse_fns(:atom, p), do: parse_atom(p)
  defp parse_fns(:t, p), do: parse_boolean(p)
  defp parse_fns(false, p), do: parse_boolean(p)
  defp parse_fns(nil, p), do: parse_nil(p)

  defp parse_fns(_, p) do
    error = "No function found for #{p.curr.type}"
    p = add_error(p, error)

    {p, nil}
  end

  defp parse_atom(p) do
    atom = %Atom{token: p.curr, value: p.curr.literal}

    {p, atom}
  end

  defp parse_boolean(p) do
    bool = %BooleanLiteral{token: p.curr, value: p.curr.type == true}

    {p, bool}
  end

  defp parse_nil(p) do
    nil_exp = %NilLiteral{token: p.curr, value: nil}

    {p, nil_exp}
  end

  defp skip_paren(p) do
    case p.peek.type do
      :lparen -> next_token(p)
      :rparen -> next_token(p)
      _ -> p
    end
  end

  # given an expected type we check if the next token is of this type
  # if true, return the peek token
  # else add an error to the parser
  defp expect_peek(%Parser{peek: peek} = p, expected_type) do
    if peek.type == expected_type do
      p = next_token(p)
      {:ok, p, peek}
    else
      error = "Expected next token to be :#{expected_type}, got :#{peek.type} instead"
      p = add_error(p, error)
      {:error, p, nil}
    end
  end

  defp add_error(p, msg), do: %{p | errors: p.errors ++ [msg]}
end
