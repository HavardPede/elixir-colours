defmodule ColoursTest do
  use ExUnit.Case
  doctest Colours

  test "greets the world" do
    assert Colours.hello() == :world
  end
end
