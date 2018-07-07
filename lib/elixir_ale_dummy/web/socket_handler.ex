defmodule ElixirALEDummy.Web.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init({_tcp, _http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    IO.puts("New websocket connection. PID is #{inspect(self())}")

    ElixirALEDummy.Board.subscribe()

    # Force first update
    Process.send(self(), :update, [])

    {:ok, req, :undefined_state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  def websocket_handle({:text, content}, req, state) do
    {:ok, %{"pin" => pin, "interrupt_direction" => direction}} = Poison.decode(content)

    ElixirALEDummy.Board.send_interrupt(pin, String.to_atom(direction))

    {:ok, req, state}
  end

  def websocket_handle(_data, req, state) do
    {:ok, req, state}
  end

  def websocket_info(:update, req, state) do
    gpios = ElixirALEDummy.Board.gpios()

    {:ok, message} = Poison.encode(%{gpios: gpios})

    {:reply, {:text, message}, req, state}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state}
  end
end
