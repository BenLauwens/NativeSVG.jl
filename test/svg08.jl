using NativeSVG

dr = Drawing(width = "300px", height = "100px") do
    desc() do
        str("Example InitialCoords - SVG's initial coordinate system")
    end
    g(fill = "none", stroke = "black", stroke_width = "3") do
        line(x1 = "0", y1 = "1.5", x2 = "300", y2 = "1.5")
        line(x1 = "1.5", y1 = "0", x2 = "1.5", y2 = "100")
    end
    g(fill = "red", stroke = "none") do
        rect(x = "0", y = "0", width = "3", height = "3")
        rect(x = "297", y = "0", width = "3", height = "3")
        rect(x = "0", y = "97", width = "3", height = "3")
    end
    g(font_size = "14", font_family = "Verdana") do
        text(x = "10", y = "20") do
            str("(0,0)")
        end
        text(x = "240", y = "20") do
            str("(300,0)")
        end
        text(x = "10", y = "90") do
            str("(0,100)")
        end
    end
end
display(dr)

dr =
    Drawing(
        width = "300px",
        height = "200px",
        viewBox = "0 0 1500 1000",
        preserveAspectRatio = "none"
    ) do
        desc() do
            str("""Example ViewBox - uses the viewBox
                   attribute to automatically create an initial user coordinate
                   system which causes the graphic to scale to fit into the
                   SVG viewport no matter what size the SVG viewport is.""")
        end
    # This rectangle goes from (0,0) to (1500,1000) in user coordinate system.
    # Because of the viewBox attribute above,
    # the rectangle will end up filling the entire area
    # reserved for the SVG content.
        rect(
            x = "0",
            y = "0",
            width = "1500",
            height = "1000",
            fill = "yellow",
            stroke = "blue",
            stroke_width = "12"
        )
    # A large, red triangle
        path(fill = "red", d = "M 750,100 L 250,900 L 1250,900 z")
    # A text string that spans most of the SVG viewport
        text(x = "100", y = "600", font_size = "200", font_family = "Verdana") do
            str("Stretch to fit")
        end
    end
display(dr)
