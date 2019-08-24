using Documenter
using Literate
using ElTopo

# try 
#     using AbstractPlotting, GLMakie  
#     @info "Animation with Makie is being made..."
#     let 
#         cd(joinpath(@__DIR__,"src"))
#         include(joinpath(@__DIR__,"../examples/enright.jl"))
#     end
# catch end

function dropexecution(content)
    content = replace(content, "```@example" => "```julia")
    return content
end

Literate.markdown(joinpath(@__DIR__, "../examples/index.jl"), joinpath(@__DIR__,"src/"); credit = false, name = "index")

Literate.markdown(joinpath(@__DIR__, "../examples/enright.jl"), joinpath(@__DIR__,"src/"); credit = false, name = "enright", postprocess=dropexecution)

Literate.script(joinpath(@__DIR__, "../examples/sphere.jl"), joinpath(@__DIR__,"src/"); credit = false, name = "sphere")

makedocs(sitename="ElTopo.jl",pages = ["index.md","enright.md"])

deploydocs(
     repo = "github.com/akels/ElTopo.jl.git",
 )
