module NativeSVG

using Dates

export svg
export line, circle, path, rect, polygon, polyline, ellipse, tref, stop
export g, text, defs, linearGradient, radialGradient, pattern, tspan, textPath
export str, cdata

const BUFFER = Ref(IOBuffer())

function svg(f::Function, fname="svg-drawing-$(Dates.format(Dates.now(), "HHMMSS_s")).svg"; kwargs...)
    BUFFER[] = IOBuffer()
    io = BUFFER[]
    print(io, "<svg xmlns=\"http://www.w3.org/2000/svg\"")
    for (arg, val) in kwargs
        print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
    end
    println(io, ">")
    f()
    println(io, "</svg>")
    open(fname, "w") do file
        write(file, String(take!(io)))
    end
end

function str(txt::String, io=BUFFER[])
    println(io, txt)
end

function cdata(txt::String, io=BUFFER[])
    println(io, "<![CDATA[")
    println(io, txt)
    println(io, "]]>")
end

for primitive in (:line, :circle, :path, :rect, :polygon, :polyline, :ellipse, :stop, :tref)
    eval(quote
        function $primitive(io=BUFFER[]; kwargs...)
            print(io, "<", $primitive)
            for (arg, val) in kwargs
                print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
            end
            println(io, "/>")
        end
    end)
end

for primitive in (:g, :text, :defs, :linearGradient, :radialGradient, :pattern, :tspan, :textPath)
    eval(quote
        function $primitive(f::Function, io=BUFFER[]; kwargs...)
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
