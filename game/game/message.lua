
module ('message', package.seeall)

local receivers = {}

function add_receiver (id, handler)
  if type(handler) == 'table' then
    receivers[id] = function (cmd, ...)
      if not handler[cmd] then
        error("Unknown command: " .. cmd)
      end
      return handler[cmd](...)
    end
  else
    receivers[id] = handler
  end
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

