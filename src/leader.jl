function send_aereq(socket, ip, port, my_id, aer::Raft.RaftRPC.AppendEntriesRequest)
  request = Raft.RaftRPC.RPCRequest(server_id=my_id, _type=Int32(0))

  # write the bytes of aer to a buffer, than put that array into the request
  ib = IOBuffer()
  ProtoBuf.writeproto(ib, aer)
  ProtoBuf.set_field!(request, :request, takebuf_array(ib))

  # write the bytes of the request to a buffer
  outb = IOBuffer()
  ProtoBuf.writeproto(outb, request)

  # send these bytes as a UDP message
  send(socket, ip, port, takebuf_array(outb))
end

function recv_aereply(socket)
  msg = recv(socket)
  readval = ProtoBuf.readproto(IOBuffer(msg), Raft.RaftRPC.RPCReply())
  msg_type = ProtoBuf.get_field(readval, :_type)
  if msg_type == Int32(0)
    if !ProtoBuf.has_field(readval, :reply)
      error("Doesn't have reply??")
    end
    ib = IOBuffer(ProtoBuf.get_field(readval, :reply))
    aer = Raft.RaftRPC.AppendEntriesReply()
    ProtoBuf.readproto(ib, aer)
    return aer
  else
    error("received incorrect reply")
  end
end

function run_leader(my_config::ServerConfig)
  socket = UDPSocket()
  bind(socket, ip"127.0.0.1", my_config.port)

  aer = Raft.RaftRPC.AppendEntriesRequest(
      term = 1,
      leaderId = 2,
      prevLogIndex = 0,
      prevLogTerm = 0,
      leaderCommit = 0
  )
  println("Sending AERequest")
  for (k,v) in my_config.servers
    send_aereq(socket, v.ipaddress, v.port, my_config.id, aer)
  end
  println("Awaiting Response")
  reply = recv_aereply(socket)
  println("SUCCESS")
end
