
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
  if not msg then
    return function (msg)
      return send(receiver_id, msg)
    end
  end
  if type(msg) == 'table' then
    return receivers[receiver_id] (unpack(msg))
  else
    return receivers[receiver_id] (msg)
  end
end

