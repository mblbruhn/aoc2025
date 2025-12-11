using BenchmarkTools


function input2graph(input::Vector{String})::Dict{String, Vector{String}}
    node_dict = Dict([String(split(l, ": ")[1]) => String.(split(split(l, ":")[2])) for l in input])
    return node_dict
end

function traverse_graph(graph::Dict{String, Vector{String}}, node::String)
    n_paths = 0
    next_nodes = graph[node]
    for nn in next_nodes
        if nn == "out"
            return 1
        end
        n_paths += traverse_graph(graph, nn)
    end
    return n_paths
end

function solve_p1(input)
    graph = input2graph(input)
    n_paths = traverse_graph(graph, "you")
    return n_paths
end



input = readlines(".data/11.txt")
solve_p1(input)