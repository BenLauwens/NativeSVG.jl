abstract type PlotObject end

abstract type Axes <: PlotObject end

abstract type Plot <: PlotObject end

const FIGUREARGS = (:width, :height, :subplot, :currentaxes, :hold)

struct Figure
    axes::Dict{UInt8,Axes}
    args::Dict{Symbol,Any}
    function Figure(; kwargs...)
        fig = new(Dict{UInt8,Axes}(), Dict{Symbol,Any}())
        for (key, value) in kwargs
            key ∈ FIGUREARGS && (fig[key] = value)
        end
        get!(fig.args, :width, 640)
        get!(fig.args, :height, 480)
        get!(fig.args, :subplot, (1, 1))
        get!(fig.args, :currentaxes, 1)
        get!(fig.args, :hold, false)
        fig
    end
end

const CURRENTFIGURE = Ref(Figure())

Base.showable(::MIME"image/svg+xml", _::NativeSVG.PlotObject) = true

function Base.show(io::IO, mime::MIME"image/svg+xml", _::NativeSVG.PlotObject)
    show(io, mime, gcf())
end

Base.showable(::MIME"image/svg+xml", _::NativeSVG.Figure) = true

function Base.show(io::IO, mime::MIME"image/svg+xml", fig::NativeSVG.Figure)
    show(io, mime, Drawing(fig))
end

function Base.getindex(object::Union{PlotObject,Figure}, key::Symbol)
    return object.args[key]
end

function Base.setindex!(object::Union{PlotObject,Figure}, v, key::Symbol)
    object.args[key] = v
end

function positionaxes(fig::Figure = gcf())
    xdim, ydim = fig[:subplot]
    nr = fig[:currentaxes]
    w = 1 / xdim
    h = 1 / ydim
    x, y = divrem(nr-1, ydim)
    #(0.125 + x * w, 0.1 + y * h, w - 0.2, h - 0.2)
    ((0.125 + x) * w, (0.1 +y) * h, 0.8 * w, 0.8 * h)
end

const CARTESIANARGS = (:xlim, :ylim, :xscale, :yscale, :position,)

struct Cartesian <: Axes
    plots::Array{Plot,1}
    args::Dict{Symbol,Any}
    function Cartesian(; kwargs...)
        axes = new(Array{Plot,1}(), Dict{Symbol,Any}())
        for (key, value) in kwargs
            key ∈ CARTESIANARGS && (axes[key] = value)
        end
        get!(axes.args, :xscale, :linear)
        get!(axes.args, :yscale, :linear)
        get!(axes.args, :position, positionaxes())
        axes
    end
end

const LINEARGS = (:linewidth,)

struct Line <: Plot
    data::Array{Float64,2}
    args::Dict{Symbol,Any}
    function Line(x::AbstractVector, y::AbstractVector; kwargs...)
        length(x) != length(y) && error("Length not equal!")
        data = [float(x[:]) float(y[:])]
        line = new(data, Dict{Symbol,Any}())
        for (key, value) in kwargs
            key ∈ LINEARGS && (line[key] = value)
        end
        get!(line.args, :linewidth, 0.5)
        line
    end
end

gcf() = CURRENTFIGURE[]

function hold(v::Bool)
    CURRENTFIGURE[][:hold] = v
end

function figure(fig::Union{Figure,Nothing} = nothing; kwargs...)
    fig == nothing && (fig = Figure(; kwargs...))
    CURRENTFIGURE[] = fig
end

gca(fig::Figure = gcf()) = fig.axes[fig[:currentaxes]]

function axes(
    axes::Union{Figure,Nothing} = nothing,
    fig::Figure = gcf();
    kwargs...
)
    axes == nothing && (axes = Cartesian(; kwargs...))
    fig.axes[fig[:currentaxes]] = axes
end

function subplot(xdim::Int, ydim::Int, nr::Int, fig::Figure = gcf())
    empty(fig.axes)
    fig[:subplot] = (xdim, ydim)
    fig[:currentaxes] = nr
    fig[:hold] = false
end

function xlabel(txt::String, fig::Figure = gcf(); kwargs...)
    axes = get!(fig.axes, fig[:currentaxes],)
    axes[:xlabel] = txt
end

function ylabel(txt::String, fig::Figure = gcf(); kwargs...)
    axes = get!(fig.axes, fig[:currentaxes],)
    axes[:ylabel] = txt
end

function plot(x::AbstractVector, y::AbstractVector, fig::Figure = gcf(); kwargs...)
    if !fig[:hold] || fig[:currentaxes] ∉ keys(fig.axes)
        fig.axes[fig[:currentaxes]] = Cartesian(; kwargs...)
    end
    axes = fig.axes[fig[:currentaxes]]
    line = Line(x, y; kwargs...)
    push!(axes.plots, line)
    line
end

function Drawing(fig::Figure)
    width = fig[:width]
    height = fig[:height]
    Drawing(
        width = width,
        height = height,
        xmlns!xlink = "http://www.w3.org/1999/xlink"
    ) do
        defs() do
            clipPath(id = "clipwindow") do
                rect(x = 0, y = 0, width = width, height = height)
            end
        end
        rect(x = 0, y = 0, width = "100%", height = "100%", fill = "lightgrey")
        g(clip_path = "url(#clipwindow)") do
            axes = fig.axes
            for (nr, axes) in fig.axes
                pos = axes[:position]
                x = pos[1] * width
                y = pos[2] * height
                w = pos[3] * width
                h = pos[4] * height
                rect(
                    x = x,
                    y = y,
                    width = w,
                    height = h,
                    fill = "none",
                    stroke = "black",
                    stroke_width = "1"
                )
                (xmin, xmax) = if :xlim ∈ keys(axes.args)
                    axes[:xlim]
                else
                    xmin, xmax = 0, 0
                    for plt in axes.plots
                        xlim = extrema(plt.data[:, 1])
                        xlim[1] < xmin && (xmin = xlim[1])
                        xlim[2] > xmax && (xmax = xlim[2])
                    end
                    xmin, xmax
                end
                (ymin, ymax) = if :ylim ∈ keys(axes.args)
                    axes[:ylim]
                else
                    ymin, ymax = 0, 0
                    for plt in axes.plots
                        ylim = extrema(plt.data[:, 2])
                        ylim[1] < ymin && (ymin = ylim[1])
                        ylim[2] > ymax && (ymax = ylim[2])
                    end
                    ymin, ymax
                end
                defs() do
                    clipPath(id = "clipnr$nr") do
                        rect(x = x, y = y, width = w, height = h)
                    end
                end
                a = w / (xmax - xmin)
                b = x - a * xmin
                c = h / (ymin - ymax)
                d = y - c * ymax
                for plt in axes.plots
                    xx = a .* plt.data[:, 1] .+ b
                    yy = c .* plt.data[:, 2] .+ d
                    polyline(
                        clipPath = "url(#clipnr$nr)",
                        fill = "none",
                        stroke_width = "1",
                        stroke = "black",
                        points = mapreduce(
                            p -> "$(p[1]),$(p[2]) ",
                            *,
                            zip(xx, yy)
                        )
                    )
                end
            end
        end
    end
end
