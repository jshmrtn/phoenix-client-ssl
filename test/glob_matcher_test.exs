defmodule GlobMatcherTest do
  @moduledoc false

  use ExUnit.Case

  doctest GlobMatcher

  describe "match/2" do

    @test_cases [
      {"*.example.com",           "foo.example.com",      true},
      {"*.example.com",           "example.com",          false},
      {"*.example.com",           "something.com",        false},
      {"example.com",             "example.com",          true},
      {"foo.*.example.com",       "foo.bar.example.com",  true},
      {"foo.*.example.com",       "xyz.bar.example.com",  false},
      {"foo",                     "xyz.bar.example.com",  false},
    ]

    for {pattern, subject, result} <- @test_cases do
      expected_state = if result, do: "works", else: "fails"

      test "#{pattern} | #{subject} #{expected_state}" do
        assert GlobMatcher.matches?(unquote(pattern), unquote(subject)) == unquote(result)
      end
    end
  end
end
