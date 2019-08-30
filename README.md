# NativeSVG

A pure Julia SVG generator. Using `do` blocks and keyword arguments, a one-to-one mapping is implemented between the SVG xml standard and Julia.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"/>
    <g stroke-linecap="butt" stroke-miterlimit="4" stroke-width="3.0703125">
        <circle cx="20" cy="20" r="16" stroke="#cb3c33" fill="#d5635c"/>
        <circle cx="40" cy="56" r="16" stroke="#389826" fill="#60ad51"/>
        <circle cx="60" cy="20" r="16" stroke="#9558b2" fill="#aa79c1"/>
    </g>
</svg>
```

```julia
Drawing() do
    g(stroke_linecap="butt", stroke_miterlimit="4", stroke_width="3.0703125") do
        circle(cx="20", cy="20", r="16", stroke="#cb3c33", fill="#d5635c")
        circle(cx="40", cy="56", r="16", stroke="#389826", fill="#60ad51")
        circle(cx="60", cy="20", r="16", stroke="#9558b2", fill="#aa79c1")
    end
end
```

## Build Status & Coverage

TODO

## Installation

NativeSVG.jl has not yet been registered but can be installed by running

```julia
julia> using Pkg

julia> pkg"add https://github.com/BenLauwens/NativeSVG.jl.git"

```

## Documentation

TODO

## License

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)

## Authors

* Ben Lauwens, Royal Military Academy, Brussels, Belgium.

## Contributing

* To discuss problems or feature requests, file an issue. For bugs, please include as much information as possible, including operating system and julia version.
* To contribute, make a pull request. Contributions should include tests for any new features/bug fixes.

## Release Notes

* v0.1 (2019): Initial release

## Todo

* Documentation.
