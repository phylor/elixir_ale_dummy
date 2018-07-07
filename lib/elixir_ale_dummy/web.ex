defmodule ElixirALEDummy.Web do
  def start_link(port \\ 8080) do
    Plug.Adapters.Cowboy.http(__MODULE__, [], port: port, dispatch: dispatch())
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", ElixirALEDummy.Web.SocketHandler, []},
         {"/", :cowboy_static, {:priv_file, :elixir_ale_dummy, "index.html"}}
       ]}
    ]
  end
end
