defmodule Mix.Tasks.Repl do
  @moduledoc """
  Define the REPL mix task
  """

  use Mix.Task

  def run(_) do
    Lisper.Repl.loop()
  end
end
