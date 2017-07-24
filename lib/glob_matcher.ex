defmodule GlobMatcher do
  @moduledoc """
  Glob Pattern Checker
  """

  @doc """
  Check if pattern matches.

  ### Examples

      iex> GlobMatcher.matches?("*.example.com", "foo.example.com")
      true

      iex> GlobMatcher.matches?("*.example.com", "example.com")
      false

      iex> GlobMatcher.matches?(["*.example.com", "example.com"], "example.com")
      true

  """
  def matches?(pattern, subject) when pattern == subject, do: true
  def matches?(patterns, subject) when is_list(patterns) do
    Enum.any?(patterns, fn pattern -> matches?(pattern, subject) end)
  end
  def matches?(pattern, subject) do
    pattern_parts = String.split(pattern, ".")
    subject_parts = String.split(subject, ".")

    if Enum.count(pattern_parts) == Enum.count(subject_parts) do
      pattern_parts
      |> Enum.zip(subject_parts)
      |> Enum.all?(fn
        {pattern, subject} when pattern == subject ->
          true
        {"*", _subject} ->
          true
        {_pattern, _subject} ->
          false
      end)
    else
      false
    end
  end
end
