using ArgParse

include("./src/raft.jl")
using Raft

## I'm just a follower to start with
ps = Raft.PersistentState(0, 0, [])
vs = Raft.VolatileState(0, 0)

s = ArgParseSettings("Runs a Raft server")
@add_arg_table s begin
  "--server_id", "-s"
      help = "id of this server"
      arg_type = UInt64
      required = true
  "--port", "-p"
      help = "port to listen on"
      required = true
      arg_type = UInt64
  "--buddy", "-b"
      help = "TEMP - port of buddy to talk to"
      required = true
      arg_type = UInt64
  "--amleader", "-l"
      action = :store_true
      help = "This server should be the leader"
end

## Read config:
parsed_args = parse_args(ARGS, s)
for key in parsed_args
  @show key
end
my_config = Raft.ServerConfig(parsed_args["server_id"],
  parsed_args["port"], Dict(2 => Raft.Address("localhost", parsed_args["buddy"])))
am_leader = parsed_args["amleader"]

## Wait for leader to contact me
if !am_leader
  println("Starting Listener")
  begin
    server = listen(my_config.port)
    while true
      sock = accept(server)
      println("RECEIVED")
      readval = ProtoBuf.readproto(sock, Raft.RaftRPC.RPCRequest())
      println("\treadval ", readval)

      if !ProtoBuf.has_field(readval, :_type) || !ProtoBuf.has_field(readval, :request)
        # drop
        println("\tDropped")
        continue
      end

      request_type = ProtoBuf.lookup(Raft.RaftRPC.ExchangeType, ProtoBuf.get_field(readval, :_type))
      println("\trequest_type: ", request_type)
      if request_type == :APPENDENTRIES
        # append entry to log
        aer = ProtoBuf.readproto(IOBuffer(ProtoBuf.get_field(readval, :request)), Raft.RaftRPC.AppendEntriesRequest())
        println("\tAER ", aer)

        reply = Rake.RakeRPC.RPCReply()
        ProtoBuf.set_field!(reply, :_type, 0)
        ib = IOBuffer()
        ProtoBuf.writeproto(ib, Raft.RaftRPC.AppendEntriesRequest(Uint64(1),true))
        ProtoBuf.set_field!(reply, :reply, ib)

        println("\tSending AER reply")
        ProtoBuf.writeproto(sock, reply)

      elseif request_type == :REQUESTVOTE
        # vote for them
        rvr = ProtoBuf.readproto(IOBuffer(ProtoBuf.get_field(readval, :request)), Raft.RaftRPC.RequestVoteRequest())
        println("\tRVR ", rvr)

      elseif request_type == :INSTALLSNAPSHOT
        # catch up
        isr = ProtoBuf.readproto(IOBuffer(ProtoBuf.get_field(readval, :request)), Raft.RaftRPC.InstallSnapshotRequest())
        println("\tISR ", isr)
      end

      println("FINISHED RECEIVING")
    end
  end
  println("Done Listening")
else

  out = connect(my_config.servers[2].port)

  aer = Raft.RaftRPC.AppendEntriesRequest(
      term = 1,
      leaderId = 2,
      prevLogIndex = 0,
      prevLogTerm = 0,
      leaderCommit = 0
  )
  request = Raft.RaftRPC.RPCRequest()
  ProtoBuf.set_field!(request, :_type, Int32(0)) # how to better deal with enums?
  ib = IOBuffer()
  ProtoBuf.writeproto(ib, aer)
  ProtoBuf.set_field!(request, :request, takebuf_array(ib))

  ProtoBuf.writeproto(out, request)
  println("SENT")

  readval = ProtoBuf.readproto(out, Raft.RaftRPC.RPCReply())
  println(ProtoBuf.enumstr("ExchangeType", get_field(readval, :_type)))
  println("DONE")
end
