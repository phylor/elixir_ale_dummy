# Elixir ALE Dummy

A dummy implementation of [ElixirALE](https://github.com/fhunleth/elixir_ale). It allows applications to run on hardware without GPIOs.

## Installation

Add `elixir_ale_dummy` to the list of dependencies in `mix.exs`. When using [Nerves](https://nerves-project.org), restrict this package to the `"host"` target.

```elixir
def deps("host") do
  [
    {:elixir_ale_dummy, "~> 0.1.0"}
  ]
end
```
