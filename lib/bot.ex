defmodule Cpg.Bot do
  @moduledoc false
  use Slack
  @state %{
    actions: []
  }

  def start_link(token),
  do: Slack.Bot.start_link(__MODULE__, @state, token, %{name: __MODULE__})

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    [target | text] = message |> Map.get(:text, "") |> String.split(" ")
    if target != "<@#{slack.me.id}>" do
      {:ok, state}
    else
      {cmd, text} = List.pop_at(text, 0)
      text = Enum.join(text, " ")
      new_actions = state.actions ++ [{message.ts, message.user, cmd, text}]
      new_state = put_in(state, [:actions], new_actions)

      build_response(new_state, message.user) |> send_message(message.channel, slack)

      {:ok, new_state}
    end
  end
  def handle_event(_, _, state), do: {:ok, state}

  def build_response(%{actions: actions}, user) do
    actions
    |> Enum.filter(&(elem(&1, 1) == user))
    |> Enum.map(fn {_, _, cmd, text} -> {cmd, text} end)
    |> Cpg.Fsm.respond_to
  end

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}	
end