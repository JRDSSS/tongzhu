defmodule MyNeo4jDemo do
  @moduledoc false

  def read_json() do
    {:ok, _neo} = Bolt.Sips.start_link(url: "bolt://neo4j:tgzzxh255@localhost:7687")
    conn = Bolt.Sips.conn()
  # 假设已经配置好连接到 Neo4j 数据库
  {:ok, json_data} = File.read("D:\\桌面\\布局.json")
  parsed_json = Jason.decode!(json_data)
  # 遍历 JSON 数据并创建节点
    Enum.each(parsed_json, fn item ->
      project = Map.get(item,"project",nil)
      IO.inspect(project)
      area = Map.get(item,"a",nil)
      area_properties = Map.get(area,"properties",nil)
      endpoints = Map.get(item,"end_points",nil)

      # 创建项目节点并与区域节点同时创建关系
      create_query = "
      CREATE (a:END_POINT:SLAB_AREA $area_properties)-[:BELONG]->(p:PROJECT $project_properties)
      RETURN p, a
      "
      params = %{project_properties: project, area_properties: area_properties}
      Bolt.Sips.query!(conn, create_query, params)


      Enum.each(endpoints, fn endpoint ->
        data = Map.get(endpoint,"data",nil)
#        IO.inspect(data_properties)

        room = Map.get(endpoint,"room",nil)
        room_properties = Map.get(room,"properties",nil)


        device = Map.get(endpoint,"device",nil)

        relation = Map.get(endpoint,"relaion",nil)
        startNode = Map.get(relation,"start",nil)
        endNode = Map.get(relation,"end",nil)
        type = Map.get(relation,"type",nil)

        # 创建一个以标签为节点标签的Cypher查询字符串
        labels_room = Map.get(room,"labels",nil)
        label_room = labels_room
                       |> Enum.map(fn label -> ":#{label}" end)
                       |> Enum.join("")





        Enum.each(data, fn item ->
          data_properties = Map.get(item,"properties",nil)
          labels_data = Map.get(item,"labels",nil)
          label_data = labels_data
                       |> Enum.map(fn label -> ":#{label}" end)
                       |> Enum.join("")
          room_data_query =
            if data_properties != nil do
              """
              CREATE (a<-r#{label_room} $room_properties)-[:#{type}]->(d#{label_data} $data_properties)
              RETURN r,d
              """
            else
              """
              CREATE (r#{label_room} $room_properties)
              RETURN r
              """
            end
          # 构建参数映射
          params = %{
            "room_properties" => room_properties,
            "data_properties"=>data_properties
          }
          Bolt.Sips.query!(conn, room_data_query, params)

        end)


      end)




  end)

end
end



