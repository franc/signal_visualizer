defmodule AudioVisualizer.Renderer do
  @center_y 100
  @resolution 16
  @multiplier 3

  def render(canvas, data) do
    draw_lines(canvas, Enum.with_index(data))
  end

  def draw_lines(canvas, data) do
    sampled_data = sample(data)
    do_draw_lines(canvas, points(sampled_data))
  end

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
      y = -127 + amplitude * @multiplier
      {x, @center_y + y}
    end)
  end

  def do_draw_lines(_canvas, []), do: :ok
  def do_draw_lines(canvas, points) do
    pen = :wxPen.new({255, 0, 0, 255})
    :wxGraphicsContext.setPen(canvas, pen)
    :wxGraphicsContext.drawLines(canvas, points)
    :ok
  end
end
