defmodule MixTestInteractive.CommandProcessor do
  @moduledoc false

  alias MixTestInteractive.Config
  alias MixTestInteractive.Command.{AllTests, Failed, FilterPaths, Quit, RunTests, Stale}

  @spec call(String.t() | :eof, Config.t()) :: {:ok, Config.t()} | :unknown | :quit

  @commands [
    FilterPaths,
    Stale,
    Failed,
    AllTests,
    RunTests,
    Quit
  ]

  def call(:eof, _config), do: :quit

  def call(command_line, config) when is_binary(command_line) do
    case String.split(command_line) do
      [] -> process_command("", [], config)
      [command | args] -> process_command(command, args, config)
    end
  end

  def usage do
    usage =
      @commands
      |> Enum.map(&usage_line/1)
      |> Enum.join("\n")

    "Usage\n" <> usage
  end

  defp usage_line(command) do
    "› #{command.name} to #{command.description}."
  end

  defp process_command(command, args, config) do
    case config
         |> applicable_commands()
         |> Enum.find(nil, &(&1.command == command)) do
      nil -> :unknown
      cmd -> cmd.run(args, config)
    end
  end

  defp applicable_commands(config) do
    Enum.filter(@commands, & &1.applies?(config))
  end
end
