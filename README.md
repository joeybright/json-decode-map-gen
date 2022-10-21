# json-decode-map-gen

A utility for elm-codegen to generate custom `Json.Decode.map` functions beyond what the elm/json package provides.

## When to Use

This package is most helpful in two cases:

1. **You want to generate decoders for values that have an unknown amount of arguments required to construct them when you're running elm-codegen.** This is most helpful when trying to decode some JSON with an unknown amount of fields into a record, but can also be used when constructing large custom types from some data passed by elm-codegen during code generation.
2. **The number of arguments to construct a value exceed 8.** As a result, you can't use the built-in `map` functions in the `elm/json` module (of which there are only 8). This module uses the built-in `map` functions when there are less than 8 arguments and generates its own `map` function when there are more than 8.

If you don't need to generate code the the two above use-cases, I highly recommend _not_ using this package. You'll likely be able to solve your problem with using decoders from the `elm/json` package by running `elm-codegen install elm/json`.

The particular problems this package solves can also be solved by installing `NoRedInk/elm-json-decode-pipeline` with elm-codegen and using it to generate decoders. The benefit of this package over that solution is a slightly different result in the generated code (a call to a single `map{x}` function rather than a large pipeline) and no additional dependencies for your generated code other than `elm/json`. Use what you feel is best for your project!

## Quick Start

After getting elm-codegen setup and this package installed, in your `codegen/Generate.elm` module, copy and paste the following code:

```elm
import Elm
import Elm.Annotation as Type
import Gen.CodeGen.Generate as Generate
import JsonDecodeMapGen


jsonDecodeMap : JsonDecodeMapGen.Generated
jsonDecodeMap = 
    JsonDecodeMapGen.generate 
        [ Gen.Json.Decode.string
        ]


generatedDecoder : Elm.Declaration
generatedDecoder =
    Elm.declaration "decodeRecord"
        (jsonDecodeMap.call 
            (Elm.fn ("name", Type.string)
                (\name -> Elm.record [ ( "name", name ) ])
            )
        )


main : Program {} () ()
main =
    Generate.run
        [ Elm.file [ "Example" ]
            [ generatedDecoder
            ]
        ]
```

You can then run elm-codegen to generate the following code in the `Example.elm` file:

```elm
decodeRecord : Json.Decode.Decoder { name : String }
decodeRecord =
    Json.Decode.map (\name -> { name = name }) Json.Decode.string
```

You can expand on this example by adding more items to the list passed to the `generate` function, running elm-codegen, and observing the results!

Note that the example above does not check to see if a custom declaration has been returned by the `generate` function. It's important to check for the generated declaration and, if it exists, to put it somewhere in your generated code!