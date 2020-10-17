defmodule Lisper.CLI do
  alias Lisper.Reader

  def main(args) do
    [path | _] = args

    path |> Reader.read()
  end
end
