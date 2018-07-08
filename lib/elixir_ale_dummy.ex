defmodule ElixirALEDummy do
  def start(port \\ 8080) do
    Supervisor.start_link(children(port), strategy: :one_for_one, name: ElixirALEDummy.Supervisor)
  end

  defp children(port) do
    [
      {ElixirALEDummy.Web, [port: port]},
      {ElixirALEDummy.Board, []}
    ]
  end
end
