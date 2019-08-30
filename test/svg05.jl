using NativeSVG

dr = Drawing(width="5cm", height="4cm") do
    desc() do
        str("Four separate rectangles")
    end
    rect(x="0.5cm", y="0.5cm", width="2cm", height="1cm")
    rect(x="0.5cm", y="2cm", width="1cm", height="1.5cm")
    rect(x="3cm", y="0.5cm", width="1.5cm", height="2cm")
    rect(x="3.5cm", y="3cm", width="1cm", height="0.5cm")

    #Show outline of viewport using 'rect' element
    rect(x=".01cm", y=".01cm", width="4.98cm", height="3.98cm",
        fill="none", stroke="blue", stroke_width=".02cm")
end
display(dr)

dr = Drawing(width="5cm", height="5cm") do
    desc() do
        str("Two groups, each of two rectangles")
    end
    g(id="group1", fill="red") do
        rect(x="1cm", y="1cm", width="1cm", height="1cm")
        rect(x="3cm", y="1cm", width="1cm", height="1cm")
    end
    g(id="group2", fill="blue") do
        rect(x="1cm", y="3cm", width="1cm", height="1cm")
        rect(x="3cm", y="3cm", width="1cm", height="1cm")
    end

    # Show outline of viewport using 'rect' element
    rect(x=".01cm", y=".01cm", width="4.98cm", height="4.98cm",
          fill="none", stroke="blue", stroke_width=".02cm")
end
display(dr)

dr = Drawing(xmlns!xlink="http://www.w3.org/1999/xlink",
             width="200", height="100", viewBox="0 0 200 100") do
    title() do
        str("Style inheritance and the use element")
    end
    desc() do
        str("""Two circles, one of which is a re-styled clone of the other.
               This file demonstrates one of the cases where
               the shadow-DOM style matching rules in SVG 2
               have a different effect than the SVG 1.1 style cloning rules.
               The original circle on the left
               should have blue fill
               and green stroke.
               In a conforming SVG 1.1 user agent,
               the re-used circle on the right
               should have orange fill and green stroke.
               In a conforming SVG 2 user agent,
               the re-used circle should have orange fill and purple stroke.
               In all cases,
               the stroke should be partially transparent
               and 20 units wide,
               relative to a total circle diameter of 100 units.""")
    end
    style(type="text/css") do
        str("""circle          { stroke-opacity: 0.7; }
               .special circle { stroke: green; }
               use             { stroke: purple;
                                 fill: orange; }""")
    end
    g(class="special", style="fill: blue") do
        circle(id="c", cy="50", cx="50", r="40", stroke_width="20")
    end
    use(xlink!href="#c", x="100")
end
