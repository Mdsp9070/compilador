defmodule Lisper.Parser do
  @moduledoc """
  Implementation of Lisp parser or syntax analysis
  """

  alias Lisper.Ast.{
    Atom,
    BooleanLiteral,
    CallExpression,
    DeFunStatement,
    DefVarStatement,
    ExpressionStatement,
    LambdaExpression,
    ListStatement,
    Node,
    NumberLiteral,
    PrefixExpression,
    Program,
    Sequence,
    StringLiteral
  }

  alias Lisper.Parser
  alias Lisper.Token

  @enforce_keys [:curr, :peek, :tokens, :errors]
  defstruct [:curr, :peek, :tokens, :errors]

  @precedences_numbers %{
    lowest: 0,
    equal: 1,
    lt_gt: 2,
    sum: 3,
    product: 4,
    call: 5
  }

  @precedences %{
    eq: @precedences_numbers.equal,
    not_eq: @precedences_numbers.equal,
    lt: @precedences_numbers.lt_gt,
    gt: @precedences_numbers.lt_gt,
    lt_eq: @precedences_numbers.lt_gt,
    gt_eq: @precedences_numbers.lt_gt,
    plus: @precedences_numbers.sum,
    minus: @precedences_numbers.sum,
    slash: @precedences_numbers.product,
    asterisk: @precedences_numbers.product,
    lparen: @precedences_numbers.call,
    lbracket: @precedences_numbers.index
  }

  def from_tokens(tokens) do
    [curr | [peek | rest]] = tokens

    %Parser{curr: curr, peek: peek, tokens: rest, errors: []}
  end

  def parse_program(p, statements \\ []), do: do_parse_program(p, statements)

  # pattern matching
  # if the p (parser) arg is a Parser with curr_token of type eof
  # this means that we finished the parsing
  # then we create a program with all statements parsed
  defp do_parse_program(%Parser{curr: %Token{type: :eof}} = p, statements) do
    statements = Enum.reverse(statements)
    program = %Program{statements: statements}

    {p, program}
  end

  # if p is a default Parser
  # means that we didn't finished the tokens yet
  # so we need to parse all remainning statements
  defp do_parse_program(%Parser{} = p, statements) do
    {p, statement} = parse_statement(p)

    statements =
      case statement do
        nil -> statements
        statement -> [statement | statements]
      end

    p = next_token(p)

    do_parse_program(p, statements)
  end

  # if there're no reamaining tokens
  # that means that the current is last token
  # and there isn't any other next
  defp next_token(%Parser{tokens: []} = p), do: %{p | curr: p.peek, peek: nil}

  # however, if p is a default Parser
  # we get the next_peek (next_next_token)
  # and advance one token,so current is the next
  # and next is the next_next_token
  defp next_token(%Parser{} = p) do
    [next_peek | rest] = p.tokens

    %{p | curr: p.peek, peek: next_peek, tokens: rest}
  end

  # we have 3 types of statements:
  # defvar, defun and expressions statements
  defp parse_statement(p) do
    case p.curr.type do
      :defvar -> parse_defvar_statement(p)
      :defun -> parse_defun_statement(p)
      _ -> parse_expression_statement(p)
    end
  end

  # to parse a defvar statement
  # we need to read the defvar token,
  # the atom token and then the value
  defp parse_defvar_statement(p) do
    defvar_token = p.curr

    with {:ok, p, atom_token} <- expect_peek(p, :atom),
         {:ok, p, value} <- parse_expression(p, @precedences_numbers.lowest) do
      atom = %Atom{token: atom_token, value: atom_token.literal}
      statement = %DefVarStatement{token: defvar_token, name: atom, value: value}

      p = skip_close_paren(p)

      {p, statement}
    end
  end

  defp parse_defun_statement(p) do
    defun_token = p.curr

    with {:ok, p, atom_token} <- expect_peek(p, :atom),
         {:ok, p, _lparen} <- expect_peek(p, :lparen),
         {:ok, p, params} <- parse_function_parameters(p),
         {:ok, p, _rparen} <- expect_peek(p, :rparen) do
      {p, body} = parse_list_statement(p)

      expression = %DeFunStatement{
        token: defun_token,
        name: atom_token,
        parameters: params,
        body: body
      }

      {p, expression}
    else
      {:error, p, _} -> {p, nil}
    end
  end

  # here we get the current token
  # parse the expression, create the ExpressionStatement
  # then skip the close paren and return the parser
  defp parse_expression_statement(p) do
    token = p.curr

    {_, p, expression} = parse_expression(p, @precedences_numbers.lowest)
    statement = %ExpressionStatement{token: token, expression: expression}

    p = skip_close_paren(p)

    {p, statement}
  end

  defp parse_expression(p, precedence) do
    case prefix_parse_fns(p.curr.type) do
      {p, nil} ->
        error =
          "Cannot parse this expression, this is the last token -> :#{p.curr} on line #{
            p.curr.line
          }"

        p = add_error(p, error)

        {:error, p, nil}

      {p, parse_function} ->
        {p, parsed_expression} = parse_function(p.curr, p)

        {:ok, p, parsed_expression}
    end
  end

  defp prefix_parse_fns(:rparen, p) do
    p = skip_close_paren(p)

    prefix_parse_fns(p.curr, p)
  end

  defp prefix_parse_fns(:lparen, p), do: parse_list_
  defp prefix_parse_fns(:atom, p), do: parse_atom(p)

  defp prefix_parse_fns(:int, p),
    # we can skip close parens
    do: defp(skip_close_paren(p)) do
    if p.peek.type == :rparen, do: next_token(p), else: p
  end

  defp curr_precedence(p), do: Map.get(@precedences, p.curr.type, @precedences_numbers.lowest)

  defp peek_precedence(p), do: Map.get(@precedences, p.peek.type, @precedences_numbers.lowest)

  defp expect_peek(%Parser{peek: peek} = p, expected_type) do
    if peek.type == expected_type do
      p = next_token(p)

      {:ok, p, peek}
    else
      error =
        "Expected next toke to be :#{expected_type}, got :#{peek.type} on line #{peek.line} instead"

      p = add_error(p, error)

      {:error, p, nil}
    end
  end

  defp add_error(p, msg), do: %{p | errors: p.errors ++ [msg]}
end
