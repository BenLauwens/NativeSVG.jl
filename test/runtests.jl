using Test
using NativeSVG

dr = Drawing(width="300", height="200") do
  rect(width="100%", height="100%", fill="red")
  circle(cx="150", cy="100", r="80", fill="green")
  text(x="150", y="125", font_size="60", text_anchor="middle", fill="white") do
    str("Drawing")
  end
end
display(dr)

dr = Drawing(width="200", height="250") do
    rect(x="10", y="10", width="30", height="30", stroke="black", fill="transparent", stroke_width="5")
    rect(x="60", y="10", rx="10", ry="10", width="30", height="30", stroke="black", fill="transparent", stroke_width="5")
    circle(cx="25", cy="75", r="20", stroke="red", fill="transparent", stroke_width="5")
    ellipse(cx="75", cy="75", rx="20", ry="5", stroke="red", fill="transparent", stroke_width="5")
    line(x1="10", x2="50", y1="110", y2="150", stroke="orange", stroke_width="5")
    polyline(points="60 110 65 120 70 115 75 130 80 125 85 140 90 135 95 150 100 145",
      stroke="orange", fill="transparent", stroke_width="5")
    polygon(points="50 160 55 180 70 180 60 190 65 205 50 195 35 205 40 190 30 180 45 180",
      stroke="green", fill="transparent", stroke_width="5")
    path(d="M20,230 Q40,205 50,230 T90,230", fill="none", stroke="blue", stroke_width="5")
end
display(dr)

dr = Drawing(width="100", height="100") do
  path(d="M 10 10 H 90 V 90 H 10 L 10 10")
  circle(cx="10", cy="10", r="2", fill="red")
  circle(cx="90", cy="90", r="2", fill="red")
  circle(cx="90", cy="10", r="2", fill="red")
  circle(cx="10", cy="90", r="2", fill="red")
end
display(dr)

dr = Drawing(width="190", height="160") do
  path(d="M 10 10 C 20 20, 40 20, 50 10", stroke="gray", fill="transparent")
  path(d="M 70 10 C 70 20, 120 20, 120 10", stroke="gray", fill="transparent")
  path(d="M 130 10 C 120 20, 180 20, 170 10", stroke="gray", fill="transparent")
  path(d="M 10 60 C 20 80, 40 80, 50 60", stroke="gray", fill="transparent")
  path(d="M 70 60 C 70 80, 110 80, 110 60", stroke="gray", fill="transparent")
  path(d="M 130 60 C 120 80, 180 80, 170 60", stroke="gray", fill="transparent")
  path(d="M 10 110 C 20 140, 40 140, 50 110", stroke="gray", fill="transparent")
  path(d="M 70 110 C 70 140, 110 140, 110 110", stroke="gray", fill="transparent")
  path(d="M 130 110 C 120 140, 180 140, 170 110", stroke="gray", fill="transparent")
end
display(dr)

dr = Drawing(width="200", height="200") do
  defs() do
    style(type="text/css") do
      cdata("""#MyRect {
                  stroke: black;
                  fill: red;
               }""")
    end
  end
  rect(x="10", height="180", y="10", width="180", id="MyRect")
end
display(dr)

dr = Drawing(width="120", height="120") do
  defs() do
    radialGradient(id="Gradient", cx="0.5", cy="0.5", r="0.5", fx="0.25", fy="0.25") do
      stop(offset="0%", stop_color="red")
      stop(offset="100%", stop_color="blue")
    end
  end
  rect(x="10", y="10", rx="15", ry="15", width="100", height="100",
        fill="url(#Gradient)", stroke="black", stroke_width="2")
  circle(cx="60", cy="60", r="50", fill="transparent", stroke="white", stroke_width="2")
  circle(cx="35", cy="35", r="2", fill="white", stroke="white")
  circle(cx="60", cy="60", r="2", fill="white", stroke="white")
  text(x="38", y="40", fill="white", font_family="sans-serif", font_size="10pt") do
    str("(fx,fy)")
  end
  text(x="63", y="63", fill="white", font_family="sans-serif", font_size="10pt") do
    str("(cx,cy)")
  end
end
display(dr)

dr = Drawing(width="200", height="200") do
  defs() do
    linearGradient(id="Gradient1") do
      stop(offset="5%", stop_color="white")
      stop(offset="95%", stop_color="blue")
    end
    linearGradient(id="Gradient2", x1="0", x2="0", y1="0", y2="1") do
      stop(offset="5%", stop_color="red")
      stop(offset="95%", stop_color="orange")
    end
    pattern(id="Pattern", x="0", y="0", width=".25", height=".25") do
      rect(x="0", y="0", width="50", height="50", fill="skyblue")
      rect(x="0", y="0", width="25", height="25", fill="url(#Gradient2)")
      circle(cx="25", cy="25", r="20", fill="url(#Gradient1)", fill_opacity="0.5")
    end
  end
  rect(fill="url(#Pattern)", stroke="black", width="200", height="200")
end
display(dr)

dr = Drawing() do
  text(x="10", y="10", fill="gray") do
    str("This is ")
    tspan(font_weight="bold", fill="red") do
      str("bold and red")
    end
  end
end
display(dr)

dr = Drawing() do
  path(id="my_path", d="M 20,20 C 80,60 100,40 120,20", fill="transparent")
  text(fill="red") do
    textPath(xmlns!xlink="http://www.w3.org/1999/xlink", xlink!href="#my_path") do
      str("A curve.")
    end
  end
end
display(dr)

t = Turtle()
forward(t, -200)
penup(t)
turn(t, -90)
forward(t, 200)
turn(t, 90)
pendown(t)
for c in (:black, :red, :orange, :yellow, :green, :blue, :indigo, :violet)
    pencolor(t, c)
    forward(t, 100)
    turn(t, 45)
end
display(Drawing(t))
