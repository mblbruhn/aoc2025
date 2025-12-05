using BenchmarkTools

function parse_input(input::Vector{String})::Tuple{Vector{Vector{Int}},Vector{Int}}
    split_idx::Int = findall(x -> x == "", input)[1]
    ranges_out::Vector{Vector{Int}} = (input[1:split_idx-1] |>
                                       ranges -> split.(ranges, "-") |>
                                                 r -> map(x -> parse.(Int, x), r)
    )
    ids_out::Vector{Int} = (input[split_idx+1:end] |>
                            ids -> parse.(Int, ids)
    )
    return ranges_out, ids_out
end

function part1(input)
    ranges, ids = parse_input(input)
    n_fresh = 0
    for id in ids
        for (lo, hi) in ranges
            if lo <= id <= hi
                n_fresh += 1
                break
            end
        end
    end
    return n_fresh
end

function part2(input)
    ranges, _ = parse_input(input)
    sort!(ranges, by=x -> x[1])
    covering = 0
    curr_max = 0
    for (lo, hi) in ranges
        lo = lo > curr_max ? lo : curr_max
        if hi >= lo
            covering += hi - lo + 1
            curr_max = hi + 1
        end
    end
    return covering
end

function part12(input)
    ranges, ids = parse_input(input)
    n_fresh = 0
    for id in ids
        for (lo, hi) in ranges
            if lo <= id <= hi
                n_fresh += 1
                break
            end
        end
    end
    
    sort!(ranges, by=x -> x[1])
    covering = 0
    curr_max = 0
    for (lo, hi) in ranges
        lo = lo > curr_max ? lo : curr_max
        if hi >= lo
            covering += hi - lo + 1
            curr_max = hi + 1
        end
    end
    return n_fresh, covering
end

input = readlines(".data/05.txt")
p1, p2 = part12(input)
println("Part 1: $p1; Part 2: $p2")
@benchmark (part12(input))