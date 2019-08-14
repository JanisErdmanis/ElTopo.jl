using ElTopo
using Documenter
using Literate

### @setup block could be used for the include

function replace_includes(str)

    included = ["sphere.jl"]

    # Here the path loads the files from their proper directory,
    # which may not be the directory of the `examples.jl` file!
    path = "examples/"

    for ex in included
        content = read(path*ex, String)
        str = replace(str, "include(\"$(ex)\")" => content)
    end
    return str
end

# function replace_includes(str)
#     ex = "sphere.jl"
#     str = replace(str, "include(\"sphere.jl\")" => "include(\"../../examples/sphere.jl\")")
#     return str
# end

Literate.markdown(joinpath(@__DIR__, "../examples/index.jl"), joinpath(@__DIR__,"src/"); credit = false, name = "index", preprocess=replace_includes)
Literate.markdown(joinpath(@__DIR__, "../examples/enright.jl"), joinpath(@__DIR__,"src/"); credit = false, name = "enright", preprocess = replace_includes)

makedocs(sitename="ElTopo.jl",pages = ["index.md","enright.md"])
#makedocs(sitename="ElTopo.jl",pages = ["index.md"])

deploydocs(
     repo = "github.com/akels/ElTopo.jl.git",
 )
