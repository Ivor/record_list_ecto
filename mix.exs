defmodule RecordListEcto.MixProject do
  use Mix.Project

  def project do
    [
      app: :record_list_ecto,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.8"},
      {:record_list, path: "../record_list"},
      {:nimble_options, "~> 0.4.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
      # {:record_list, git: "git@github.com:Ivor/record_list.git", tag: "0.1.0"}
    ]
  end
end
