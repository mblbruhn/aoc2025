using PaddedViews
using BenchmarkTools

function string_to_matrix(input::Vector{String})
    a = reduce(hcat, split.(input, ""))
    d = Dict("." => 0, "@" => 1)
    out::Array{Int8} = collect(map(x -> d[x], a)')
    return out
end

function neighbor_map(in_map::Array{Int8})
    rows, cols = in_map.size
    out::Array{Int8} = zeros(Int8, (rows, cols))
    pad_val::Int8 = 0
    padded = PaddedView(pad_val, in_map, (0:rows+1, 0:cols+1))
    for ii = 1:rows
        for jj = 1:cols
            out[ii, jj] = sum(padded[ii-1:ii+1, jj-1:jj+1])
        end
    end
    out = in_map .* out
    return out
end


function part1(input)
    numerical_input = string_to_matrix(input)
    nm = neighbor_map(numerical_input)
    thresh_lo::Int8 = 0
    thresh_hi::Int8 = 5
    movable = sum(thresh_lo .< nm .< thresh_hi)
    return movable
end

function neighbors(coord::Tuple{UInt8, UInt8})::Vector{Tuple{UInt8, UInt8}}
    return [(coord[1] + ii, coord[2] + jj) for ii = -1:1:1 for jj = -1:1:1]
end

function part2(input)
    function remove_rolls!(coord::Tuple{UInt8, UInt8})
        """Removes a coordinate (containing a roll) if it has up to 4 neighbors"""
        possible_neighbors = neighbors(coord)
        n_neighbors::UInt8 = 0
        for neighbor_coord in possible_neighbors
            if neighbor_coord in coords
                n_neighbors += 1
            end
        end
        if n_neighbors < 5
            pop!(temp, coord)
        end
    end

    # create set of coordinates with paper rolls 
    coords::Set{Tuple{UInt8,UInt8}} = Set()
    mat = reduce(hcat, split.(input, ""))
    for ii = 1:mat.size[1]
        for jj = 1:mat.size[2]
            if mat[ii, jj] == "@"
                push!(coords, (ii, jj))
            end
        end
    end

    # Iteratively remove rolls until the coordinate set does not change anymore
    removed = 0
    temp = copy(coords)
    remove_rolls!.(coords)
    removed += length(coords) - length(temp)
    while coords != temp
        coords = copy(temp)
        temp = copy(coords)
        remove_rolls!.(coords)
        removed += length(coords) - length(temp)
    end
    return removed
end

input = readlines(".data/04.txt")
println("Part 1: $(part1(input)); Part 2: $(part2(input))")
@benchmark (part1(input), part2(input))

