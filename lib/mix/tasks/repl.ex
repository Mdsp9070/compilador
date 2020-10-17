defmodule Mix.Tasks.Repl do
  use Mix.Task

  def run(_) do
    Lisper.Repl.loop()
  end
end
