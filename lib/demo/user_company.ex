defmodule UserCompany do
  @moduledoc false
  def read_json() do
#    {:ok, _neo} = Bolt.Sips.start_link(url: "bolt://neo4j:metadata@47.92.249.35:7687")
    {:ok, _neo} = Bolt.Sips.start_link(url: "bolt://neo4j:tgzzxh255@localhost:7687")
    conn = Bolt.Sips.conn()
    # 假设已经配置好连接到 Neo4j 数据库
    {:ok, json_data} = File.read("D:\\桌面\\neo4j\\user_work_company.json")
    json_data = String.replace(json_data, "\uFEFF", "")
#    IO.inspect(json_data)
    parsed_json = Jason.decode!(json_data)
#    IO.inspect(parsed_json)

    # 1. 检查Company是否存在
    check_query = "
  MATCH (c:COMPANY {name: $name})
  RETURN c
"

    check_params = %{name: "自贡疾控中心二楼"}

    check_result = Bolt.Sips.query(conn, check_query, check_params)
    # 从 check_result 中提取响应 Map
    response_map = elem(check_result, 1)
    # 从响应 Map 中提取记录集
    records = Map.get(response_map, :records, [])
    # 计算记录集的长度
    record_count = length(records)
    if record_count == 0 do
    # 创建共享公司节点
    company = %{
      "name" => "自贡疾控中心二楼"
    }

    company_query = "
  CREATE (c:COMPANY $company_properties)
  RETURN c
"
    company_params = %{company_properties: company}
#    company_result = Bolt.Sips.query!(conn, company_query, company_params)
    else
      IO.puts("该Company已存在")
    end
#    company_id = Enum.at(company_result.results, 0)["c"].id
#    company_data  = Enum.at(company_result.results, 0)
#    company_name = company_data["name"]
#    IO.inspect(company_id)
#    IO.inspect(company_name)





    # 循环处理每个用户
    Enum.each(parsed_json, fn item ->
      user_properties = Map.get(item, "user", nil)
      phone = Map.get(user_properties,"phone",nil)
      work = Map.get(item, "work", nil)
      roles = Map.get(work,"roles",nil)
#      IO.inspect(roles)


      # 1. 执行检查查询，检查是否已存在具有相同 phone 属性的用户
      check_query = "
      MATCH (u:USER {phone: $phone})
      RETURN u
    "

      check_params = %{phone: phone}

      check_result = Bolt.Sips.query(conn, check_query, check_params)
#      IO.inspect(check_result)

      # 从 check_result 中提取响应 Map
      response_map = elem(check_result, 1)
#      IO.inspect(response_map)

      # 从响应 Map 中提取记录集
      records = Map.get(response_map, :records, [])
#      IO.inspect(records)

      # 计算记录集的长度
      record_count = length(records)
#      IO.inspect(record_count)

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
#      IO.inspect(user_id)

      # 创建关系，将用户节点指向公司节点
      create_relationship_query = "
    MATCH (u:USER), (c:COMPANY)
    WHERE u.phone = $user_phone AND c.name = '自贡疾控中心二楼'
    MERGE (u)-[work:WORK]->(c)
    ON CREATE SET work.roles = $roles
  "

      create_relationship_params = %{roles: roles,user_phone: phone}
#      IO.inspect(create_relationship_query)

      # 执行创建关系的查询
      Bolt.Sips.query!(conn, create_relationship_query, create_relationship_params)


    end)


  end
end
