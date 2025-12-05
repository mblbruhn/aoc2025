using BenchmarkTools

function find_highest_joltage(bank::String)
    highest = 0
    for ii = 1:length(bank)-1
        for jj = 1+ii:length(bank)
            current_joltage = parse(Int, bank[ii] * bank[jj])
            if current_joltage > highest
                highest = current_joltage
            end
        end
    end
    return highest
end

function optimize_joltage(bank::String, to_select)
    # some memoization, make the entire thing way faster
    return get!(cache, (bank, to_select)) do
        if to_select == 1
            return string(maximum(parse.(Int, split(bank, ""))))
        end
        highest = 0
        end_idx = length(bank) - to_select + 1
        for ii = 1:end_idx
            nums = []
            push!(nums, bank[ii], optimize_joltage(bank[ii+1:end], to_select - 1))
            this_num = parse(Int, reduce(*, nums))
            if this_num > highest && length(string(this_num)) == to_select
                highest = this_num
            end
        end
        return string(highest)
    end
end

input = readlines(".data/03.txt")
cache = Dict()
println(@btime (sum(parse.(Int, optimize_joltage.(input, 2))), 
    sum(parse.(Int, optimize_joltage.(input, 12)))))
part1 = sum(find_highest_joltage.(input))
part2 = sum(parse.(Int, optimize_joltage.(input, 12)))
println("$part1, $part2")
