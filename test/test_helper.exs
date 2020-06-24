cowboy_version =
  :cowboy
  |> Application.spec(:vsn)
  |> to_string()
  |> Version.parse!()

options =
  cond do
    Version.match?(cowboy_version, "~> 1.0") -> [exclude: [:cowboy_2]]
    Version.match?(cowboy_version, "~> 2.0") -> [exclude: [:cowboy_1]]
    true -> raise "unknown cowboy version"
  end

ExUnit.start(options)
