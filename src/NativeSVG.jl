module NativeSVG

using Juno

export Drawing, finish, preview
export line, circle, path, rect, polygon, polyline, ellipse, tref, stop
export g,
       text,
       defs,
       style,
       linearGradient,
       radialGradient,
       pattern,
       tspan,
       textPath
export str, cdata

struct Drawing
    filename::String
    buffer::IOBuffer
    bufferdata::Array{UInt8,1}
    Drawing(fname::String = "") = new(fname, IOBuffer(), UInt8[])
end

const DRAWING = Ref(Drawing())

Base.showable(::MIME"image/svg+xml", _::NativeSVG.Drawing) = true

function Base.show(io::IO, ::MIME"image/svg+xml", svg::NativeSVG.Drawing)
    write(io, svg.bufferdata)
end

function Drawing(f::Function, fname = "nativeSVG-drawing.svg"; kwargs...)
    DRAWING[] = Drawing(fname)
    io = DRAWING[].buffer
    print(io, "<svg xmlns=\"http://www.w3.org/2000/svg\"")
    for (arg, val) in kwargs
        print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
    end
    println(io, ">")
    f()
    println(io, "</svg>")
    DRAWING[]
end

function finish()
    append!(DRAWING[].bufferdata, take!(DRAWING[].buffer))
    open(DRAWING[].filename, "w") do io
        write(io, DRAWING[].bufferdata)
    end
end

function preview()
    (isdefined(Main, :IJulia) && Main.IJulia.inited) ? jupyter = true :
    jupyter = false
    Juno.isactive() ? juno = true : juno = false
    if jupyter
        Main.IJulia.clear_output(true)
        display_ijulia(MIME("image/svg+xml"), DRAWING[].filename)
        return
    elseif juno
        display(DRAWING[])
        return
    elseif Sys.isapple()
        run(`open $(DRAWING[].filename)`)
        return DRAWING[].filename
    elseif Sys.iswindows()
        cmd = get(ENV, "COMSPEC", "cmd")
        run(`$(ENV["COMSPEC"]) /c start $(DRAWING[].filename)`)
        return DRAWING[].filename
    elseif Sys.isunix()
        run(`xdg-open $(DRAWING[].filename)`)
        return DRAWING[].filename
    end
end

function str(txt::String, io = DRAWING[].buffer)
    println(io, txt)
end

function cdata(txt::String, io = DRAWING[].buffer)
    println(io, "<![CDATA[")
    println(io, txt)
    println(io, "]]>")
end

for primitive in (
    :line,
    :circle,
    :path,
    :rect,
    :polygon,
    :polyline,
    :ellipse,
    :stop,
    :tref
)
    eval(quote
        function $primitive(io = DRAWING[].buffer; kwargs...)
            print(io, "<", $primitive)
            for (arg, val) in kwargs
                print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
            end
            println(io, "/>")
        end
    end)
end

for primitive in (
    :g,
    :text,
    :defs,
    :style,
    :linearGradient,
    :radialGradient,
    :pattern,
    :tspan,
    :textPath
)
    eval(quote
        function $primitive(f::Function, io = DRAWING[].buffer; kwargs...)
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
    String(replace(collect(String(sym)), '_' => '-', '!' => ':'))
end

end
