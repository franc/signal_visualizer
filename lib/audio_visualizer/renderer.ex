defmodule AudioVisualizer.Renderer do
  @center_y 500
  @resolution 16
  @multiplier 3

  def render(dc, data) do
    canvas = :wxGraphicsContext.create(dc)
    draw_lines(canvas, dc, Enum.with_index(data))
  end

  def draw_lines(canvas, dc, data) do
    sampled_data = sample(data)
    do_draw_lines(canvas, dc, points(sampled_data))
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
      y = -128 + amplitude * @multiplier
      {round(x), round(@center_y + y)}
    end)
  end

  def do_draw_lines(_canvas, _dc, []), do: :ok
  def do_draw_lines(canvas, dc, points) do
    :wxPaintDC.clear(dc)
    pen = :wxPen.new({255, 0, 0, 255})
    :wxGraphicsContext.setPen(canvas, pen)
    :wxGraphicsContext.drawLines(canvas, points)
  end
end
