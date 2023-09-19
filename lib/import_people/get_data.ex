defmodule GetData do
  @moduledoc false
  def get_excel() do
    {:ok, pid} = Postgrex.start_link(
      hostname: "36.111.70.11",
      port: "9999",
      username: "postgres",
      password: "logdata",
      database: "tongzhu"
    )
    {:ok, content} = Xlsxir.extract("D:\\桌面\\服务对象1\\三岔街道关爱巡访平台数据导入模板（低保特困补漏人员）.xlsx", 1)
    list2 = Enum.map(
              3..100000,
              fn (line) ->
                id_card = Xlsxir.get_cell(content, Excel.convert_col("F", line))
                if id_card != nil do
                  id_card = String.replace(id_card, " ", "")
                  people = Connection.getc(pid, id_card)
                  id = Map.get(people, :id, nil)
                  region = Xlsxir.get_cell(content, Excel.convert_col("C", line))
                  community = Xlsxir.get_cell(content, Excel.convert_col("D", line))
                  name = Xlsxir.get_cell(content, Excel.convert_col("E", line))

                  labels = [
                    (
                      if Xlsxir.get_cell(content, Excel.convert_col("J", line)) == "是",
                         do: %{"category" => "特殊老年人", "levelA" => "独居老人"}, else: %{}),
                    (
                      if Xlsxir.get_cell(content, Excel.convert_col("M", line)) == "是",
                         do: %{"category" => "最低生活保障（边缘）", "levelA" => "农村低保"}, else: %{}),
                    (
                      if Xlsxir.get_cell(content, Excel.convert_col("N", line)) == "是",
                         do: %{"category" => "最低生活保障（边缘）", "levelA" => "城市低保"}, else: %{}),
                    (
                      if Xlsxir.get_cell(content, Excel.convert_col("Q", line)) == "是",
                         do: %{"category" => "特困人员救助供养", "levelA" => "分散供养"}, else: %{})
                  ]
                  labels = Enum.filter(labels, fn x -> x != %{} end)
                  label1 = Map.get(people, :label, [])
                  labels = labels ++ label1
                  labels = if labels == [], do: [%{"category" => "其他"}], else: labels
                  <<year :: binary - size(4), month :: binary - size(2), day :: binary - size(2)>> =
                    String.slice(id_card, 6..13)
                  birthday = (year <> "-" <> month <> "-" <> day)
                             |> DateLib.from_iso!()
                  org = %{"id" => "dbxqtz", "name" => "东部新区"}
                  labels = for label <- labels do
                    Enum.reduce(
                      label,
                      %{},
                      fn {key, value}, acc ->
                        if value != nil do
                          Map.put(acc, key, value)
                        else
                          acc
                        end
                      end
                    )
                  end
                  labels = updatalabels(labels)
                  args = %{
                    "address" => "四川省,成都市,东部新区-#{region},#{community}",
                    "region" => region,
                    "community" => community,
                    "name" => name,
                    "id" => id,
                    "id_card" => id_card,
                    "birthday" => birthday,
                    "label" => labels,
                    "org" => org
                  }
                  args = Enum.reduce(
                    args,
                    %{},
                    fn {key, value}, acc ->
                      if value != nil do
                        Map.put(acc, key, value)
                      else
                        acc
                      end
                    end
                  )

                  args2 = args
                  #                           添加 否则 修改
                  if id == nil do
                    id3 = ImportVisit.testSnowflake
                    args2= Map.put(args2, "id", id3)
                    args2=Map.put(args2, "type", 1)
                    args2=Map.put(args2, "status", 1)
                    now = Timex.now()
                    {:ok,formatted_datetime} = Timex.format(now, "{ISO:Extended}")
                    {:ok,formatted_datetime} =Timex.parse(formatted_datetime, "{ISO:Extended}")
                    #                    formatted_datetime=  DateLib.from_iso!(formatted_datetime)
                    args2=Map.put(args2, "ts", formatted_datetime)
                    Connection.insert(pid, args2)
                  else
                                                  Connection.update(pid,args2)
                  end

                  args
                end
              end
            )
            |> Enum.filter(&(&1 != nil))

    json_data = Jason.encode!(list2)
    file_name2 = "D:\\桌面\\服务对象1\\三岔街道关爱巡访平台数据导入模板（低保特困补漏人员）1.json"
    File.write(file_name2, json_data)
  end

  def  testData()do
    data = [
      %{
        "category" => "特困人员救助供养",
        "levelA" => "分散供养"
      },
      %{
        "category" => "特困人员救助供养",
        "levelA" => "分散供养"
      },
      %{
        "category" => "特殊老年人",
      }
    ]

    data = updatalabels(data)
    IO.inspect(data)
  end
  def  updatalabels(data)do
    filtered_data = Enum.reduce(
      data,
      [],
      fn (map, acc) ->
        category = map["category"]
        ru = case Enum.find(acc, fn (existing_map) -> existing_map["category"] == category end) do
          nil ->
            acc ++ [map]
          existing_map ->

            if Map.size(map) > Map.size(existing_map) do
              [map] ++ Enum.reject(acc, fn (m) -> m["category"] == category end)
            else
              acc
            end
        end
      end
    )
  end


end

