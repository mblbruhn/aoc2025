using BenchmarkTools

function add_to_state(s, x)
    """Return the number of wrap-arounds for RH rotation."""
    if s + x == 100
        return 0, 0
    elseif s + x < 100
        return s + x, 0
    else
        s, wraps = add_to_state(s, x-100)
        return s, wraps + 1
    end
end

function sub_from_state(s, x)
    """Return the number of wrap-arounds for LH rotation."""
    if s - x >= 0
        return s - x, 0
    elseif s == 0 && s - x > -100
        return 100 + (s - x), 0
    elseif s - x > -100
        return 100 + (s - x), 1
    else
        s, wraps = sub_from_state(s, x-100)
        return s, wraps + 1
    end
end

function number_of_zeros(input)
    state = 50
    n_zeros = 0
    n_wrap_arounds = 0

    for line in input
        clicks = parse(Int, line[2:end])

        if line[1] == 'L'
            state, wrap_arounds = sub_from_state(state, clicks)
        elseif line[1] == 'R'
            state, wrap_arounds = add_to_state(state, clicks)
        end

        n_wrap_arounds += wrap_arounds
        n_zeros += state == 0
    end
    return n_zeros, n_wrap_arounds + n_zeros
end


raw_input = readlines(".data/01.txt")
p1, p2 = number_of_zeros(raw_input)
println("Number of times state was zero: \t\t\t\t$p1 (Solution part 1)\n\
            Number of times the state was zero or passed through zero: \t$p2 (Solution part 2)")

@benchmark number_of_zeros(raw_input)