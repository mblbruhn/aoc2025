using BenchmarkTools


function track_beam_path(beam_pos::Tuple{Int, Int})
    return get!(cache, beam_pos) do
        if beam_pos[2] == bottom
            return 1
        end
        should_split = hit_splitter(beam_pos)
        while ~should_split
            beam_pos = move_down(beam_pos)
            if beam_pos[2] == bottom 
                return 1
            end
            should_split = hit_splitter(beam_pos)
        end
        left, right = split_beam(beam_pos)
        left_timelines = track_beam_path(left)
        right_timelines = track_beam_path(right)
        return left_timelines + right_timelines
    end
end

function move_down(a::Tuple{Int, Int})
    return (a[1], a[2]+1)
end

function split_beam(a::Tuple{Int, Int})
    left = (a[1]-1, a[2])
    right = (a[1]+1, a[2])
    return left, right
end

function hit_splitter(a::Tuple{Int, Int})
    if splitter_map[a[2], a[1]]
        split_pos[a[2], a[1]] = true
        return true
    end
    return false
end

function main(input)
    global splitter_map = split.(input, "") |> stack |> permutedims |> x-> x .== "^"
    global bottom = length(input)
    global split_pos = falses(size(splitter_map))
    global cache = Dict{Tuple{Int, Int}, Int}()
    beam_entry = findfirst("S", input[1])
    timelines = track_beam_path((beam_entry[1], 1))
    return sum(split_pos), timelines
end


input = readlines(".data/07.txt")
@benchmark main(input)