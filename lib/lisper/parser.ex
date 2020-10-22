defmodule Lisper.Parser do
  alias Lisper.Ast.{
    Boolean,
    CallExp,
    DefStatement,
    Atom,
    IfExp,
    LambdaLiteral,
    NumberLiteral,
    PrefixExpression,
    Program,
    StringLiteral,
    Vector
  }

  alias Lisper.Parser
  alias Lisper.Token

  # specify required keys when creating a Parser struct
  @enforce_keys [:curr, :peek, :tokens, :errors]
  # define the struct itself
  defstruct [:curr, :peek, :tokens, :errors]

  # precedences levels
  @precedences_numbers %{
    lowest: 0,
    equal: 1,
    lt_gt: 2,
    sum: 3,
    product: 4,
    prefix: 5
  }

  # precedences Map
  @precedences %{
    equal: @precedences_numbers.equal,
    not_eq: @precedences_numbers.equal,
    lt: @precedences_numbers.lt_gt,
    gt: @precedences_numbers.lt_gt,
    lt_eq: @precedences_numbers.lt_gt,
    gt_eq: @precedences_numbers.lt_gt,
    plus: @precedences_numbers.sum,
    minus: @precedences_numbers.sum,
    slash: @precedences_numbers.product,
    asterisk: @precedences_numbers.product
  }

  def from_tokens(tokens) do
    [curr | [peek | rest]] = tokens

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
  # defp do_parse_program(%Parser{} = p, stmts) do
  #    {p, stmt} = parse_statement(p)

  # stmts =
  #  case stmt do
  #   nil -> stmts
  #  stmt -> [stmt | stmts]
  # end

  # p = next_token(p)

  # do_parse_program(p, stmts)
  # end

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

  #  defp parse_statement(p) do
  #    case p.curr.type do
  #      :defun -> parse_defun_statement(p)
  #      :defvar -> parse_defvar_statement(p)
  #      _ -> parse_expression_statement
  #    end
  #  end

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
