using PaddedViews
using BenchmarkTools


function solve(input)
    mat = reduce(hcat, split.(input, ""))
    d = Dict("." => false, "@" => true)
    mat_b::Array{Bool} = collect(map(x -> d[x], mat)')
    mat_b_padded = PaddedView(false, mat_b, (0:mat.size[1]+1, 0:mat.size[2]+1))
    start = sum(mat_b)
    total = 0
    last_removal = 1
    while last_removal > 0
        for row in axes(mat_b, 1)
            for col in axes(mat_b, 2)
                if sum(mat_b_padded[row-1:row+1, col-1:col+1]) < 5
                    parent(mat_b_padded)[row, col] = false
                end
            end
        end
        last_removal = start - sum(mat_b)
        total += last_removal
        start = sum(mat_b)
    end
    return total



end

input = readlines(".data/04.txt")
@benchmark res = solve(input)
# println(res)