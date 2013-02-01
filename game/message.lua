
module ('message', package.seeall)

local receivers = {}

function add_receiver (id, handler)
  receivers[id] = handler
end

function remove_receiver (id)
  receivers[id] = nil
end

function send (receiver_id, msg)
  if not receivers[receiver_id] then return end
  receivers[receiver_id] (msg)
end

