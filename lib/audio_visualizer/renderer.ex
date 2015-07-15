defmodule AudioVisualizer.Renderer do
  @center_y 500
  @resolution 16
  @multiplier 3

  def render(canvas, data) do
    draw_lines(canvas, Enum.with_index(data))
  end

  def draw_lines(canvas, [head|rest]) do
    draw_line(canvas, head)
    draw_lines(canvas, rest)
  end
  def draw_lines(canvas, []), do: :ok

  def draw_line(canvas, {amplitude, position}) do
    case rem(position, @resolution) do
      0 ->
        pen = :wxPen.new({255, 0, 0, 255})
        x = 0 + position/@resolution
        :wxGraphicsContext.setPen(canvas, pen)
        :wxGraphicsContext.drawLines(canvas, [
          {x, @center_y},
          {x, @center_y + (-128 + amplitude) * @multiplier}
        ])
      _ ->
        :ok
    end
    :ok
  end
end
