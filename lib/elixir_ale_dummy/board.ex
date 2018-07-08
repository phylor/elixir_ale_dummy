defmodule ElixirALEDummy.Board do
  use GenServer

  defmodule State do
    defstruct gpios: [], subscribers: []
  end

  def start_link(_options) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def gpios do
    GenServer.call(__MODULE__, :gpios)
  end

  def add_gpio(pin, gpio_pid) do
    GenServer.cast(__MODULE__, {:add_gpio, pin, gpio_pid})
  end

  def send_interrupt(pin, direction) do
    gpio_pid = get_pid(pin)
    requestor = GenServer.call(gpio_pid, :get_interrupt_requestor)

    Process.send(requestor, {:gpio_interrupt, pin, direction}, [])
  end

  def subscribe do
    GenServer.call(__MODULE__, :subscribe)
  end

  defp get_pid(pin) do
    GenServer.call(__MODULE__, {:get_pid, pin})
  end

  # Callbacks
  def handle_cast({:add_gpio, pin, gpio_pid}, state) do
    new_state = %State{state | gpios: [{pin, gpio_pid} | state.gpios]}
    GenServer.call(gpio_pid, :subscribe)
    {:noreply, new_state}
  end

  def handle_cast(:gpio_changed, state) do
    Enum.each(state.subscribers, fn subscriber ->
      Process.send(subscriber, :update, [])
    end)

    {:noreply, state}
  end

  def handle_call(:gpios, _from, state) do
    gpios =
      Enum.map(state.gpios, fn {_pin, pid} ->
        GenServer.call(pid, :read_full)
      end)

    {:reply, gpios, state}
  end

  def handle_call({:get_pid, pin_to_search}, _from, state) do
    pid =
      Enum.find(state.gpios, fn {pin, _pid} -> pin_to_search == pin end)
      |> elem(1)

    {:reply, pid, state}
  end

  def handle_call(:subscribe, from, state) do
    new_state = %State{state | subscribers: [elem(from, 0) | state.subscribers]}
    {:reply, :ok, new_state}
  end
end
