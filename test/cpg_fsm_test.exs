defmodule CpgFsmTest do
  use ExUnit.Case
  doctest Cpg.Fsm

  test "the fsm" do
    user = "<@sam>"
    state = %{
      actions: [
        {"_", user, "run", ""},
        {"_", user, "stop", ""}
      ]
    }

    res = state.actions
    |> Enum.filter(&(elem(&1, 1) == user))
    |> Enum.map(fn {_, _, cmd, text} -> {cmd, text} end)
    |> Cpg.Fsm.respond_to

    assert res == "Switching to Stopped."
  end
end
