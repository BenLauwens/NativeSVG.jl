mutable struct Turtle
    commands :: Array{Tuple, 1}
    Turtle(cmds=Tuple[]) = new(cmds)
end

for command in COMMANDS
    eval(quote
             function $command(t::Turtle, v::Union{Number, Symbol}=:nothing)
                 push!(t.commands, (Symbol($command), v))
             end
         end)
end

function Drawing(t::Turtle, width::Number=640, height::Number=480)
    Drawing(width=width, height=height) do
        xpos = width / 2
        ypos = height / 2
        pendown = true
        orientation = 0.0
        pencolor = :black
        for (cmd, arg) in t.commands
            if cmd == :forward
                xold, yold = xpos, ypos
                xpos += cos(orientation) * arg
                ypos += sin(orientation) * arg
                pendown && line(x1=xold, x2=xpos, y1=yold, y2=ypos, stroke=pencolor)
            elseif cmd == :turn
                orientation += mod2pi(deg2rad(arg))
            elseif cmd == :penup
                pendown = false
            elseif cmd == :pendown
                pendown = true
            elseif cmd == :pencolor
                pencolor = arg
            end
        end
    end
end
