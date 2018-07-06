defmodule ElixirALE.GPIO do
  use GenServer

  def start_link(pin, pin_direction) do
    GenServer.start_link(__MODULE__, [pin, pin_direction], name: __MODULE__)
  end

  def set_int(pid, direction) do
  end
end
