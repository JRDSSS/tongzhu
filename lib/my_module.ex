#
#
#defmodule MyModule do
#  def format_time(time) when is_binary(time) do
#    # 如果是字符串，尝试将其转换为时间格式
#    case DateTime.from_naive(time) do
#      {:ok, datetime} ->
#        DateTime.to_string(datetime, "yyyy-MM-dd HH:mm:ss")
#      _ ->
#        time  # 如果无法转换为时间格式，保持不变
#    end
#  end
#
#  def format_time(time) when is_tuple(time) do
#    # 如果已经是时间格式，直接将其转换为字符串
#    DateTime.to_string(time, "yyyy-MM-dd HH:mm:ss")
#  end
#end
#
### 测试
##time_str = "~N[2023-05-04 10:30:00]"
##formatted_time_str = MyModule.format_time(time_str)
##IO.puts(formatted_time_str)
##
##time_tuple = ~N[2023-05-04 10:30:00]
##formatted_time_tuple = MyModule.format_time(time_tuple)
##IO.puts(formatted_time_tuple)
##
##other_value = "This is not a time"
##formatted_other = MyModule.format_time(other_value)
##IO.puts(formatted_other)
