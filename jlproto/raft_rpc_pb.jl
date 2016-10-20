# syntax: proto3
using Compat
using ProtoBuf
import ProtoBuf.meta
import Base: hash, isequal, ==

type __enum_ExchangeType <: ProtoEnum
    APPENDENTRIES::Int32
    REQUESTVOTE::Int32
    INSTALLSNAPSHOT::Int32
    __enum_ExchangeType() = new(0,1,2)
end #type __enum_ExchangeType
const ExchangeType = __enum_ExchangeType()

type RPCRequest
    _type::Int32
    request::Array{UInt8,1}
    RPCRequest(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type RPCRequest
hash(v::RPCRequest) = ProtoBuf.protohash(v)
isequal(v1::RPCRequest, v2::RPCRequest) = ProtoBuf.protoisequal(v1, v2)
==(v1::RPCRequest, v2::RPCRequest) = ProtoBuf.protoeq(v1, v2)

type RPCReply
    _type::Int32
    reply::Array{UInt8,1}
    RPCReply(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type RPCReply
hash(v::RPCReply) = ProtoBuf.protohash(v)
isequal(v1::RPCReply, v2::RPCReply) = ProtoBuf.protoisequal(v1, v2)
==(v1::RPCReply, v2::RPCReply) = ProtoBuf.protoeq(v1, v2)

type LogEntry
    index::UInt64
    term::UInt64
    key::AbstractString
    value::Array{UInt8,1}
    LogEntry(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type LogEntry
hash(v::LogEntry) = ProtoBuf.protohash(v)
isequal(v1::LogEntry, v2::LogEntry) = ProtoBuf.protoisequal(v1, v2)
==(v1::LogEntry, v2::LogEntry) = ProtoBuf.protoeq(v1, v2)

type AppendEntriesRequest
    term::UInt64
    leaderId::UInt64
    prevLogIndex::UInt64
    prevLogTerm::UInt64
    entry::Array{LogEntry,1}
    leaderCommit::UInt64
    AppendEntriesRequest(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type AppendEntriesRequest
hash(v::AppendEntriesRequest) = ProtoBuf.protohash(v)
isequal(v1::AppendEntriesRequest, v2::AppendEntriesRequest) = ProtoBuf.protoisequal(v1, v2)
==(v1::AppendEntriesRequest, v2::AppendEntriesRequest) = ProtoBuf.protoeq(v1, v2)

type AppendEntriesReply
    term::UInt64
    success::Bool
    AppendEntriesReply(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type AppendEntriesReply
hash(v::AppendEntriesReply) = ProtoBuf.protohash(v)
isequal(v1::AppendEntriesReply, v2::AppendEntriesReply) = ProtoBuf.protoisequal(v1, v2)
==(v1::AppendEntriesReply, v2::AppendEntriesReply) = ProtoBuf.protoeq(v1, v2)

type RequestVoteRequest
    term::UInt64
    candidateId::UInt64
    lastLogIndex::UInt64
    lastLogTerm::UInt64
    RequestVoteRequest(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type RequestVoteRequest
hash(v::RequestVoteRequest) = ProtoBuf.protohash(v)
isequal(v1::RequestVoteRequest, v2::RequestVoteRequest) = ProtoBuf.protoisequal(v1, v2)
==(v1::RequestVoteRequest, v2::RequestVoteRequest) = ProtoBuf.protoeq(v1, v2)

type RequestVoteReply
    term::UInt64
    voteGranted::Bool
    RequestVoteReply(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type RequestVoteReply
hash(v::RequestVoteReply) = ProtoBuf.protohash(v)
isequal(v1::RequestVoteReply, v2::RequestVoteReply) = ProtoBuf.protoisequal(v1, v2)
==(v1::RequestVoteReply, v2::RequestVoteReply) = ProtoBuf.protoeq(v1, v2)

type InstallSnapshotRequest
    term::UInt64
    leaderId::UInt64
    lastIncludedIndex::UInt64
    lastIncludedTerm::UInt64
    offset::UInt64
    data::Array{UInt8,1}
    done::Bool
    InstallSnapshotRequest(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type InstallSnapshotRequest
hash(v::InstallSnapshotRequest) = ProtoBuf.protohash(v)
isequal(v1::InstallSnapshotRequest, v2::InstallSnapshotRequest) = ProtoBuf.protoisequal(v1, v2)
==(v1::InstallSnapshotRequest, v2::InstallSnapshotRequest) = ProtoBuf.protoeq(v1, v2)

type InstallSnapshotReply
    term::UInt64
    InstallSnapshotReply(; kwargs...) = (o=new(); fillunset(o); isempty(kwargs) || ProtoBuf._protobuild(o, kwargs); o)
end #type InstallSnapshotReply
hash(v::InstallSnapshotReply) = ProtoBuf.protohash(v)
isequal(v1::InstallSnapshotReply, v2::InstallSnapshotReply) = ProtoBuf.protoisequal(v1, v2)
==(v1::InstallSnapshotReply, v2::InstallSnapshotReply) = ProtoBuf.protoeq(v1, v2)

export ExchangeType, RPCRequest, RPCReply, LogEntry, AppendEntriesRequest, AppendEntriesReply, RequestVoteRequest, RequestVoteReply, InstallSnapshotRequest, InstallSnapshotReply
