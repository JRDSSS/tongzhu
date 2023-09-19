defmodule Excel do
  @moduledoc false
  def convert_col(col, line) when is_integer(col) do
    List.to_string([col]) <> "#{line}"
  end
  def convert_col(col, line) do
    "#{col}#{line}"
  end
end
