module NativeSVG

using Juno

export SVG, finish, preview
export line, circle, path, rect, polygon, polyline, ellipse, tref, stop
export g, text, defs, style, linearGradient, radialGradient, pattern, tspan, textPath
export str, cdata

struct SVG
    filename :: String
    buffer :: IOBuffer
    bufferdata :: Array{UInt8, 1}
    SVG(fname::String="") = new(fname, IOBuffer(), UInt8[])
end

const CRSVG = Ref(SVG())

Base.showable(::MIME"image/svg+xml", _::NativeSVG.SVG) = true

function Base.show(io::IO, ::MIME"image/svg+xml", svg::NativeSVG.SVG)
    write(io, svg.bufferdata)
end

function SVG(f::Function, fname="nativeSVG-drawing.svg"; kwargs...)
    CRSVG[] = SVG(fname)
    io = CRSVG[].buffer
    print(io, "<svg xmlns=\"http://www.w3.org/2000/svg\"")
    for (arg, val) in kwargs
        print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
    end
    println(io, ">")
    f()
    println(io, "</svg>")
    CRSVG[]
end

function finish()
    append!(CRSVG[].bufferdata, take!(CRSVG[].buffer))
    open(CRSVG[].filename, "w") do io
        write(io, CRSVG[].bufferdata)
    end
end

function preview()
    (isdefined(Main, :IJulia) && Main.IJulia.inited) ? jupyter = true : jupyter = false
    Juno.isactive() ? juno = true : juno = false
    if jupyter
        Main.IJulia.clear_output(true)
        display_ijulia(MIME("image/svg+xml"), CRSVG[].filename)
        return
    elseif juno
        display(CRSVG[])
        return
    elseif Sys.isapple()
        run(`open $(CRSVG[].filename)`)
        return CRSVG[].filename
    elseif Sys.iswindows()
        cmd = get(ENV, "COMSPEC", "cmd")
        run(`$(ENV["COMSPEC"]) /c start $(CRSVG[].filename)`)
        return CRSVG[].filename
    elseif Sys.isunix()
        run(`xdg-open $(CRSVG[].filename)`)
        return CRSVG[].filename
    end
end

function str(txt::String, io=CRSVG[].buffer)
    println(io, txt)
end

function cdata(txt::String, io=CRSVG[].buffer)
    println(io, "<![CDATA[")
    println(io, txt)
    println(io, "]]>")
end

for primitive in (:line, :circle, :path, :rect, :polygon, :polyline, :ellipse, :stop, :tref)
    eval(quote
        function $primitive(io=CRSVG[].buffer; kwargs...)
            print(io, "<", $primitive)
            for (arg, val) in kwargs
                print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
            end
            println(io, "/>")
        end
    end)
end

for primitive in (:g, :text, :defs, :style, :linearGradient, :radialGradient, :pattern, :tspan, :textPath)
    eval(quote
        function $primitive(f::Function, io=CRSVG[].buffer; kwargs...)
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
