module NativeSVG

using NodeJS

export Drawing
export str, cdata, latex

const PRIMITIVES = Dict(
    :svg => true,
    :g => true,
    :defs => true,
    :use => false,
    :desc => true,
    :title => true,
    :style => true,
    :path => false,
    :line => false,
    :rect => true,
    :polygon => false,
    :polyline => false,
    :circle => false,
    :ellipse => false,
    :text => true,
    :tspan => true,
    :textPath => true,
    :linearGradient => true,
    :radialGradient => true,
    :stop => false,
    :pattern => true,
    :marker => true,
    :clipPath => true,
    :style => true,
    :foreignObject => true,
)

for primitive in keys(PRIMITIVES)
    eval(quote
        export $primitive
    end)
end

export Turtle

const COMMANDS = (:forward, :turn, :penup, :pendown, :pencolor,)

for command in COMMANDS
    eval(quote
        export $command
    end)
end

include("svg.jl")
include("turtles.jl")

end
