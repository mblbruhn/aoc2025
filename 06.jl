using BenchmarkTools

function part1(input::Vector{String})::Int
    nums = (
        input[1:SIGNLINE-1] |>
        x -> split.(x) |>
             y -> map(x -> parse.(Int, x), y) |>
                  x -> stack(x, dims=2)
    )
    signs = input[SIGNLINE] |> split
    total::Int = 0
    for ii in axes(nums, 1)
        if signs[ii] == "*"
            total += reduce(*, nums[ii, :])
        elseif signs[ii] == "+"
            total += reduce(+, nums[ii, :])
        end
    end
    return total
end

function part2(input::Vector{String})
    sign_line = input[SIGNLINE]
    nums::Vector{Int} = []
    total::Int = 0
    for ii in length(sign_line):-1:1
        push!(nums,
            @views digits_to_num(
                [d[ii] == ' ' ? 0 : parse(Int, d[ii])
                 for d::String in input[1:SIGNLINE-1]]
            )
        )
        sign = sign_line[ii]
        if sign != ' '
            if sign == '*'
                total += reduce(*, nums[nums.>0])
                nums = []
            else
                total += reduce(+, nums)
                nums = []
            end
        end
    end
    return total
end

@inline @views function digits_to_num(a)
    first_idx = 1
    last_idx = SIGNLINE - 1
    for ii = 1:SIGNLINE-1
        if a[ii] == 0
            first_idx += 1
        else
            break
        end
    end
    for ii = SIGNLINE-1:-1:1
        if a[ii] == 0
            last_idx -= 1
        else
            break
        end
    end
    return reduce((x, y) -> muladd(10, x, y), a[first_idx:last_idx], init=0)
end

filename = ".data/06.txt"

input = readlines(filename)
const SIGNLINE = length(input)
@benchmark (part1(input), part2(input))
