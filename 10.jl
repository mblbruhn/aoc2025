using BenchmarkTools
using JuMP
using HiGHS

function parse_input_p1(input)::Tuple{Vector{BitArray}, Vector{BitArray}}
    split_lines = split.(input, " ")
    lights = [sl[1] for sl in split_lines]
    buttons = [sl[2:end-1] for sl in split_lines]

    button_mats = Vector{BitArray}()
    light_vecs = Vector{BitVector}()
    for ii in eachindex(input)
        light = lights[ii]
        button = buttons[ii]
        light_vec = BitArray([c == '.' ? false : true for c in light[2:end-1]])
        rows = length(light_vec)
        cols = length(button)
        button_mat = falses((rows, cols))
        for jj in 1:cols
            set_true = parse.(Int, split(button[jj][2:end-1], ",")).+1
            button_mat[set_true, jj] .= true
        end
        push!(button_mats, button_mat)
        push!(light_vecs, light_vec)
    end
    button_mats, light_vecs
end

function parse_input_p2(input::Vector{String})::Tuple{Vector{Matrix{Int}}, Vector{Vector{Int}}}
    split_lines = split.(input, " ")
    joltages = [sl[end] for sl in split_lines]
    buttons = [sl[2:end-1] for sl in split_lines]

    button_mats = Vector{Matrix{Int}}()
    jolt_vecs = Vector{Vector{Int}}()
    for ii in eachindex(input)
        jolt = joltages[ii]
        button = buttons[ii]
        jolt_vec = parse.(Int, split(jolt[2:end-1], ","))
        rows = length(jolt_vec)
        cols = length(button)
        button_mat = zeros(Int, (rows, cols))
        for jj in 1:cols
            set_true = parse.(Int, split(button[jj][2:end-1], ",")).+1
            button_mat[set_true, jj] .= true
        end
        push!(button_mats, button_mat)
        push!(jolt_vecs, jolt_vec)
    end
    button_mats, jolt_vecs
end

function gauss_elim(M::BitMatrix, t::BitVector)
    """Gauss elimination for reduced row echelon form, implemented for bool logic."""
    A = hcat(M, t) # concatenate mat and vec
    rows, cols = size(M)
    pivot_row = 1

    for col = 1:cols
        pivot_row > rows ? break : nothing
        possible_row = nothing
        for pr = pivot_row:rows 
            if A[pr, col]
                possible_row = pr 
                break
            end
        end
        if possible_row === nothing; continue; end

        if possible_row != pivot_row
            A[pivot_row, :], A[possible_row, :] = A[possible_row, :], A[pivot_row, :]
        end

        for rr in 1:rows
            if rr != pivot_row && A[rr, col]
                A[rr, :] .⊻= A[pivot_row, :] # xor (since it's boolean logic)
            end
        end
        pivot_row += 1
    end
    return A
end

function solve_min_weight(rref::BitMatrix)::Int
    rows, cols = size(rref)
    n_vars = cols - 1
    
    pivots = Int[]
    pivot_to_row = Dict{Int, Int}()
    
    for r in 1:rows
        p_col = findfirst(rref[r, 1:n_vars])
        
        if !isnothing(p_col)
            push!(pivots, p_col)
            pivot_to_row[p_col] = r
        end
    end
    
    free_vars = setdiff(1:n_vars, pivots)
    min_weight = Inf
    
    # try all combinations of free variables (either 1 or 0)
    num_combinations = 2^length(free_vars)
    for i in 0:(num_combinations - 1)
        x = falses(n_vars)
        bits = digits(i, base=2, pad=length(free_vars))
        for (idx, f_col) in enumerate(free_vars)
            x[f_col] = bits[idx] == 1
        end
        
        for p_col in pivots
            r = pivot_to_row[p_col]
            val = rref[r, end]
            for f_col in free_vars
                if rref[r, f_col] && x[f_col]
                    val = !val # XOR operation
                end
            end
            x[p_col] = val
        end

        current_weight = sum(x)
        if current_weight < min_weight
            min_weight = current_weight
        end
    end
    
    return min_weight
end

function solve_ilp(buttons::Matrix{Int}, target::Vector{Int})::Int
    """Solve integer linear programming problem with JuMP using the HiGHS optimizer."""
    rows, cols = size(buttons)
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    @variable(model, x[1:cols] >= 0, Int) # constraint x ∈ N, i.e. positive integer
    for r in 1:rows
        # constrain the sum along each row to the target
        @constraint(model, sum(buttons[r, c] * x[c] for c in 1:cols) == target[r])
    end
    @objective(model, Min, sum(x)) # objective is to minimize the sum over x
    optimize!(model)

    return Int(objective_value(model))
end

function solve_p1(input::Vector{String})::Int
    buttons, lights = parse_input_p1(input)
    total = 0
    for (button, light) in zip(buttons, lights)
        m = gauss_elim(button, light)
        total += solve_min_weight(m)
    end
    return total
end

function solve_p2(input::Vector{String})::Int
    buttons, jolts = parse_input_p2(input)
    total = 0
    for (button, jolt) in zip(buttons, jolts)
        total += solve_ilp(button, jolt)
    end
    return total
end

function main(input)::Tuple{Int, Int}
    return solve_p1(input), solve_p2(input)
end

input = readlines(".data/10-test.txt")
@benchmark main(input)