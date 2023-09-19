defmodule Neo.MixProject do
  use Mix.Project

  def project do
    [
      app: :neo,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger,:snowflake],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
#      # {:dep_from_hexpm, "~> 0.3.0"},
#      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
#      {:jason, "~> 1.4"},
#      {:bolt_sips, "~> 2.0"},
      {:csv, "~> 3.0"},
#            {:jason, "~> 1.2"},
      {:httpoison, "~> 1.8"},
      {:xlsxir, "~> 1.6.4"},
      {:snowflake, "~> 1.0"} ,
      {:ecto_sql, "~> 3.2"},
      {:postgrex, "~> 0.15"},
      {:timex, "~> 3.7"},

      {:bolt_sips, "~> 2.0.11"},
#      {:poison, "~> 3.0"} # 请确保这个版本号与你的需求相匹配

    ]
  end
end
