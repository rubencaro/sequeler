
defmodule Sequeler.Harakiri do
  use GenServer

  @moduledoc """
    Start the harakiri loop for the files at given paths in a supervisable
    `GenServer`. If any of the files change, then the given action is fired.

    Actions can be:

    * `:stop`: `Application.stop/1` and `Application.unload/1` are called.
    * `:restart`: like `:stop` and then `Application.ensure_all_started/1`.

    Add it to a supervisor like this:
    ```
    opts =[ paths: ["file1","file2"], app: :sequeler, action: :reload ]
    worker( Sequeler.Harakiri, [opts] ),
    ```
  """

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @doc """
    Init callback, spawn the loop process and return the state
  """
  def init(args) do
    paths = args[:paths] |> Enum.map(fn(p) -> {p,nil} end)
    spawn_link fn -> loop(paths, args[:app], args[:action]) end
    {:ok, args}
  end

  @doc """
    Perform harakiri if given file is touched. Else keep an infinite loop
    sleeping given msecs each time.
  """
  def loop(paths, app, action, sleep_ms \\ 5_000) do
    paths = paths |> Enum.map(fn({path, mtime}) ->
      {path, check_file(path, app, action, mtime)}
    end)
    :timer.sleep sleep_ms
    loop paths, app, action, sleep_ms
  end

  def check_file(path, app, action, previous_mtime) do
    new_mtime = File.stat!(path).mtime
    if previous_mtime && (previous_mtime != new_mtime), do: fire(action, app)
    new_mtime
  end

  def fire(:stop,app) do
    :ok = Application.stop app
    :ok = Application.unload app
    :ok
  end

  def fire(:restart, app) do
    fire :stop, app
    {:ok, _} = Application.ensure_all_started app
    :ok
  end
end
