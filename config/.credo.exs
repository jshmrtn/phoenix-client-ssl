%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test", "mix.exs"],
        excluded: []
      },
      checks: [
        # For others you can also set parameters
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
      ]
    }
  ]
}
