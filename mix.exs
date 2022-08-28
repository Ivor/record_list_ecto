defmodule RecordListEcto.MixProject do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))

  def project do
    [
      app: :record_list_ecto,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  defp docs do
    [
      name: "RecordListEcto",
      main: "readme",
      extras: ["README.md"],
      source_ref: @version,
      source_url: "https://github.com/ivor/record_list_ecto/"
    ]
  end

  defp package() do
    [
      description: "Ecto step implementations for RecordList",
      maintainers: ["Ivor Paul"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/ivor/record_list_ecto",
        "Changelog" =>
          "https://github.com/ivor/record_list_ecto/blob/#{@version}/CHANGELOG.md##{String.replace(@version, ".", "")}"
      },
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        ".formatter.exs",
        "VERSION",
        "LICENSE"
      ]
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
      {:eliver, "~> 2.0.0", only: :dev},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:nimble_options, "~> 0.4.0"},
      {:record_list, "~> 0.1.2"}
    ]
  end
end
