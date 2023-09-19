#defmodule New_import_1wumiao do
#  @moduledoc false
#  def get_excel() do
#    {:ok, pid} = Postgrex.start_link(
#      hostname: "36.111.70.11",
#      port: "9999",
#      username: "postgres",
#      password: "logdata",
#      database: "tongzhu"
#    )
#    filename = "import_9_5"
#    {:ok, content} = Xlsxir.extract("D:\\java\\工作文件夹\\新建文件夹\\新建文件夹\\#{filename}.xlsx", 0)
#    list2 = Enum.map(
#              3..100000,
#              fn (line) ->
#                id_card = Xlsxir.get_cell(content, Excel.convert_col("F", line))
#                if id_card != nil do
#                  id_card = String.replace(id_card, " ", "")
#                  people = Connection.getc(pid, id_card)
#                  id = Map.get(people, :id, nil)
#                  region = Xlsxir.get_cell(content, Excel.convert_col("C", line))
#                  community = Xlsxir.get_cell(content, Excel.convert_col("D", line))
#                  name = Xlsxir.get_cell(content, Excel.convert_col("E", line))
#                  resident = Xlsxir.get_cell(content, Excel.convert_col("I", line))
#
#                  labels = [
#                    %{"category" => "特殊群体儿童", "levelA" =>   Xlsxir.get_cell(content, Excel.convert_col("T", line))},
#                    (
#                      if Xlsxir.get_cell(content, Excel.convert_col("L", line)) == "是",
#                         do: %{"category" => "残疾人"}, else: %{}),
#                    (
#                      if Xlsxir.get_cell(content, Excel.convert_col("M", line)) == "是",
#                         do: %{"category" => "最低生活保障（边缘）", "levelA" => "农村低保"}, else: %{})
#                  ]
#                  labels = Enum.filter(labels, fn x -> x != %{} end)
#                  label1 = Map.get(people, :label, [])
#                  labels = labels ++ label1
#                  labels = if labels == [], do: [%{"category" => "其他"}], else: labels
#                  <<year :: binary - size(4), month :: binary - size(2), day :: binary - size(2)>> =
#                    String.slice(id_card, 6..13)
#                  birthday = (year <> "-" <> month <> "-" <> day)
#                             |> DateLib.from_iso!()
#                  org = %{"id" => "dbxqtz", "name" => "东部新区"}
#                  labels = for label <- labels do
#                    Enum.reduce(
#                      label,
#                      %{},
#                      fn {key, value}, acc ->
#                        if value != nil do
#                          Map.put(acc, key, value)
#                        else
#                          acc
#                        end
#                      end
#                    )
#                  end
#                  labels = GetData.updatalabels(labels)
#                  args = %{
#                    "address" => "四川省,成都市,东部新区-#{region},#{community}",
#                    "resident" => resident,
#                    "region" => region,
#                    "community" => community,
#                    "name" => name,
#                    "id" => id,
#                    "id_card" => id_card,
#                    "birthday" => birthday,
#                    "label" => labels,
#                    "org" => org
#                  }
#                  args = Enum.reduce(
#                    args,
#                    %{},
#                    fn {key, value}, acc ->
#                      if value != nil do
#                        Map.put(acc, key, value)
#                      else
#                        acc
#                      end
#                    end
#                  )
#
#                  args2 = args
#                  #                                             添加 否则 修改
#                  if id == nil do
#                    id3 = WjImport.testSnowflake
#                    args2= Map.put(args2, "id", id3)
#                    args2=Map.put(args2, "type", 1)
#                    args2=Map.put(args2, "status", 1)
#                    now = Timex.now()
#                    {:ok,formatted_datetime} = Timex.format(now, "{ISO:Extended}")
#                    {:ok,formatted_datetime} =Timex.parse(formatted_datetime, "{ISO:Extended}")
#                    #                    formatted_datetime=  DateLib.from_iso!(formatted_datetime)
#                    args2=Map.put(args2, "ts", formatted_datetime)
#                    Connection.insert(pid, args2)
#                  else
#                    Connection.update(pid,args2)
#                  end
#
#                  args
#                end
#              end
#            )
#            |> Enum.filter(&(&1 != nil))
#
#    json_data = Jason.encode!(list2)
#    file_name2 = "D:\\java\\工作文件夹\\新建文件夹\\新建文件夹\\#{filename}.json"
#    File.write(file_name2, json_data)
#  end
#
#end
#
