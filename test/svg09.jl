using NativeSVG

dr = Drawing(width="5cm", height="4cm", viewBox="0 0 500 400") do
    title() do
        str("Example cubic01- cubic Bézier commands in path data")
    end
    desc() do
      str("""Picture showing a simple example of path data
             using both a "C" and an "S" command,
             along with annotations showing the control points
             and end points""")
    end
    style(type="text/css") do
        cdata(""".Border { fill:none; stroke:blue; stroke-width:1 }
                 .Connect { fill:none; stroke:#888888; stroke-width:2 }
                 .SamplePath { fill:none; stroke:red; stroke-width:5 }
                 .EndPoint { fill:none; stroke:#888888; stroke-width:2 }
                 .CtlPoint { fill:#888888; stroke:none }
                 .AutoCtlPoint { fill:none; stroke:blue; stroke-width:4 }
                 .Label { font-size:22; font-family:Verdana }""")
    end
    rect(class="Border", x="1", y="1", width="498", height="398")
    polyline(class="Connect", points="100,200 100,100")
    polyline(class="Connect", points="250,100 250,200")
    polyline(class="Connect", points="250,200 250,300")
    polyline(class="Connect", points="400,300 400,200")
    path(class="SamplePath", d="M100,200 C100,100 250,100 250,200
                                S400,300 400,200")
    circle(class="EndPoint", cx="100", cy="200", r="10")
    circle(class="EndPoint", cx="250", cy="200", r="10")
    circle(class="EndPoint", cx="400", cy="200", r="10")
    circle(class="CtlPoint", cx="100", cy="100", r="10")
    circle(class="CtlPoint", cx="250", cy="100", r="10")
    circle(class="CtlPoint", cx="400", cy="300", r="10")
    circle(class="AutoCtlPoint", cx="250", cy="300", r="9")
    text(class="Label", x="25", y="70") do
        str("M100,200 C100,100 250,100 250,200")
    end
    text(class="Label", x="325", y="350",
         style="text-anchor:middle") do
        str("S400,300 400,200")
    end
end
display(dr)

dr = Drawing(width="12cm", height="6cm", viewBox="0 0 1200 600") do
    title() do
        str("Example quad01 - quadratic Bézier commands in path data")
    end
    desc() do
        str("""Picture showing a "Q" a "T" command,
               along with annotations showing the control points
               and end points""")
    end
    rect(x="1", y="1", width="1198", height="598",
         fill="none", stroke="blue", stroke_width="1")
    path(d="M200,300 Q400,50 600,300 T1000,300",
         fill="none", stroke="red", stroke_width="5")
    # End points
    g(fill="black") do
        circle(cx="200", cy="300", r="10")
        circle(cx="600", cy="300", r="10")
        circle(cx="1000", cy="300", r="10")
    end
    # Control points and lines from end points to control points
    g(fill="#888888") do
        circle(cx="400", cy="50", r="10")
        circle(cx="800", cy="550", r="10")
    end
    path(d="M200,300 L400,50 L600,300 L800,550 L1000,300",
         fill="none", stroke="#888888", stroke_width="2")
end
display(dr)

dr = Drawing(width="12cm", height="5.25cm", viewBox="0 0 1200 400") do
    title() do
        str("Example arcs01 - arc commands in path data")
    end
    desc() do
        str("""Picture of a pie chart with two pie wedges and
               a picture of a line with arc blips""")
    end
    rect(x="1", y="1", width="1198", height="398",
         fill="none", stroke="blue", stroke_width="1")

    path(d="M300,200 h-150 a150,150 0 1,0 150,-150 z",
         fill="red", stroke="blue", stroke_width="5")
    path(d="M275,175 v-150 a150,150 0 0,0 -150,150 z",
         fill="yellow", stroke="blue", stroke_width="5")

    path(d="""M600,350 l 50,-25
              a25,25 -30 0,1 50,-25 l 50,-25
              a25,50 -30 0,1 50,-25 l 50,-25
              a25,75 -30 0,1 50,-25 l 50,-25
              a25,100 -30 0,1 50,-25 l 50,-25""",
         fill="none", stroke="red", stroke_width="5")
end
