module Raft
using ProtoBuf

include("./common_types.jl")

include("./leader.jl")
include("./candidate.jl")
include("./follower.jl")

end
