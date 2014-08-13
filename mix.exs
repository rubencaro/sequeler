defmodule Sequeler.Mixfile do
  use Mix.Project

  def project do
    [app: :sequeler,
     version: "0.0.1",
     elixir: "~> 0.15.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :cowboy, :plug, :emysql],
     mod: {Sequeler, []}]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [ {:cowboy, "~> 1.0.0"}, # plug needs this to be listed before...
      {:plug, github: "elixir-lang/plug", tag: "v0.5.3"},
      {:emysql, github: "Eonblast/Emysql"},
      {:jsex, github: "talentdeficit/jsex"} ]
  end
end