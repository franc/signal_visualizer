defmodule AudioVisualizer.Renderer do
  @center_y 100

  def render(canvas, data) do
    draw_lines(canvas, data)
  end

  def draw_lines(canvas, [head|rest]) do
    draw_line(canvas, head)
    draw_lines(canvas, rest)
  end
  def draw_lines(canvas, []), do: :ok

  def draw_line(canvas, {position, amplitude}) do
    IO.puts amplitude
    pen = :wxPen.new({255, 0, 0, 255})
    :wxGraphicsContext.setPen(canvas, pen)
    :wxGraphicsContext.drawLines(canvas, [{0 + position, @center_y}, {0 + position, amplitude}])
    :ok
  end
end
