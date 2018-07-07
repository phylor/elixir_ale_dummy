defmodule ElixirALE.GPIO do
  use GenServer

  defmodule State do
    @moduledoc """
    Keeps track of:
      * the gpio `pin` number
      * the current `pin_state` (`0` for logic low or `1` for logic high)
      * the `direction` (`:input` or `:output`)
      * the `interrupt_direction` (`:falling`, `:rising` or `:both`)
      * the `interrupt_requestor` of an interrupt
      * the `subscribers` which get notified when the state changes
    """
    defstruct pin: nil,
              pin_state: nil,
              direction: nil,
              interrupt_direction: nil,
              interrupt_requestor: nil,
              subscribers: []
  end

  def start_link(pin, pin_direction, options \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {pin, pin_direction}, options)

    ElixirALEDummy.Board.add_gpio(pin, pid)

    {:ok, pid}
  end

  def init({pin, pin_direction}) do
    state = %State{pin: pin, direction: pin_direction, pin_state: 0}
    {:ok, state}
  end

  # API of ElixirALE
  def write(pid, value) do
    GenServer.call(pid, {:write, value})
  end

  def read(pid) do
    GenServer.call(pid, :read)
  end

  def set_int(pid, direction) do
    GenServer.call(pid, {:set_int, direction, self()})
  end

  # Custom functions of ElixirALEDummy
  def read_full(pid) do
    GenServer.call(pid, :read_full)
  end

  def subscribe(pid) do
    GenServer.call(pid, :subscribe)
  end

  # Callbacks
  def handle_call(:read, _from, state) do
    {:reply, state.pin_state, state}
  end

  def handle_call({:write, value}, _from, state) do
    new_state = %State{state | pin_state: value}

    notify_all(state.subscribers, new_state)

    {:reply, :ok, new_state}
  end

  def handle_call({:set_int, direction, requestor}, _from, state) do
    new_state = %State{state | interrupt_direction: direction, interrupt_requestor: requestor}

    notify_all(state.subscribers, new_state)

    {:reply, :ok, new_state}
  end

  def handle_call(:read_full, _from, state) do
    output =
      Map.from_struct(state) |> Map.take([:pin, :pin_state, :direction, :interrupt_direction])

    {:reply, output, state}
  end

  def handle_call(:get_interrupt_requestor, _from, state) do
    {:reply, state.interrupt_requestor, state}
  end

  def handle_call(:subscribe, from, state) do
    new_state = %State{state | subscribers: [elem(from, 0) | state.subscribers]}
    {:reply, :ok, new_state}
  end

  defp notify_all(subscribers, _new_state) do
    Enum.each(subscribers, fn subscriber ->
      GenServer.cast(subscriber, :gpio_changed)
    end)
  end
end
