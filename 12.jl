using BenchmarkTools

struct tree
    length::Int
    width::Int
    area::Int
    gifts::Vector{Int}
end

struct shape
    mask::BitArray
    occupied::Int
    id::Int
end

function parse_input(input::Vector{String})
    function parse_shape(lines::Vector{String}, id::Int)
        mask = stack(collect.(lines), dims=1) .== '#'
        return shape(mask, sum(mask), id)
    end
    function parse_tree(line)
        gifts = split(line, ": ")[2] |> split |> x -> parse.(Int, x)
        width, length = split(line, "x")[1] |> x -> parse(Int, x), split(split(line, "x")[2], ":")[1] |> x -> parse(Int, x)
        area = width * length
        tree(length, width, area, gifts)
    end
    shapes = [parse_shape(input[ii*5+2:ii*5+4], ii) for ii in 0:5]
    trees = parse_tree.(input[31:end])

    return shapes, trees
end

function solve_naive(tree, shapes)
    min_area_needed = tree.gifts' * [s.occupied for s in shapes] # a'b == a'*b == a ⋅ b == dot(a, b)
    return min_area_needed < tree.area
end

function main()
    shapes, trees = parse_input(input)
    return sum([solve_naive(t, shapes) for t in trees])
end






input = readlines(".data/12.txt")
@benchmark main()

