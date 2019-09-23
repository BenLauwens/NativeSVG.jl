abstract type PlotObject end

abstract type Axes <: PlotObject end

abstract type Plot <: PlotObject end

const FIGUREARGS = (:width, :height, :subplot, :currentaxes)

struct Figure
    axes::Dict{UInt8,Axes}
    args::Dict{Symbol,Any}
    function Figure(; kwargs...)
        fig = new(Dict{UInt8,Axes}(), Dict{Symbol,Any}())
        for (key, value) in kwargs
            key ∈ FIGUREARGS && (fig[key] = value)
        end
        get!(fig.args, :width, 604.72440945)
        get!(fig.args, :height, 427.60473067)
        get!(fig.args, :currentaxes, 1)
        get!(fig.args, :subplot, (1, 1))
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

function savefig(filename::AbstractString, fig::Figure = gcf())
    write(filename, Drawing(fig))
end

function positionaxes(fig::Figure = gcf())
    xdim, ydim = fig[:subplot]
    ca = fig[:currentaxes]
    w = 1 / xdim
    h = 1 / ydim
    x, y = divrem(ca - 1, ydim)
    x * w, y * h, w, h
end

const CARTESIANARGS = (:hold, :xlim, :ylim, :xscale, :yscale, :position, :title, :xlabel, :ylabel, :legend)

struct Cartesian <: Axes
    plots::Vector{Plot}
    args::Dict{Symbol,Any}
    function Cartesian(; kwargs...)
        axes = new(Plot[], Dict{Symbol,Any}())
        for (key, value) in kwargs
            key ∈ CARTESIANARGS && (axes[key] = value)
        end
        get!(axes.args, :hold, :false)
        get!(axes.args, :xscale, :linear)
        get!(axes.args, :yscale, :linear)
        get!(axes.args, :position, positionaxes())
        axes
    end
end

const LINEARGS = (:linetype,)
const LINETYPES = Dict(
    :solid => [0],
    :dotted => [1 2],
    :dashed => [4 2],
    :dashdotted => [4 2 1 2],
)

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
        get!(line.args, :linetype, :solid)
        line
    end
end

gcf() = CURRENTFIGURE[]

function figure(fig::Union{Figure,Nothing} = nothing; kwargs...)
    fig == nothing && (fig = Figure(; kwargs...))
    CURRENTFIGURE[] = fig
end

function gca(fig::Figure = gcf())
    ca = fig[:currentaxes]
    ca ∉ keys(fig.axes) && (fig.axes[ca] = Cartesian(; kwargs...))
    fig.axes[ca]
end

function hold(val::Bool, fig::Figure = gcf(); kwargs...)
    ca = fig[:currentaxes]
    ca ∉ keys(fig.axes) && (fig.axes[ca] = Cartesian(; kwargs...))
    axes = fig.axes[ca]
    axes[:hold] = val
    axes
end

function subplot(xdim::Int, ydim::Int, ca::Int, fig::Figure = gcf())
    (xdim, ydim) != fig[:subplot] && empty!(fig.axes)
    fig[:currentaxes] = ca
    fig[:subplot] = (xdim, ydim)
    fig
end

function title(txt::String, fig::Figure = gcf(); kwargs...)
    ca = fig[:currentaxes]
    ca ∉ keys(fig.axes) && (fig.axes[ca] = Cartesian(; kwargs...))
    axes = fig.axes[ca]
    axes[:title] = txt
    axes
end

function xlabel(txt::String, fig::Figure = gcf(); kwargs...)
    ca = fig[:currentaxes]
    ca ∉ keys(fig.axes) && (fig.axes[ca] = Cartesian(; kwargs...))
    axes = fig.axes[ca]
    axes[:xlabel] = txt
    axes
end

function ylabel(txt::String, fig::Figure = gcf(); kwargs...)
    ca = fig[:currentaxes]
    ca ∉ keys(fig.axes) && (fig.axes[ca] = Cartesian(; kwargs...))
    axes = fig.axes[ca]
    axes[:ylabel] = txt
    axes
end

function legend(legs::Vector{S}, fig::Figure = gcf(); kwargs...) where S<:AbstractString
    ca = fig[:currentaxes]
    ca ∉ keys(fig.axes) && (fig.axes[ca] = Cartesian(; kwargs...))
    axes = fig.axes[ca]
    axes[:legend] = legs
    axes
end

function plot(x::AbstractVector, y::AbstractVector, fig::Figure = gcf(); kwargs...)
    ca = fig[:currentaxes]
    ! (ca ∈ keys(fig.axes) && fig.axes[ca][:hold]) && (fig.axes[ca] = Cartesian(; kwargs...))
    axes = fig.axes[ca]
    line = Line(x, y; kwargs...)
    push!(axes.plots, line)
    line
end

const COLORS = (
    "rgb(0%, 44.7%, 74.1%)",
    "rgb(85%, 32.5%, 9.8%)",
    "rgb(92.9%, 69.4%, 12.5%)",
    "rgb(49.4%, 18.4%, 55.6%)",
    "rgb(46.6%, 67.4%, 18.8%)",
    "rgb(30.1%, 74.5%, 93.3%)",
    "rgb(63.5%, 7.8%, 18.4%)"
)

function Drawing(fig::Figure)
    width = fig[:width]
    height = fig[:height]
    Drawing(
        width = width,
        height = height,
        xmlns!xlink = "http://www.w3.org/1999/xlink",
    ) do
        defs() do
            clipPath(id = "clipwindow") do
                rect(x = 0, y = 0, width = "100%", height = "100%")
            end
        end
        rect(x = 0, y = 0, width = "100%", height = "100%", fill = "white")
        g(clip_path = "url(#clipwindow)") do
            for axes in values(fig.axes)
                draw(axes, fig)
            end
        end
    end
end

function adjustlimits(amin::Number, amax::Number)
    a = log10(amax - amin)
    quotient, remainder = divrem(a, 1)
    remainder *= remainder
    exponent = floor(quotient)
    quotient - exponent > 0.5 && (exponent += 1)
    remainder < 0.5 && (exponent -= 1)
    scale = 10^(-exponent)
    floor(scale * amin) / scale, ceil(scale * amax) / scale
end

function tick(amin::Number, amax::Number)
    exponent = log10(amax - amin)
    intpart = div(exponent, 1)
    factor = 10^(exponent - intpart)
    tickunit = if factor > 5; 2
        elseif factor > 2.5; 1
        elseif factor > 1; 0.5
        elseif factor > 0.5; 0.2
        elseif factor > 0.25; 0.1
        else; 0.05
    end
    tickunit * 10^intpart
end

function draw(axes::Cartesian, fig::Figure)
    width = fig[:width]
    height = fig[:height]
    pos = axes[:position]
    x = pos[1] * width
    y = pos[2] * height
    w = pos[3] * width
    h = pos[4] * height
    fontsize = 12
    :title ∈ keys(axes.args) && text(
        x = x + 0.125 * w + 0.4 * w,
        y = y + 0.04 * h,
        text_anchor = :middle,
        dominant_baseline = :middle,
        font_size = fontsize,
        vector_effect="non-scaling-stroke"
    ) do
        str(axes[:title])
    end
    :xlabel ∈ keys(axes.args) && text(
        x = x + 0.125 * w + 0.4 * w,
        y = y + h - 0.02 * h,
        text_anchor = :middle,
        dominant_baseline = :middle,
        font_size = fontsize,
        font_style = :italic,
        vector_effect="non-scaling-stroke"
    ) do
        str(axes[:xlabel])
    end
    :ylabel ∈ keys(axes.args) && text(
        x = x + 0.02 * w,
        y = y + 0.075 * h + 0.4 * h,
        text_anchor = :middle,
        dominant_baseline = :middle,
        font_size = fontsize,
        font_style = :italic,
        rotate = -90,
        vector_effect="non-scaling-stroke"
    ) do
        str(axes[:ylabel])
    end
    (xmin, xmax) = if :xlim ∈ keys(axes.args)
        axes[:xlim]
    else
        xmin, xmax = 0, 0
        for plt in axes.plots
            xlim = extrema(plt.data[:, 1])
            xlim[1] < xmin && (xmin = xlim[1])
            xlim[2] > xmax && (xmax = xlim[2])
        end
        xmin, xmax = adjustlimits(xmin, xmax)
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
        ymin, ymax = adjustlimits(ymin, ymax)
    end
    a = 0.8 * w / (xmax - xmin)
    b = 0.125 * w + x - a * xmin
    c = 0.8 * h / (ymin - ymax)
    d = 0.075 * h + y - c * ymax
    xtick = tick(xmin, xmax) / 5
    tmp = xmin / xtick
    intpart = div(tmp, 1)
    i = intpart == tmp ? tmp : floor(intpart) + 1
    xi = i * xtick
    while xi <= xmax
        color, len = if rem(i, 5) == 0
            text(x = a * xi + b,
                y = c * ymin + d + 0.02 * h,
                text_anchor = :middle,
                dominant_baseline = :middle,
                font_size = fontsize,
                vector_effect="non-scaling-stroke"
            ) do
                str(string(xi == div(xi, 1) ? Int(xi) : xi))
            end
            :lightgrey, 0.02 * h
        else
            :whitesmoke, 0.01 * h
        end
        line(x1 = a * xi + b, y1 = c * ymin + d, x2 = a * xi + b, y2 = c * ymax + d, stroke = color)
        line(x1 = a * xi + b, y1 = c * ymin + d, x2 = a * xi + b, y2 = c * ymin + d - len, stroke = :black)
        line(x1 = a * xi + b, y1 = c * ymax + d, x2 = a * xi + b, y2 = c * ymax + d + len, stroke = :black)
        i += 1
        xi = i * xtick
    end
    ytick = tick(ymin, ymax) / 5
    tmp = ymin / ytick
    intpart = div(tmp, 1)
    i = intpart == tmp ? tmp : floor(intpart) + 1
    yi = i * ytick
    while yi <= ymax
        color, len = if rem(i, 5) == 0
            text(x = a * xmin + b - 0.02 * w,
                y = c * yi + d,
                text_anchor = :end,
                dominant_baseline = :middle,
                font_size = fontsize,
                vector_effect="non-scaling-stroke"
            ) do
                str(string(yi == div(yi, 1) ? Int(yi) : yi))
            end
            :lightgrey, 0.02 * h
        else
            :whitesmoke, 0.01 * h
        end
        line(x1 = a * xmin + b, y1 = c * yi + d, x2 = a * xmax + b, y2 = c * yi + d, stroke = color, vector_effect="non-scaling-stroke")
        line(x1 = a * xmin + b, y1 = c * yi + d, x2 = a * xmin + b + len, y2 = c * yi + d, stroke = :black, vector_effect="non-scaling-stroke")
        line(x1 = a * xmax + b, y1 = c * yi + d, x2 = a * xmax + b - len, y2 = c * yi + d, stroke = :black, vector_effect="non-scaling-stroke")
        i += 1
        yi = i * ytick
    end
        defs() do
            clipPath(id = "clipplot") do
                rect(x = 0, y = 0, width = "100%", height = "100%")
            end
        end
        for (i, plt) in enumerate(axes.plots)
            xx = a .* plt.data[:, 1] .+ b
            yy = c .* plt.data[:, 2] .+ d
            plt[:linetype] != :none &&
                polyline(
                    clipPath = "url(#clipplot)",
                    fill = "none",
                    stroke = COLORS[(i - 1) % 7 + 1],
                    stroke_dasharray = mapreduce(
                        e -> "$e ",
                        *,
                        LINETYPES[plt[:linetype]]
                    ),
                    points = mapreduce(
                        p -> "$(p[1]),$(p[2]) ",
                        *,
                        zip(xx, yy)
                    ),
                    vector_effect="non-scaling-stroke"
                )
        end
    rect(
        x = x + 0.125 * w,
        y = y + 0.075 * h,
        width = 0.8 * w,
        height = 0.8 * h,
        fill = "none",
        stroke = "black",
        vector_effect="non-scaling-stroke"
    )
end
