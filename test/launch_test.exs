defmodule LaunchTest do
  use ExUnit.Case
  doctest Launch

  test "greets the world" do
    assert Launch.hello() == :world
  end
end
