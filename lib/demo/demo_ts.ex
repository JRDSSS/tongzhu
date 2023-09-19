defmodule DemoTs do
  @moduledoc false

  def test_ts() do
#    input_str = "2023-08-02 14:28:39 2023-08-09      13:04:00      2023-08-15 15:06:09 2023-08-23   14:28:02"
#    # 使用正则表达式将多个连续空格替换为一个空格
#    output_str = Regex.replace(~r/\s+/, input_str, " ")
#
#    IO.inspect(output_str)
#    regex = ~r/2023.*?(?=2023|$)/
#
#    matches = Regex.scan(regex, output_str)
#    IO.inspect(matches)
#
#    # 使用 Enum.flat_map/2 将子列表中的字符串提取并放入新的列表
#    flat_list = Enum.flat_map(matches, fn [str] -> [str] end)
#
#    IO.inspect(flat_list)


#    input_str = "2023-07-07 10:00"
#
#    # 使用多个分隔符来分割字符串
#    split_chars = ~r/[- :]/
#    result_list = String.split(input_str, split_chars)
#
#    filtered_list = Enum.filter(result_list, fn str -> String.length(str) > 0 end)
#    IO.inspect result_list
#    IO.inspect filtered_list



    input_list = ["2023", "07", "05", "9", "11", "19"]

    padded_list = Enum.map(input_list, fn str ->
      if String.length(str) == 1 do
        "0" <> str
      else
        str
      end
    end)

    IO.inspect padded_list



  end

end
