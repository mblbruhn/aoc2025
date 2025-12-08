using BenchmarkTools
using DataStructures


struct Coord3D
    x::Int
    y::Int
    z::Int
end

function r(p1::Coord3D, p2::Coord3D)::Int
    return (p1.x - p2.x)^2 + (p1.y - p2.y)^2 + (p1.z - p2.z)^2
end

function main(input::Vector{String})::Tuple{Int,Int}
    coords::Vector{Coord3D} = input .|> (
        line -> line |>
                x -> split(x, ",") |>
                     x -> parse.(Int, x) |>
                          x -> Coord3D(x...)
    )
    max_idx = length(input)
    distances = Vector{Pair{Tuple{Coord3D, Coord3D},Int}}(undef, max_idx*(max_idx-1)÷2) # pre-allocating for speed based on gauss summation formula
    lin_idx = 1
    for ii in 1:max_idx
        for jj = ii+1:max_idx
            distances[lin_idx] = (coords[ii], coords[jj]) => r(coords[ii], coords[jj])
            lin_idx +=1
        end
    end
    sort!(distances, by=x -> x[2]; alg=QuickSort) # quicksort is unstable (doesn't matter) and a bit faster

    part1 = 0
    circuits = DisjointSet{Coord3D}(coords)
    for ii in eachindex(distances)
        ((p1, p2), _) = distances[ii]
        if !in_same_set(circuits, p1, p2)
            union!(circuits, p1, p2)
        end
        if ii == n 
            # no native `number_of_elems_per_group` function is provided by DataStructures.jl
            # this implementation counts (for each root, ie the bucket), how many coords are in the bucket
            # using a DisjointSet is 10 ms faster than my own implementation of Vector{Set{Coord3D}}: 65 ms -> 54 ms
            # previous implementation can be found in earlier commit 
            counts = Dict{Coord3D, Int}((cc, 0) for cc in coords)
            for cc in coords # iterate over the Coord3D structs
                r = find_root!(circuits, cc) # this returns the root of the group of the coord
                # for this root, increase the count by one
                counts[r] = get(counts, r, 0) + 1
            end
            part1 = reduce(*, sort(collect(values(counts)), rev=true)[1:3])
        end
        if num_groups(circuits) == 1
            part2 = p1.x*p2.x
            return part1, part2
        end
    end
end


fname = ".data/08.txt"
input = readlines(fname)
const n = occursin("test", fname) ? 10 : 1000
@benchmark main(input)
