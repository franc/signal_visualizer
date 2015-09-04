defmodule AudioVisualizer.GetAudio do
  def start do
    {:ok, data_agent} = Agent.start_link(fn -> [] end)

    spawn(fn() ->
      AudioReceiver.start(data_agent)
    end)

    AudioVisualizer.Window.start(data_agent)
  end
end

defmodule AudioReceiver do
  def start(data_agent) do
    Port.open({:spawn, "sox -d -q -e unsigned-integer -b 8 -c 1 -t u8 -"}, [])
    loop(data_agent)
  end

  def loop(data_agent) do
    receive do
      {_, {:data, data}} ->
        Agent.update(data_agent, fn(existing_data) ->
          data ++ existing_data
        end)
      other -> IO.inspect "got other: #{inspect other}"
    end
    loop(data_agent)
  end
end
