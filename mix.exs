defmodule ElixirAleDummy.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_ale_dummy,
      version: "0.1.2",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "An ElixirALE implementation for hosts without GPIOs.",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:elm_compile, "~> 0.1.0", only: :dev},
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.4"},
      {:poison, "~> 3.1"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Serge Hänni"],
      links: %{"GitHub" => "https://github.com/phylor/elixir_ale_dummy"}
    ]
  end
end
