# Not sure if this is a proper usage of wxWidgets. Ripped of bits and pieces
# from Erlang's :wx.demo source.

# This is from @sasajuric's library: pythaforas_tree

defmodule AudioVisualizer.MainWindow do
  @behaviour :wx_object

  def start(title, opts) do
    :wx_object.start(AudioVisualizer.MainWindow, {title, opts}, [])
  end

  def draw_lines(object, lines) do
    :wx_object.call(object, {:draw_lines, lines})
    object
  end

  def draw_points(object, points) do
    #draw_lines(object, points_to_lines(points))
    #IO.inspect points
    #points_to_lines(points)
    #|> Enum.chunk(2, 1)
    #|> Enum.map(&(:wx_object.call(object, {:draw_lines, &1})))
    :wx_object.call(object, {:draw_lines, points_to_lines(points)})
    object
  end

  def points_to_lines(points) do
    #[{0,0}, {1,1}, {2, 2}] => [{{0,0}, {1, 1}}, {{1, 1}, {2, 2}}]
    points
    |> Stream.chunk(2, 1)
    |> Enum.map(&List.to_tuple/1)
  end

  def init({title, opts}) do
    wx = :wx.new
    window = :wxFrame.new(wx, -1, '#{title}', opts)
    :wxFrame.show(window)
    {width, height} = opts[:size]
    bitmap = :wxBitmap.new(width, height)
    :wxFrame.connect(window, :paint, [:callback])
    {window, %{window: window, bitmap: bitmap}}
  end

  def handle_sync_event({:wx, _, _, _, {:wxPaint, _}}, _, state) do
    dc = :wxPaintDC.new(state.window)
    memory_dc = :wxMemoryDC.new(state.bitmap)

    :wxDC.blit(dc, {0,0}, :wxWindow.getSize(state.window), memory_dc, {0,0})

    :wxPaintDC.destroy(dc)
    :wxMemoryDC.destroy(memory_dc)
    :ok
  end

  def handle_event(_, state), do: {:noreply, state}

  def handle_call({:draw_lines, lines}, _, state) do
    memory_dc = :wxMemoryDC.new(state.bitmap)
    dc = :wxClientDC.new(state.window)

    IO.puts "handle_event"

    for {from, to} <- lines do
      :wxDC.drawLine(memory_dc, from, to)
    end

    :wxDC.blit(dc, {0,0}, :wxWindow.getSize(state.window), memory_dc, {0,0})

    :wxClientDC.destroy(dc)
    :wxMemoryDC.destroy(memory_dc)
    {:reply, :ok, state}
  end

  def handle_call(:shutdown, _, state), do: {:stop, :normal, :ok, state}
  def handle_call(_, _, state), do: {:noreply, state}

  def handle_cast(_, state), do: {:noreply, state}

  def handle_info(_, state), do: {:noreply, state}
  def code_change(_, _, state), do: {:ok, state}
  def terminate(_, _), do: :ok
end