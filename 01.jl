function add_to_state(s, x)
    """This function returns the number of wrap-arounds."""
    if s + x == 100
        return 0, 0
    elseif s + x < 100
        return s + x, 0
    else
        x -= 100
        s, wraps = add_to_state(s, x)
        return s, wraps + 1
    end
end

function sub_from_state(s, x)
    if s - x == 0
        return 0, 0
    elseif s - x > 0
        return s - x, 0
    elseif s == 0 && s - x > -100
        return 100 + (s - x), 0
    elseif s - x > -100
        return 100 + (s - x), 1
    else
        x -= 100
        s, wraps = sub_from_state(s, x)
        return s, wraps + 1
    end
end

function number_of_zeros(input)
    state = 50
    n_zeros_p1 = 0
    n_zeros_p2 = 0

    for line in input
        clicks = parse(Int, line[2:end])

        if line[1] == 'L'
            state, n = sub_from_state(state, clicks)
        elseif line[1] == 'R'
            state, n = add_to_state(state, clicks)
        end
        n_zeros_p2 += n

        if state % 100 == 0
            n_zeros_p1 += 1
            n_zeros_p2 += 1
        end
    end
    return n_zeros_p1, n_zeros_p2
end

raw_input = readlines(".data/01.txt")
p1, p2 = number_of_zeros(raw_input)
println("Number of times state was zero: \t\t\t\t$p1 (Solution part 1)\n\
Number of times the state was zero or passed through zero: \t$p2 (Solution part 2)")