using BenchmarkTools


function part1()
    mystring = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

    mystring = read(".data/05.txt", String)

    sep = "\r\n"

    IDs = parse.(Int64, split(split(mystring, sep * sep)[2], sep))
    ranges = [parse.(Int64, split(range, "-")) for range in split(split(mystring, sep * sep)[1], sep)]
    #ranges_full = collect(Iterators.flatten([collect(range[1]:range[2]) for range in ranges]))


    summ = 0
    for ID in IDs
        for range in ranges
            if (range[1] <= ID <= range[2])
                summ += 1
                break
            end
        end
    end
    # println(summ)
end

function part2()
    mystring = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

    mystring = read(".data/05.txt", String)
    sep = "\r\n"

    IDs = parse.(Int64, split(split(mystring, sep * sep)[2], sep))
    ranges = [parse.(Int64, split(range, "-")) for range in split(split(mystring, sep * sep)[1], sep)]
    #make into array, probably faster
    ranges = reduce(vcat, transpose.(ranges))

    #Some ranges have overlap with over ranges. 
    #To solve this, we need to compare every range with every suceeding range and shorten it accordingly
    NN = size(ranges)[1]
    for ii = 1:NN
        for jj = 1:NN
            #if ranges[jj,1] <= ranges[ii, 1] <= ranges[jj,2]  #if the start of current range is inside another range
            #   ranges[ii,1] = ranges[jj,1] #set start point to other start point
            #end
            if jj != ii
                if ranges[jj, 1] <= ranges[ii, 2] <= ranges[jj, 2]  #same thing for end of range
                    ranges[ii, 2] = ranges[jj, 1] - 1 #
                end
            end
        end
    end
    #ranges
    s = sum(ranges[:, 2] - ranges[:, 1]) + NN
    # println(s)
end


@benchmark (part2(), part1())
