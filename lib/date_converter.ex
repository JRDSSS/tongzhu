defmodule DateConverter do
  use Timex

  def convert_to_gmt8!(date_string) do
    # date_string  有2种类型 2023-04-24    2023-01-01 01:01:01   都转换为 date类型

    if date_string != nil do
      date_string = String.trim(date_string)
      date_string=
        case Timex.parse(date_string, "{YYYY}-{0M}-{D}") do
          {_, result} -> result
          {:error, reason} ->
            raise reason
        end

    end
    #   try do   rescue end

  end
end
