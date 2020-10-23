defmodule Lisper.Parser do
  def parse(tokens) do
    tokens |> parse([])
  end

  defp parse(["(" | rest], program) do
    {rem_tokens, sub_tree} = parse(rest, [])

    parse(rem_tokens, [sub_tree | program])
  end

  defp parse([")" | rest], program) do
    {rest, Enum.reverse(program)}
  end

  defp parse([], program) do
    Enum.reverse(program)
  end

  defp parse([head | rest], program) do
    parse(rest, [atom(head) | program])
  end

  def atom(token) do
    case Integer.parse(token.literal) do
      {value, ""} ->
        value

      :error ->
        case Float.parse(token.literal) do
          {value, ""} -> value
          :error -> String.to_atom(token.literal)
        end
    end
  end
end
