function recvreq(socket)
  while true
    addr, msg = recvfrom(socket)
    println("RECEIVED")
    readval = ProtoBuf.readproto(IOBuffer(msg), Raft.RaftRPC.RPCRequest())
    return (addr, readval)
  end
end

function send_aereply(socket, ip, port, my_id, aer)
  reply = Raft.RaftRPC.RPCReply(_type=Int32(0),server_id=my_id)
  ib = IOBuffer()
  ProtoBuf.writeproto(ib, aer)
  ProtoBuf.set_field!(reply, :reply, takebuf_array(ib))

  println("\tSending AER reply")
  outb = IOBuffer()
  ProtoBuf.writeproto(outb, reply)
  send(socket, ip, port, takebuf_array(outb))
end

function run_follower(my_config::ServerConfig)
  println("Starting Listener")
  socket = UDPSocket()
  bind(socket, ip"127.0.0.1", my_config.port)
  while true
    addr, rpcreq = recvreq(socket)
    if !ProtoBuf.has_field(rpcreq, :_type) || !ProtoBuf.has_field(rpcreq, :request)
        println("\tDropped")
        continue
    elseif !ProtoBuf.has_field(rpcreq, :server_id)
      println("\tNo return address")
    end

    request_type = ProtoBuf.lookup(Raft.RaftRPC.ExchangeType, ProtoBuf.get_field(rpcreq, :_type))
    sender = my_config.servers[ProtoBuf.get_field(rpcreq, :server_id)]
    assert(sender.ipaddress == addr)
    if request_type == :APPENDENTRIES
      println("\tAER")
      aer = ProtoBuf.readproto(IOBuffer(ProtoBuf.get_field(rpcreq, :request)), Raft.RaftRPC.AppendEntriesRequest())
      send_aereply(socket, sender.ipaddress, sender.port, my_config.id, Raft.RaftRPC.AppendEntriesReply(term=UInt64(1),success=true))
    elseif request_type == :REQUESTVOTE
      rvr = ProtoBuf.readproto(IOBuffer(ProtoBuf.get_field(rpcreq, :request)), Raft.RaftRPC.RequestVoteRequest())
      println("\tRVR ", rvr)
    elseif request_type == :INSTALLSNAPSHOT
      isr = ProtoBuf.readproto(IOBuffer(ProtoBuf.get_field(rpcreq, :request)), Raft.RaftRPC.InstallSnapshotRequest())
      println("\tISR ", isr)
    else
      println("\tUNKNOWN REQUEST TYPE")
    end
  end
end
