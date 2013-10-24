
module ('gamenet', package.seeall) do

  known_nodes = {}

  function add_node(node)
    known_nodes[node.uuid] = node
  end
end