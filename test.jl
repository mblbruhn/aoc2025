function add_to_state(s, x)
    """This function return the number of wrap-arounds."""
    if s + x == 100
        return 0, 0
    elseif s + x < 100
        return s + x, 0
    else
        x -= 100
        s, wraps = add_to_state(s, x)
        println(state)
        return s, wraps + 1
    end
end

function sub_from_state(s, x)
    if s - x == 0
        return 0, 0
    elseif s - x > 0
        return s-x, 0
    elseif s == 0 && s-x > -100
        return 100 + (s - x), 0
    elseif s - x > -100
        return 100 + (s - x), 1
    else
        x -= 100
        s, wraps = sub_from_state(s, x)
        return s, wraps + 1
    end
end


state = 0
clicks = 5

new_state, n = sub_from_state(state, clicks)
println("New state: $new_state; Number of wraps: $n")