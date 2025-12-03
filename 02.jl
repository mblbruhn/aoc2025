using BenchmarkTools


function count_doubles_naive(input)
    ranges = split(input, ",")
    false_ids_sum = 0
    for r in ranges
        hyphen_idx = findfirst('-', r)
        first_num, last_num = parse(Int, r[1:hyphen_idx-1]), parse(Int, r[hyphen_idx+1:end])
        for num in first_num:last_num
            num = string(num)
            if length(num) % 2 == 0
                if num[1:end÷2] == num[end÷2+1:end]
                    false_ids_sum += parse(Int, num)
                end
            end
        end
    end
    return false_ids_sum
end

function count_duplicates_naive(input)
    ranges = split(input, ",")
    false_ids_sum = 0
    for r in ranges
        hyphen_idx = findfirst('-', r)
        first_num, last_num = parse(Int, r[1:hyphen_idx-1]), parse(Int, r[hyphen_idx+1:end])
        for num in first_num:last_num
            num = string(num)
            # for substring_length in 1:Int(ceil(sqrt(length(num))))
            for substring_length in 1:length(num)÷2
                if length(num) % substring_length == 0
                    options_this_length = [num[1+offset:substring_length+offset] for offset in 0:substring_length:length(num)-substring_length]
                    if all(y -> y == options_this_length[1], options_this_length) # all items the same
                        false_ids_sum += parse(Int, num)
                        break
                    end
                end
            end
        end
    end
    return false_ids_sum
end

input = readlines(".data/02.txt")[1]
count = count_doubles_naive(input)
println("Part 1: Sum over all false IDs:\t$count")
count2 = count_duplicates_naive(input)
println("Part 2: Sum over all false IDs:\t$count2")
@benchmark (count_doubles_naive(input), count_duplicates_naive(input))
