println("adicionando processos")
addprocs(4)
p = procs()
println("processos $p")

################################################################################
repeat("#", 80) |> println
println("populate1")
repeat("#", 80) |> println

p = cycle(p)

@everywhere function randProc(arr::SharedArray, index::Int)
    arr[index] = rand(1:5)
    println(myid())
end

function populate1(arr::SharedArray, proc::Base.Cycle)
    state = start(proc)
    for i in 1:length(arr)
        value, state = next(proc, state)
        remotecall_fetch(randProc, value, arr, i)
    end
end
################################################################################
repeat("#", 80) |> println
println("populate2")
repeat("#", 80) |> println
function populate2(arr::SharedArray)
    @parallel for i in 1:length(arr)
        randProc(arr, i)
    end
end
################################################################################

repeat("#", 80) |> println
println("execution:")
repeat("#", 80) |> println

arr = SharedArray(Int, 1000)

println("populate1")
@time populate1(arr, p)

println("populate2")
@time populate2(arr)
#println(arr)
