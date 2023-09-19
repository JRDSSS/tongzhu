defmodule ExcelToJson do
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
    {:ok, labeldata} = File.read("D:\\java\\html\\Project\\JsonData\\wjtz.json")
    labeldata = Jason.decode!(labeldata)
    labelkey1 = Map.keys(labeldata)
    labelvalues = Map.values(labeldata)
    labelvalues = Enum.reduce(labelvalues, %{}, fn map, acc -> Map.merge(acc, map) end)
    labelkey2 = Enum.map(labelvalues, fn {key, value} -> key end)

    IO.inspect(labelkey2)

    # 循环 7 次
    #    for count <- 6..7 do
    # 输出当前循环的次数
    #      IO.puts("当前循环的次数：#{count}")

    {:ok, content} = Xlsxir.extract("D:\\java\\工作文件夹\\新建文件夹\\巡访\\#{filename}.xlsx", 7)

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
            end_date = Xlsxir.get_cell(content, Excel.convert_col("I", line))
            visit_ts = Xlsxir.get_cell(content, Excel.convert_col("J", line))
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
              "start_date" => start_date,
              "end_date" => end_date,
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

    file_name2 = "D:\\java\\工作文件夹\\新建文件夹\\巡访\\#{filename}7.json"
    File.write(file_name2, json_data)
  end

end
