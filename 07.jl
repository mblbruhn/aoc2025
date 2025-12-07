using BenchmarkTools

struct BeamEnd
    x::Int64
    y::Int64
end


function track_beam_path(beam_pos::BeamEnd)
    return get!(cache, beam_pos) do
        if beam_pos.y == bottom
            return 1
        end
        should_split = hit_splitter(beam_pos)
        while ~should_split
            beam_pos = move_down(beam_pos)
            if beam_pos.y == bottom 
                return 1
            end
            should_split = hit_splitter(beam_pos)
        end
        left, right = split(beam_pos)
        left_timelines = track_beam_path(left)
        right_timelines = track_beam_path(right)
        return left_timelines + right_timelines
    end
end

@inline function move_down(a::BeamEnd)
    return BeamEnd(a.x, a.y+1)
end

@inline function Base.split(a::BeamEnd)
    left = BeamEnd(a.x-1, a.y)
    right = BeamEnd(a.x+1, a.y)
    return left, right
end

@inline function hit_splitter(a::BeamEnd)
    if splitter_map[a.y, a.x]
        split_pos[a.y, a.x] = true
        return true
    end
    return false
end

function main(input)
    global splitter_map = split.(input, "") |> stack |> permutedims |> x-> x .== "^"
    global bottom = length(input)
    global split_pos = falses(size(splitter_map))
    global cache = Dict{BeamEnd, Int}()
    beam_entry = findfirst("S", input[1])
    timelines = track_beam_path(BeamEnd(beam_entry[1], 1))
    return sum(split_pos), timelines
end


input = readlines(".data/07.txt")
@benchmark main(input)