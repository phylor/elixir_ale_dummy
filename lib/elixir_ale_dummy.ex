defmodule ElixirALEDummy do
  def start(port \\ 8080) do
    ElixirALEDummy.Web.start_link(port)
    ElixirALEDummy.Board.start_link()
  end
end
