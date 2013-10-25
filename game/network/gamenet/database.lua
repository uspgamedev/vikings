
module ('gamenet', package.seeall) do

  known_nodes = {}

  function add_node(node_or_uuid, ip, port)
    local node
    if type(node_or_uuid) ~= 'table' then
      node = {
        uuid = node_or_uuid,
        ip = ip,
        port = port,
      }
    else
      node = node_or_uuid
    end
    assert(node.uuid, "add_node must receive at least an uuid")
    known_nodes[node.uuid] = node
  end
end