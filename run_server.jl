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
  "--buddies", "-b"
      nargs = '+'
      help = "ports of buddies to talk to"
      arg_type = UInt64
      required = true
  "--amleader", "-l"
      action = :store_true
      help = "This server should be the leader"
end

## Read config:
parsed_args = parse_args(ARGS, s)
for key in parsed_args
  @show key
end

buddies = Dict{Raft.Server, Raft.Address}()
i = UInt64(1)
for b in parsed_args["buddies"]
  buddies[i] = Raft.Address(ip"127.0.0.1", b)
  i+=1
end

my_config = Raft.ServerConfig(parsed_args["server_id"],
  parsed_args["port"], buddies)
am_leader = parsed_args["amleader"]

## Wait for leader to contact me
if !am_leader
  Raft.run_follower(my_config)
else
  Raft.run_leader(my_config)
end
