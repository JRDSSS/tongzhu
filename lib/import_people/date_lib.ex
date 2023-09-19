defmodule DateLib do
  @moduledoc false
  def from_iso!(date) do
    case Date.from_iso8601(date) do
      {:ok, v} ->
        v
      {_, _} ->
        PrivateCandy.debug_remind(__ENV__, "#{date} not valid")
    end
  end

end
