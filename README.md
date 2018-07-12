# Elixir ALE Dummy

A dummy implementation of [ElixirALE](https://github.com/fhunleth/elixir_ale). It allows applications to run on hardware without GPIOs.

## Installation

Add `elixir_ale_dummy` to the list of dependencies in `mix.exs`. When using [Nerves](https://nerves-project.org), restrict this package to the `"host"` target.

```elixir
def deps("host") do
  [
    {:elixir_ale_dummy, "~> 0.1.2"}
  ]
end
```

Start the simulator by adding the following to your startup code:

```elixir
if Mix.Project.config()[:target] == "host" do
  ElixirALEDummy.start(8080)
end
```

Visit [http://localhost:8080](http://localhost:8080) to view the state of the GPIOs.
