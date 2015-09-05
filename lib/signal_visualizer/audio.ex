defmodule SignalVisualizer.Audio do

  def start(opts \\ []) do
    {:ok, data_agent} = Agent.start_link(fn -> [] end)

    spawn(fn() ->
      AudioReceiver.start(data_agent)
    end)

    window = SignalVisualizer.Window.start("Audio Visualizer", Keyword.merge([pos: {20, 20}, size: {500, 550}], opts))

    receive do
      :ok -> :ok
      after 100 -> # Have to wait for a little for the window to exist
                   # before creating the drawing context
        draw(data_agent, window)
    end
    receive do
      :ok -> :ok
    end

    :ok
  end

  def draw(data_agent, window) do
    do_draw(data_agent, window)
  end

  def do_draw(data_agent, :error) do
    IO.puts "Bye!"
    Agent.stop data_agent
    exit :shutdown
  end

  def do_draw(data_agent, window) do
    w = SignalVisualizer.Window.draw_points(window, Agent.get(data_agent, fn(data) ->
      a = Enum.take(data, 16_000)
      points(sample(Enum.with_index(a)))
    end))
    :timer.sleep(10)
    do_draw(data_agent, w)
  end

  @center_y 0
  @resolution 16
  @multiplier 3
  def sample(data) do
    sample(data, [])
  end
  def sample([{amplitude, position}|rest], acc) do
    case rem(position, @resolution) do
      0 ->
        sample(rest, [{amplitude, position}|acc])
      _ ->
        sample(rest, acc)
    end
  end
  def sample([], acc), do: Enum.reverse(acc)

  def points(sampled_data) do
    Enum.map(sampled_data, fn({amplitude, position}) ->
      x = 0 + position/@resolution
      y = -128 + amplitude * @multiplier
      {round(x), round(@center_y + y)}
    end)
  end

end


defmodule AudioReceiver do
  def start(data_agent) do
    Port.open({:spawn, "sox -d -q -V0 -e unsigned-integer -b 8 -c 1 -t u8 -"}, [])
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
