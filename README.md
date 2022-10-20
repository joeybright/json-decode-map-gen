# json-decode-map-gen

An package `elm-codegen` for generating custom `Json.Decode.map` functions beyond what the `elm/json` package provides.

## When to Use

This library is most helpful for two cases:

1. **You're trying to generate decoders for values at runtime with an unknown amount of arguments required to construct them.** For example, if you're trying to generate a decoder for some JSON passed to elm-codegen via flags, it's impossible to know what the shape of that JSON is when your code is being generated. This module can help by generating the right `map` function regardless of the shape of that JSON.
2. **The number of arguments to construct a value exceed 8.** As a result, you can't use the built-in `map` functions in the `elm/json` module (of which there are only 8). This module uses the built-in `map` functions when there are less than 8 arguments and generates its own `map` function when there are more than 8.

## Getting Started

After getting elm-codegen setup and this package installed, in your `codegen/Generate.elm` module, import the package. You can use the code below as a guide:

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

You can then run elm-codgen to generate the follow code in the `Example.elm` file:

```elm
decodeRecord : Json.Decode.Decoder { name: String }
decodeRecord =
    Json.Decode.map 
        (\name -> { name = name } )
    (Json.Decode.string)

```

Note that the example above does not check to see if a custom declaration has been returned by the `generate` function. It's important to check for and properly put that function somewhere in your generated code!

## Examples

### Generating a custom map function

If you're looking to generate a custom map function for something you're [...]
