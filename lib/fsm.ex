defmodule Cpg.Fsm do
  @moduledoc false
  use Fsm, initial_state: :stopped

  def respond_to(actions) do
    actions
    |> Enum.reduce({{:init, "Starting..."}, Cpg.Fsm.new}, &reduce/2)
    |> elem(0)
    |> elem(1)
  end

  defp reduce({cmd, text}, {_resp, fsm}), do: transition(fsm, cmd, [text])

  # STOPPED
  defevent _, state: :stopped, event: "run",
  do: respond({:ok, "Switching to Running."}, :running)

  # RUNNING
  defevent _, state: :running, event: "stop",
  do: respond({:ok, "Switching to Stopped."}, :stopped)

  # ERROR
  defevent _, event: e, state: s,
  do: respond({:err_unknown_evt, "I don't understand: #{s} > #{e}"})
end
