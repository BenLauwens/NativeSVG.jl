struct Drawing
    data::Array{UInt8,1}
end

const BUFFER = IOBuffer()

Base.showable(::MIME"image/svg+xml", _::NativeSVG.Drawing) = true

function Base.show(io::IO, svg::NativeSVG.Drawing)
    write(io, String(copy(svg.data)))
end

function Base.show(io::IO, ::MIME"text/plain", svg::NativeSVG.Drawing)
    (isdefined(Main, :IJulia) && Main.IJulia.inited ||
     isdefined(Main, :Juno) && Main.Juno.isactive()) && return
    filename = "nativesvg.svg"
    open(filename, "w") do io
        write(io, svg.data)
    end
    if Sys.isapple()
        run(`open $(filename)`)
    elseif Sys.iswindows()
        cmd = get(ENV, "COMSPEC", "cmd")
        run(`$(ENV["COMSPEC"]) /c start $(filename)`)
    elseif Sys.isunix()
        run(`xdg-open $(filename)`)
    end
    return filename
end

function Base.show(io::IO, ::MIME"image/svg+xml", svg::NativeSVG.Drawing)
    write(io, svg.data)
end

function Base.write(filename::AbstractString, svg::NativeSVG.Drawing)
    open(filename, "w") do io
        println(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
        write(io, svg.data)
    end
end

function Drawing(f::Function, io::IOBuffer = BUFFER; kwargs...)
    svg(
        ;
        xmlns = "http://www.w3.org/2000/svg",
        kwargs...
    ) do
        f()
    end
    Drawing(take!(BUFFER))
end

function str(txt::String, io::IOBuffer = BUFFER)
    println(io, txt)
end

function cdata(txt::String, io::IOBuffer = BUFFER)
    println(io, "<![CDATA[")
    println(io, txt)
    println(io, "]]>")
end

const deps = normpath(joinpath(@__DIR__, "..", "deps"))
const tex2mml = joinpath(deps, "node_modules", "mathjax-node-cli", "bin", "tex2mml")

function latex(text::String, io::IOBuffer = BUFFER; kwargs...)
    foreignObject(; kwargs...) do
        cmd = `$tex2mml --inline=true --speech=false --semantics=false --notexhints=true $text`
        mml = read(cmd, String)
        print(io, mml)
    end
end

"""
    empty_element(tagname::String, io::IOBuffer = BUFFER; kwargs...)
Write an empty SVG element (no children) with the specified tagname
and attributes.
"""
function empty_element(tagname::String, io::IOBuffer = BUFFER; kwargs...)
  print(io, "<", tagname)
  for (arg, val) in kwargs
    print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
  end
  println(io, "/>")
end

function empty_element(tagname::Symbol, io::IOBuffer = BUFFER; kwargs...)
    empty_element(String(tagname), io; kwargs...)
end

"""
    element(f::Function, tagname::String, io::IOBuffer = BUFFER; kwargs...)
Write an SVG element with name tagname and the specified attributes.
The function f ic called to generate the SVG for the element's children.
"""
function element(f::Function, tagname::String, io::IOBuffer = BUFFER; kwargs...)
  print(io, "<", tagname)
  for (arg, val) in kwargs
    print(io, " ", replacenotallowed(arg), "=\"", val, "\"")
  end
  println(io, ">")
  f()
  println(io, "</", tagname, ">")
end

function element(f::Function, tagname::Symbol, io::IOBuffer = BUFFER; kwargs...)
    element(f, String(tagname), io; kwargs...)
end

export element, empty_element

# All SVG elements:
for primitive in keys(PRIMITIVES)
    eval(quote
        function $primitive(io::IOBuffer = BUFFER; kwargs...)
          empty_element($(QuoteNode(primitive)), io; kwargs...)
        end
    end)
end

# All SVG elements that can have children:
for primitive in keys(filter(d -> last(d), PRIMITIVES))
    eval(quote
        function $primitive(f::Function, io::IOBuffer = BUFFER; kwargs...)
          element(f, $(QuoteNode(primitive)), io; kwargs...)
        end
    end)
end

function replacenotallowed(sym::Symbol)
    String(replace(collect(String(sym)), '_' => '-', '!' => ':'))
end
