include("../jlproto/RaftRPC.jl")

###
# Types for state stored on servers
###

# Lots of different indexes in this format
typealias CandidateId UInt64
typealias LogIndex UInt64
typealias Term UInt64
typealias Server UInt64 # not sure what to do with this?

# Remember to save to disk before responding to RPCs
type PersistentState
  currentTerm::Term
  votedFor::CandidateId
  log::Array{Tuple{Term, RaftRPC.LogEntry}}
end

type VolatileState
  commitIndex::LogIndex
  lastApplied::LogIndex
end

type LeaderVolatileState
  nextIndex::Dict{Server, LogIndex}
  matchIndex::Dict{Server, LogIndex}
end

# Configuration
type Address
  ipaddress::String
  port::UInt
end

type ServerConfig
  id::Server # my id
  port::UInt # port to listen on
  servers::Dict{Server, Address}
end
