function read_puzzle(file)
    s = read(file, String) |> strip
    fresh, avail = split(s, "\n\n")
    fresh = map(split(fresh, "\n")) do s
        a, b = parse.(Int, split(s, "-"))
        a:b
    end
    avail = map(split(avail, "\n")) do s
        parse(Int, s)
    end
    fresh, avail
end

function compute(fresh, avail)
    part1 = 0
    for a in avail
        for f in fresh
            if a in f
                part1 += 1
                break
            end
        end
    end
    # println(part1)
    part2 = 0
    sort!(fresh, lt=(x, y) -> x.start < y.start)
    i = 1
    while i <= length(fresh)
        start = fresh[i].start
        finish = fresh[i].stop
        i = i+1
        while i <= length(fresh) && fresh[i].start <= finish
            finish = max(finish, fresh[i].stop)
            i += 1
        end
        part2 += finish - start + 1
    end
    # println(part2)
end

fresh, avail = read_puzzle(".data/05.txt")
compute(fresh, avail)