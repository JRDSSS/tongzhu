defmodule UserProject do
  @moduledoc false
  def read_json() do

#    {:ok, _neo} = Bolt.Sips.start_link(url: "bolt://neo4j:metadata@47.92.249.35:7687")
    {:ok, _neo} = Bolt.Sips.start_link(url: "bolt://neo4j:tgzzxh255@localhost:7687")
    conn = Bolt.Sips.conn()
    # 假设已经配置好连接到 Neo4j 数据库
    {:ok, json_data} = File.read("D:\\桌面\\neo4j\\user_access_project (2).json")
    json_data = String.replace(json_data, "\uFEFF", "")
    #    IO.inspect(json_data)
    parsed_json = Jason.decode!(json_data)
    #    IO.inspect(parsed_json)
    # 1. 检查Project是否存在
    check_query = "
  MATCH (p:PROJECT {id: $id})
  RETURN p
"

    check_params = %{id: "zgjk"}

    check_result = Bolt.Sips.query(conn, check_query, check_params)
    # 从 check_result 中提取响应 Map
    response_map = elem(check_result, 1)
    # 从响应 Map 中提取记录集
    records = Map.get(response_map, :records, [])
#    IO.inspect(records)
    # 计算记录集的长度
    record_count = length(records)
    if record_count == 0 do
    # 创建共享公司节点
    project = %{
      "address" => "四川省@自贡市@自流井区@汇川路826号",
      "alert_allow_period" => ["09:00:00", "22:00:00"],
      "app_ver_code" => "1.0.0",
      "app_ver_name" => "0.0.1",
      "business_dutyer" => "李轲@18611890835",
      "city_id" => "101140408",
      "endpoint_main_types" => ["air"],
      "ez_app_key" => "91f8e4baa42c40f19e319e76d8580005",
      "ez_app_sec" => "1117d12215187aa6187d6c37d59a6d19",
      "ez_app_token" => "at.2fwmqodjarxocgl545caimm5a20w8anm-5tqkneczq3-1b4lxu3-frkkbp9bg",
      "ez_app_token_expire" => "2023-09-11 07:43:35",
      "id" => "zgjk",
      "jg_activity" => "com.mcarespace.envp.MainActivity",
      "jg_app_key" => "a2c866c51606be1ceafd6f3c",
      "jg_master_sec" => "51c1bff0c2c054aaae3739f3",
      "location" => "zigong",
      "mqtt_host" => "39.100.229.159",
      "mqtt_port" => 1883,
      "name" => "自贡疾控中心",
      "project_dutyer" => "李线毅@13264259590",
      "record_city_weather" => true,
      "topic_reply" => "slab/zigong/zgjk/reply",
      "topic_rtdata" => "slab/zigong/zgjk/rtdata",
      "type" => "slab"
    }

    id = Map.get(project,"id",nil)

    project_query = "
  CREATE (p:PROJECT $project_properties)
  RETURN p
"
    project_params = %{project_properties: project}
#    project_result = Bolt.Sips.query!(conn, project_query, project_params)
    else
      IO.puts("该Project已存在")
    end
#    project_id = Enum.at(project_result.results, 0)["p"].id
#    project_id = Enum.at(project_result.results, 0)["p"].properties
    #    company_data  = Enum.at(company_result.results, 0)
    #    company_name = company_data["name"]
#    IO.inspect(project_id)
    #    IO.inspect(company_name)





    # 循环处理每个用户
    Enum.each(parsed_json, fn item ->
      user_properties = Map.get(item, "user", nil)
      phone = Map.get(user_properties,"phone",nil)
      access = Map.get(item, "access", nil)
      roles = Map.get(access,"roles",nil)

      # 1. 执行检查查询，检查是否已存在具有相同 phone 属性的用户
      check_query = "
  MATCH (u:USER {phone: $phone})
  RETURN u
"

      check_params = %{phone: phone}

      check_result = Bolt.Sips.query(conn, check_query, check_params)

      # 从 check_result 中提取响应 Map
      response_map = elem(check_result, 1)

      # 从响应 Map 中提取记录集
      records = Map.get(response_map, :records, [])

      # 计算记录集的长度
      record_count = length(records)

      if record_count == 0 do
      # 创建用户节点
      user_query = "
    CREATE (u:USER $user_properties)
    RETURN u
  "
      user_params = %{user_properties: user_properties}
      # 执行创建用户节点的查询
      user_result = Bolt.Sips.query!(conn, user_query, user_params)
      else
        IO.puts("#{phone}用户已经存")
end
#      # 获取新创建的用户节点的ID
#      user_id = Enum.at(user_result.results, 0)["u"].id
##      user_name = Enum.at(user_result.results, 0)["u"].name
#      IO.inspect(user_id)
#      IO.inspect(user_name)

      # 创建关系，将用户节点指向项目节点
      create_relationship_query = "
    MATCH (u:USER), (p:PROJECT)
    WHERE u.phone = $user_phone AND p.id = $id
    MERGE (u)-[access:ACCESS]->(p)
    ON CREATE SET access.roles = $roles
  "

      create_relationship_params = %{roles: roles, user_phone: phone ,id: "zgjk"}
#      IO.inspect(create_relationship_query)

      # 执行创建关系的查询
      Bolt.Sips.query!(conn, create_relationship_query, create_relationship_params)


    end)


  end
end
