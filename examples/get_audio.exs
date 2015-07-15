{:ok, data_agent} = Agent.start_link(fn -> [] end)

defmodule AudioReceiver do
  def start(data_agent) do
    Port.open({:spawn, "parec --rate=16000 --format=u8 -n 'alsa_input.usb-BLUE_MICROPHONE_Blue_Snowball_201306-00-Snowball.analog-stereo'"}, [])
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

spawn(fn() ->
  AudioReceiver.start(data_agent)
end)

AudioVisualizer.Window.start(data_agent)
