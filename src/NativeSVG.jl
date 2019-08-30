module NativeSVG

export Drawing
export str, cdata

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
    :rect => false,
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
)

struct Drawing
    data :: Array{UInt8, 1}
end

const BUFFER = IOBuffer()

Base.showable(::MIME"image/svg+xml", _::NativeSVG.Drawing) = true

function Base.show(io::IO, svg::NativeSVG.Drawing)
    write(io, String(copy(svg.data)))
end

function Base.show(io::IO, ::MIME"image/svg+xml", svg::NativeSVG.Drawing)
    write(io, svg.data)
end

function Base.write(filename::AbstractString, svg::NativeSVG.Drawing)
    open(filename, "w") do io
        write(io, svg.data)
    end
end

function Drawing(f::Function, io=BUFFER; kwargs...)
    println(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    print(io, "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\"")
    for (arg, val) in kwargs
        print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
    end
    println(io, ">")
    f()
    println(io, "</svg>")
    Drawing(take!(BUFFER))
end

function str(txt::String, io=BUFFER)
    println(io, txt)
end

function cdata(txt::String, io=BUFFER)
    println(io, "<![CDATA[")
    println(io, txt)
    println(io, "]]>")
end

for primitive in keys(PRIMITIVES)
    eval(quote
        function $primitive(io=BUFFER; kwargs...)
            print(io, "<", $primitive)
            for (arg, val) in kwargs
                print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
            end
            println(io, "/>")
        end
        export $primitive
    end)
end

for primitive in keys(filter(d->last(d), PRIMITIVES))
    eval(quote
        function $primitive(f::Function, io=BUFFER; kwargs...)
            print(io, "<", $primitive)
            for (arg, val) in kwargs
                print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
            end
            println(io, ">")
            f()
            println(io, "</", $primitive, ">")
        end
    end)
end

function replacenotallowed(sym::Symbol)
    String(replace(collect(String(sym)), '_'=>'-', '!'=>':'))
end

end
