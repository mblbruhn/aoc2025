using BenchmarkTools


function input2graph(input::Vector{String})::Dict{String,Vector{String}}
    node_dict = Dict([String(split(l, ": ")[1]) => String.(split(split(l, ":")[2])) for l in input])
    return node_dict
end

function traverse_graph(graph::Dict{String,Vector{String}}, curr_node::String, target::String)
    return get!(cache, (curr_node, target)) do
        n_paths = 0
        next_nodes = graph[curr_node]
        for nn in next_nodes
            if nn == target
                return 1
            end
            if nn == "out" # when the graph ends but 'out' was not the target
                return 0
            end
            n_paths += traverse_graph(graph, nn, target)
        end
        return n_paths
    end
end

function p2(graph)
    # The graph has unidirectional edges: keys are unique and data can only flow in one direction
    # this means that the paths are either fft => dac or dac => fft, not both
    #   (since reversibility would make the graph cyclic, which it isn't)
    # after knowing in which order the data flows through (fft, dac), the problem can be reformulated:
    # how many options are there from svr => fft/dac, from fft/dac => fft/dac, from fft/dac => out
    # then multiplying the answers

    dac_fft = traverse_graph(graph, "dac", "fft")
    fft_dac = traverse_graph(graph, "fft", "dac")

    if dac_fft > 0 # Whether any connection between dac => fft have been found
        return (traverse_graph(graph, "svr", "dac") *
                dac_fft *
                traverse_graph(graph, "fft", "out"))
    else
        return (traverse_graph(graph, "svr", "fft") *
                fft_dac *
                traverse_graph(graph, "dac", "out"))
    end
end


function main(input)
    graph = input2graph(input)
    global cache = Dict{Tuple{String,String},Int}()
    n_paths_p1 = traverse_graph(graph, "you", "out")
    n_paths_p2 = p2(graph)
    return n_paths_p1, n_paths_p2
end




input = readlines(".data/11.txt")
@benchmark main(input)