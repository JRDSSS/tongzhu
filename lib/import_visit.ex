defmodule ImportVisit do
  @moduledoc false

  def import1() do
    {:ok, pid} =
      Postgrex.start_link(
        hostname: "36.111.70.11",
        port: "9999",
        username: "postgres",
        password: "logdata",
        database: "tongzhu"
      )

    filename = "巡查巡防"
    {:ok, labeldata} = File.read("D:\\桌面\\温江标签.json")
    labeldata = Jason.decode!(labeldata)
    labelkey1 = Map.keys(labeldata)
    labelvalues = Map.values(labeldata)
    labelvalues = Enum.reduce(labelvalues, %{}, fn map, acc -> Map.merge(acc, map) end)
    labelkey2 = Enum.map(labelvalues, fn {key, value} -> key end)
#IO.inspect(labeldata)
#IO.inspect(labelkey1)
#    IO.inspect(labelkey2)

    # 循环 7 次
#        for count <- 6..7 do
    # 输出当前循环的次数
    #      IO.puts("当前循环的次数：#{count}")

    {:ok, content} = Xlsxir.extract("D:\\桌面\\巡查巡防(1).xlsx", 7)

    list2 =
      Enum.map(
        2..100_000,
        fn line ->
          id_card = Xlsxir.get_cell(content, Excel.convert_col("A", line))

          id_card =
            if id_card == nil || String.contains?(id_card, "*") || String.length(id_card) == 0 do
              nil
            else
              id_card
            end

          if id_card != nil do
            #                  id_card为people的id_card
            id_card = String.replace(id_card, " ", "")
            people = Connection.getc(pid, id_card)
            id = Map.get(people, :id, nil)
            peo_name = Xlsxir.get_cell(content, Excel.convert_col("B", line))
            #                  if id == nil do
            #                    IO.puts "id为空"
            #                  else
            #                    IO.puts "id不为空"
            #                  end
            birthday =
              try do
                <<year::binary-size(4), month::binary-size(2), day::binary-size(2)>> =
                  String.slice(id_card, 6..13)

                birthday =
                  (year <> "-" <> month <> "-" <> day)
                  |> DateLib.from_iso!()
              rescue
                # 捕捉到异常时执行的代码
                _ -> nil
              end

            people = %{
              "name" => peo_name,
              "id_card" => id_card,
              "birthday" => birthday
            }

            nolabel = Xlsxir.get_cell(content, Excel.convert_col("C", line))

            labels =
              if nolabel != nil && nolabel != "" do
                String.split(nolabel, "_")
              else
                []
              end

            labels =
              Enum.map(labels, fn str ->
                result =
                  Enum.find(labelkey1, fn item ->
                    String.contains?(str, item)
                  end)

                if result != nil do
                  %{
                    "category" => result
                  }
                else
                  %{}
                end
              end)

            labels = Enum.filter(labels, fn map -> map != %{} end)

            labels =
              if length(labels) == 0 do
                labels = [
                  %{
                    "category" => "其他"
                  }
                ]
              else
                labels
              end

            people =
              Map.merge(people, %{
                "label" => labels
              })

            region = Xlsxir.get_cell(content, Excel.convert_col("D", line))
            community = Xlsxir.get_cell(content, Excel.convert_col("E", line))
            visiter_name = Xlsxir.get_cell(content, Excel.convert_col("F", line))
            visiter_phone = Xlsxir.get_cell(content, Excel.convert_col("G", line))

            visiter = %{
              "name" => visiter_name,
              "phone" => visiter_phone
            }

            start_date = Xlsxir.get_cell(content, Excel.convert_col("H", line))
            result_start = if is_tuple(start_date) do
#              IO.puts("这是一个元组")

                start_date
                |> Tuple.to_list()
                |> Enum.map(&Integer.to_string/1)  # 将整数转换为字符串
                |> Enum.map(&String.pad_leading(&1, 2, "0"))
                |> Enum.join("-")
            else
              start_date
            end

#            IO.inspect(result_start)

            end_date = Xlsxir.get_cell(content, Excel.convert_col("I", line))
            result_end = if is_tuple(end_date) do
#              IO.puts("这是一个元组")
                end_date
                |> Tuple.to_list()
                |> Enum.map(&Integer.to_string/1)  # 将整数转换为字符串
                |> Enum.map(&String.pad_leading(&1, 2, "0"))
                |> Enum.join("-")
            else
              end_date
            end

#            IO.inspect(result_end)
            visit_ts = Xlsxir.get_cell(content, Excel.convert_col("J", line))
            #
#            # 定义正则表达式模式匹配 ~N[...] 格式
#            regex_pattern = ~r/~N\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]/
#
#            case Regex.scan(regex_pattern, visit_ts) do
#              [match] ->
#                [_, datetime_str] = match
#                {:ok, datetime} = DateTime.from_naive!(datetime_str)
#                formatted_datetime = DateTime.to_string(datetime, "yyyy-MM-dd HH:mm:ss")
#                IO.puts(formatted_datetime)
#                visit_ts = formatted_datetime  # 将visit_ts更新为转换后的日期时间字符串
#              _ ->
#                IO.puts(visit_ts)
#            end
#
            IO.inspect(visit_ts)




            #            delimiter = ["、", ",", "\n"]  # 定义分隔符列表，包含顿号、逗号和换行符
#
#            # 使用String.split/3函数分割字符串并存储到列表
#            visit_ts_list = String.split(visit_ts, delimiter)
#
#            IO.inspect(visit_ts_list)

#            IO.inspect(visit_ts)

            period = Xlsxir.get_cell(content, Excel.convert_col("K", line))
            advice = Xlsxir.get_cell(content, Excel.convert_col("L", line))
            pension = Xlsxir.get_cell(content, Excel.convert_col("M", line))
            careInsurance = Xlsxir.get_cell(content, Excel.convert_col("N", line))
            unemploymentInsurance = Xlsxir.get_cell(content, Excel.convert_col("O", line))
            wageIncome = Xlsxir.get_cell(content, Excel.convert_col("P", line))
            employmentSituation = Xlsxir.get_cell(content, Excel.convert_col("Q", line))
            jy_intro = Xlsxir.get_cell(content, Excel.convert_col("R", line))
            ywcjjytj = Xlsxir.get_cell(content, Excel.convert_col("T", line))
            relation = Xlsxir.get_cell(content, Excel.convert_col("U", line))
            yjcd = Xlsxir.get_cell(content, Excel.convert_col("V", line))
            tfdxshzt = Xlsxir.get_cell(content, Excel.convert_col("W", line))
            microWishState = Xlsxir.get_cell(content, Excel.convert_col("X", line))
            #                  IO.inspect(microWishState)
            microWishState =
              if(microWishState == nil) do
                ""
              else
                microWishState = String.replace(microWishState, ~r/[\d.]/, "")
                microWishState = String.replace(microWishState, "、", "_")
                microWishState
              end

            microWishState =
              if String.contains?(microWishState, "_") do
                String.split(microWishState, "_")
              else
                if String.length(microWishState) > 0 do
                  [microWishState]
                else
                  nil
                end
              end

            nil

            visitType = Xlsxir.get_cell(content, Excel.convert_col("Y", line))

            visitType =
              if visitType != nil do
                String.replace(visitType, ~r/[\d.]/, "")
              else
                nil
              end

            psychologyHealthy = Xlsxir.get_cell(content, Excel.convert_col("Z", line))
            bcms = Xlsxir.get_cell(content, Excel.convert_col("AA", line))
            wjy_intro = Xlsxir.get_cell(content, Excel.convert_col("AB", line))

            org = %{"id" => "wjtz", "name" => "温江低收入平台"}

            args = %{
              "region" => region,
              "community" => community,
              "visiter" => visiter,
              "people" => people,
              "start_date" => result_start,
              "end_date" => result_end,
              "visit_ts" => visit_ts,
              "period" => period,
              "advice" => advice,
              "pension" => pension,
              "careInsurance" => careInsurance,
              "unemploymentInsurance" => unemploymentInsurance,
              "wageIncome" => wageIncome,
              "employmentSituation" => employmentSituation,
              "jy_intro" => jy_intro,
              "ywcjjytj" => ywcjjytj,
              "relation" => relation,
              "yjcd" => yjcd,
              "tfdxshzt" => tfdxshzt,
              "microWishState" => microWishState,
              "visitType" => visitType,
              "psychologyHealthy" => psychologyHealthy,
              "bcms" => bcms,
              "wjy_intro" => wjy_intro,
              "org" => org
            }

            args =
              Enum.reduce(
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
            args
          end
        end
      )
      |> Enum.filter(&(&1 != nil))

    IO.inspect(list2)
    json_data = Jason.encode!(list2)

    file_name2 = "D:\\工作文件\\巡访json\\巡查巡防7.json"
    File.write(file_name2, json_data)
  end

  def read_json() do
    {:ok, pid} =
      Postgrex.start_link(
        hostname: "36.111.70.11",
        port: "9999",
        username: "postgres",
        password: "logdata",
        database: "tongzhu"
      )

    for count <- 0..7 do
      file_name = "D:\\工作文件\\巡访json\\巡查巡防#{count}.json"
      {:ok, content} = File.read(file_name)
#      IO.inspect(content)
      data = Jason.decode!(content)
#      IO.inspect(data)

      Enum.each(
        data,
        fn line ->

          id_card = Map.get(line, "id_card", nil)
          people = Connection.getc(pid, id_card)
          peo_id = Map.get(people, :id, nil)
          args2 = Map.get(line, "people", %{})

          peo_id =
            if peo_id == nil do
              id3 = testSnowflake()
              args2 = Map.put(args2, "id", id3)
              args2 = Map.put(args2, "type", 1)
              args2 = Map.put(args2, "status", 1)
              now = Timex.now("Etc/GMT+8")
              args2 = Map.put(args2, "ts", now)
#                              Connection.inser_wjtz(pid, args2, "wjtz")
              id3
            else
              peo_id
            end

          {:ok, visit_id} = Snowflake.next_id()
          now = "2023-01-01 01:01:01"
          formatted_datetime =DateConverter.convert_to_gmt8!(now)
          ts = formatted_datetime
          detail=%{
            "pension" => Map.get(line, "pension", nil),
            "careInsurance" => Map.get(line, "careInsurance", nil),
            "unemploymentInsurance" => Map.get(line, "unemploymentInsurance", nil),
            "wageIncome" => Map.get(line, "wageIncome", nil),
            "employmentSituation" => Map.get(line, "employmentSituation", nil),
            "jy_intro" => Map.get(line, "jy_intro", nil),
            "ywcjjytj" => Map.get(line, "ywcjjytj", nil),
            "relation" => Map.get(line, "relation", nil),
            "yjcd" => Map.get(line, "yjcd", nil),
            "tfdxshzt" => Map.get(line, "tfdxshzt", nil),
            "microWishState" => Map.get(line, "microWishState", nil),
            "visitType" => Map.get(line, "visitType", nil),
            "psychologyHealthy" => Map.get(line, "psychologyHealthy", nil),
            "bcms" => Map.get(line, "bcms", nil),
            "wjy_intro" => Map.get(line, "wjy_intro", nil),
            "region" => Map.get(line, "region", nil),
            "community" => Map.get(line, "community", nil)
          }
          detail =
            Enum.reduce(
              detail,
              %{},
              fn {key, value}, acc ->
                if value != nil do
                  Map.put(acc, key, value)
                else
                  acc
                end
              end
            )

          now = Map.get(line, "end_date", nil)
#          IO.inspect(now)
          formatted_datetime =DateConverter.convert_to_gmt8!(now)
          end_date=formatted_datetime

          now = Map.get(line, "start_date", nil)
          formatted_datetime =DateConverter.convert_to_gmt8!(now)
          start_date=formatted_datetime

          visit_ts =
            try do
              now = Map.get(line, "visit_ts", nil)
              now = cond do
                String.contains?(now, ",") ->
                  String.replace(now, ",", " ")

                String.contains?(now, "，") ->
                  String.replace(now, "，", " ")

                String.contains?(now, "、") ->
                  String.replace(now, "、", " ")

                String.contains?(now, "：") ->
                  String.replace(now, "：", ":")

                String.contains?(now, ";") ->
                  String.replace(now, ";", ":")

                String.contains?(now, "T") ->
                  String.replace(now, "T", " ")

                String.contains?(now, "/") ->
                  String.replace(now, "/", "-")

                String.contains?(now, "\n") ->
                  String.replace(now, "\n", " ")
                true ->
                  now
              end
              #将多个空格替换成一个空格
              now = Regex.replace(~r/\s+/, now, " ")

#              IO.inspect(now)
#              IO.inspect("")
              #分割成多个以2023开头的字符串
              regex = ~r/2023.*?(?=2023|$)/
              matches = Regex.scan(regex, now)
#              IO.inspect(matches)

              # 使用 Enum.flat_map/2 将子列表中的字符串提取并放入新的列表
              flat_list = Enum.flat_map(matches, fn [str] -> [str] end)
              IO.inspect(flat_list)
              Enum.map(flat_list, fn item ->
                # 使用多个分隔符来分割字符串(-或" "或:)
                split_chars = ~r/[- :]/
                result_list = String.split(item, split_chars)

                #过滤掉空串
                filtered_list = Enum.filter(result_list, fn str -> String.length(str) > 0 end)
                #不足六个元素就在后面补充00
                filtered_list = if length(filtered_list) < 6 do
                  filtered_list ++ ["00"]
                  else
                  filtered_list
                end
                filtered_list = Enum.map(filtered_list, fn str ->
                  if String.length(str) == 1 do
                    "0" <> str
                  else
                    str
                  end
                end)

                IO.inspect filtered_list
              end)
              IO.inspect("下一个")

#              if  String.contains?(now,"\n") do
#                tsList=String.split(now,"\n")
##                IO.inspect(tsList)
#                tsList=Enum.filter(tsList,fn item  -> item != nil && String.length(item) != 0 end)
#
##                IO.inspect(tsList)
#                Enum.map(tsList,fn item ->
#                  item=String.replace(item," ","") |> String.replace("-","") |> String.replace(":","")
#                  {:ok, formatted_datetime}=Timex.parse(item, "{ASN1:GeneralizedTime}")
#                  formatted_datetime
#                end)
#              else
#                [end_date]
#              end
            rescue
              # 捕捉到异常时执行的代码
              _ -> [end_date]
            end


          args = %{
            "id" => visit_id,
            "people_id" => peo_id,
            "project_id" => "wjtz",
            "ts" => ts,
            "visiter" => Map.get(line, "visiter", nil),
            "status" => Map.get(line, "status", nil),
            "media" => Map.get(line, "media", nil),
            "org" => Map.get(line, "org", nil),
            "type" => Map.get(line, "type", nil),
            "period" => Map.get(line, "period", nil),
            "visit_ts" => visit_ts,
            "start_date" => start_date,
            "end_date" => end_date,
            "detail" => detail,
            "supervisor" => Map.get(line, "supervisor", nil),
            "advice" => Map.get(line, "advice", nil),
            "sign" => Map.get(line, "sign", nil),
            "sync" => Map.get(line, "sync", nil),
            "flag" => Map.get(line, "flag", nil),
            "lat" => 99999,
            "lon" => 99999
          }

          args =
            Enum.reduce(
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
#          IO.inspect(visit_ts)
          Enum.each(visit_ts, fn item  ->
            args=Map.put(args,"visit_ts",item )
            #              {_, co} =  Connection.insert_visit_wjtz(pid, args)
          end)


        end
      )
    end
  end

  def  testSnowflake do
    Enum.each([
      nodes: ["192.168.0.9", :"tz@192.168.0.9"],
      # up to 1023 nodes
      epoch: 1142974214000,
      machine_id: 2
    ], &Application.put_env(:snowflake, elem(&1, 0), elem(&1, 1)))
    {:ok,id3}=  Snowflake.next_id()
    id3
  end
end
