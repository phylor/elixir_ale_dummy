defmodule ElixirALEDummy.Web do
  def child_spec([port: port] \\ [port: 8080]) do
    Plug.Adapters.Cowboy.child_spec(:http, __MODULE__, [], port: port, dispatch: dispatch())
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", ElixirALEDummy.Web.SocketHandler, []},
         {"/", :cowboy_static, {:priv_file, :elixir_ale_dummy, "index.html"}},
         {"/[...]", :cowboy_static, {:priv_dir, :elixir_ale_dummy, "static/"}}
       ]}
    ]
  end
end
