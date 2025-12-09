using BenchmarkTools

@views function area(a::Vector{Int}, b::Vector{Int})
    return (abs(a[1] - b[1]) + 1) * (abs(a[2] - b[2]) + 1)
end

function contour(coords)
    outer = Set{Tuple{Int,Int}}()
    for ii = 1:length(coords)-1
        if coords[ii][1] == coords[ii+1][1]
            if coords[ii][2] > coords[ii+1][2]
                union!(outer, Set((coords[ii][1], kk) for kk in coords[ii][2]:-1:coords[ii+1][2]))
            else
                union!(outer, Set((coords[ii][1], kk) for kk in coords[ii][2]:coords[ii+1][2]-1))
            end
        else
            if coords[ii][1] > coords[ii+1][1]
                union!(outer, Set((kk, coords[ii][2]) for kk in coords[ii][1]:-1:coords[ii+1][1]))
            else
                union!(outer, Set((kk, coords[ii][2]) for kk in coords[ii][1]:coords[ii+1][1]-1))
            end
        end
    end
    if coords[end][1] == coords[1][1]
        if coords[end][2] > coords[1][2]
            union!(outer, Set((coords[end][1], kk) for kk in coords[end][2]:-1:coords[1][2]))
        else
            union!(outer, Set((coords[end][1], kk) for kk in coords[end][2]:coords[1][2]-1))
        end
    else
        if coords[end][1] > coords[1][1]
            union!(outer, Set((kk, coords[end][2]) for kk in coords[end][1]:-1:coords[1][1]))
        else
            union!(outer, Set((kk, coords[end][2]) for kk in coords[end][1]:coords[1][1]-1))
        end
    end
    return outer
end

function rectangle_is_within_bounds(outer::Set{Tuple{Int,Int}}, a::Vector{Int}, b::Vector{Int})
    # It is (is it?) sufficient for a rectangle to have all four points within bounds to also
    # have all other points in bounds (I think this should at least apply to all convex boundaries)
    (x1, y1), (x2, y2) = a, b
    x_hi, x_lo = x1 > x2 ? (x1, x2) : (x2, x1)
    y_hi, y_lo = y1 > y2 ? (y1, y2) : (y2, y1)
    coord_list = [[x_lo + 1, y_lo + 1], [x_hi - 1, y_lo + 1], [x_hi - 1, y_hi - 1], [x_lo + 1, y_hi - 1]]
    inner_cnt_rect = contour(coord_list)

    return length(intersect(outer, inner_cnt_rect)) == 0
end

function part1(input::Vector{String})
    coord_len = length(input)
    coords = input .|>
             x -> split(x, ",") |>
                  x -> parse.(Int, x)
    outer = contour(coords)
    max_size_red = 0
    max_size_green = 0
    for ii = 1:coord_len
        println("Iteration: $ii")
        for jj = ii+1:coord_len
            a = area(coords[ii], coords[jj])
            if a > max_size_red
                max_size_red = a
                println("Update Red: $(coords[ii]), $(coords[jj]) => $max_size_red")
            end
            if rectangle_is_within_bounds(outer, coords[ii], coords[jj]) && a > max_size_green
                max_size_green = a
                println("Update Green: $(coords[ii]), $(coords[jj]) => $max_size_green")
            end
        end
    end
    return max_size_red, max_size_green
end


input = readlines(".data/09.txt")
k = part1(input)