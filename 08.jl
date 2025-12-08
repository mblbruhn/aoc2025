using BenchmarkTools
struct Coord3D
    z::Int
    y::Int
    x::Int
end

function r(p1::Coord3D, p2::Coord3D)::Float64
    return sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2 + (p1.z - p2.z)^2)
end

function which_circuits_do_these_points_belong_to(circuits, p1, p2)
    idx_p1 = 0
    idx_p2 = 0
    for ii in eachindex(circuits)
        if p1 in circuits[ii]
            idx_p1 = ii
        end
        if p2 in circuits[ii]
            idx_p2 = ii
        end
    end
    return idx_p1, idx_p2
end

function main(input)
    coords = input .|> (
                 line -> line |>
                         x -> split(x, ",") |>
                              x -> parse.(Int, x) |>
                                   x -> Coord3D(x...)
             )
    distances = Vector{Pair{Tuple{Coord3D, Coord3D}, Float64}}()
    max_idx = length(input)
    for ii in 1:max_idx
        for jj = ii+1:max_idx
            push!(distances, (coords[ii], coords[jj]) => r(coords[ii], coords[jj]))
        end
    end
    sort!(distances, by=x->x[2])
    
    part1 = 0
    circuits = Vector{Set}([Set([c]) for c in coords])
    for ii in eachindex(distances)
        ((p1, p2), _) = distances[ii]
        cidx_p1, cidx_p2 = which_circuits_do_these_points_belong_to(circuits, p1, p2)
        if cidx_p1 != cidx_p2
            union!(circuits[cidx_p1], circuits[cidx_p2])
            deleteat!(circuits, cidx_p2)
        end
        if ii == n 
            part1 = reduce(*, sort(length.(circuits), rev=true)[1:3])
        end
        if length(circuits) == 1
            part2 = p1.z*p2.z
            return part1, part2
        end
    end
end



fname = ".data/08.txt"
input = readlines(fname)
const n = occursin("test", fname) ? 10 : 1000
@benchmark main(input)
