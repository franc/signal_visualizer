defmodule AudioVisualizer.Renderer do
  def render(canvas, data) do
    draw_lines(canvas, data)
  end

  def draw_lines(canvas, _data) do
    draw_line(canvas)
  end

  def draw_line(canvas) do
    pen = :wxPen.new({255, 0, 0, 255})
    :wxGraphicsContext.setPen(canvas, pen)
    :wxGraphicsContext.drawLines(canvas, [{100, 100}, {200, 200}])
    :ok
  end
end
