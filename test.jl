using PaddedViews
using BenchmarkTools


function solvep2(input::Vector{String})::Int64
    mat::Matrix{String} = reduce(hcat, split.(input, ""))
    d::Dict{String, Bool} = Dict("." => false, "@" => true)
    mat_b::Matrix{Bool} = collect(map(x -> d[x], mat))
    mat_b_padded = PaddedView(false, mat_b, (0:mat.size[1]+1, 0:mat.size[2]+1))
    initial = sum(mat_b)
    temp::Int64 = 0
    while temp != sum(mat_b)
        temp = sum(mat_b)
        for row in axes(mat_b, 1)
            for col in axes(mat_b, 2)
                if sum(@inbounds @view mat_b_padded[row-1:row+1, col-1:col+1]) < 5
                    parent(mat_b_padded)[row, col] *= false
                end
            end
        end
    end
    return initial - temp
end

input::Vector{String} = readlines(".data/04.txt")
@benchmark res = solvep2(input)
# println(res)