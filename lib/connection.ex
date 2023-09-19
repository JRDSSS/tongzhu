defmodule Connection do
  @moduledoc false
  def getc(pid, id_card) do
    query = "SELECT label,id,name FROM dbxqtz.people WHERE id_card = $1"
    values = [id_card]
    {:ok, result} = Postgrex.query(pid, query, values)

    if result.rows != [] do
      [head | tail] = result.rows
      data = head
      label = Enum.at(data, 0)
      id = Enum.at(data, 1)
      name = Enum.at(data, 2)

      result_map = %{
        label: label,
        id: id,
        name: name
      }

      result_map
    else
      %{}
    end
  end

  def update(pid, map) do
    #    da= Map.get(map1,"birthday",nil)
    #    map= if da != nil do
    #      {_,date}=  Date.from_iso8601(da)
    #      %{map1|"birthday" =>date }
    #      else
    #        map1
    #    end
    stt = map_to_key_value(map)
    idt = Map.get(map, "id")
    keyNum = Map.size(map)
    update_query = "UPDATE dbxqtz.people SET " <> stt <> " WHERE id = $#{keyNum}"
    IO.inspect(update_query)
    id_value = Map.get(map, "id", nil)
    map_without_id = Map.delete(map, "id")
    values_except_id = Map.values(map_without_id)
    update_data = values_except_id ++ [id_value]
    Postgrex.query(pid, update_query, update_data)
  end

  def insert(pid, map) do
    #    da= Map.get(map1,"birthday",nil)
    #    map= if da != nil do
    #      {_,date}=  Date.from_iso8601(da)
    #      %{map1|"birthday" =>date }
    #    else
    #      map1
    #    end
    IO.puts("进入插入")

    IO.inspect(map)
    keys = Map.keys(map)

    values_str =
      Enum.with_index(map, 1)
      |> Enum.reduce("", fn {{key, value}, i}, acc ->
        value_pair = "$#{i},"

        if String.length(acc) == 0 do
          value_pair
        else
          "#{acc}#{value_pair}"
        end
      end)

    values_str = String.replace_suffix(values_str, ",", "")
    keys_str = Enum.join(keys, ", ")
    insert_query = "INSERT INTO dbxqtz.people (#{keys_str}) VALUES (#{values_str})"
    insert_values = Map.values(map)
    Postgrex.query(pid, insert_query, insert_values)

    #    IO.puts("插入成功")
  end

  def map_to_key_value(map1) do
    map = Map.delete(map1, "id")

    ss =
      Enum.with_index(map, 1)
      |> Enum.reduce("", fn {{key, value}, i}, acc ->
        key_value_pair = "#{key}=$#{i},"

        if String.length(acc) == 0 do
          key_value_pair
        else
          "#{acc}#{key_value_pair}"
        end
      end)

    String.replace_suffix(ss, ",", "")
  end

  def inser_wjtz(pid, map, org_id) do
    keys = Map.keys(map)

    values_str =
      Enum.with_index(map, 1)
      |> Enum.reduce("", fn {{key, value}, i}, acc ->
        value_pair = "$#{i},"

        if String.length(acc) == 0 do
          value_pair
        else
          "#{acc}#{value_pair}"
        end
      end)

    values_str = String.replace_suffix(values_str, ",", "")
    keys_str = Enum.join(keys, ", ")
    insert_query = "INSERT INTO #{org_id}.visit (#{keys_str}) VALUES (#{values_str})"
    insert_values = Map.values(map)
    {_, co} = Postgrex.query(pid, insert_query, insert_values)

    IO.puts(co)
  end

  def insert_visit_wjtz(pid, map) do
    keys = Map.keys(map)

    values_str =
      Enum.with_index(map, 1)
      |> Enum.reduce("", fn {{key, value}, i}, acc ->
        value_pair = "$#{i},"

        if String.length(acc) == 0 do
          value_pair
        else
          "#{acc}#{value_pair}"
        end
      end)

    values_str = String.replace_suffix(values_str, ",", "")
    keys_str = Enum.join(keys, ", ")
    insert_query = "INSERT INTO wjtz.visit (#{keys_str}) VALUES (#{values_str})"
    insert_values = Map.values(map)
    {_, co} = Postgrex.query(pid, insert_query, insert_values)
    IO.puts(co)
  end
end

# spring.datasource.driver-class-name=org.postgresql.Driver
# spring.datasource.url=jdbc:postgresql://192.168.31.193:6432/test
# spring.datasource.username=postgres
# spring.datasource.password=logdata
# Connection.getc "511027194605178274"

