# json-decode-map-gen

A utility for `elm-codegen` for generating custom`Json.Decode.map` functions beyond what the package provides.

Let's say you're writing [...] 

```elm
import JsonDecodeMapGen

jsonDecodeMap : JsonDecodeMapGen.Generated
jsonDecodeMap = 
    JsonDecodeMapGen.genereate 
        [ Gen.Json.Decode.string
        , Gen.Json.Decode.int
        , Gen.Json.Decode.string
        ]

generateDecoder : Elm.Declaration
generateDecoder =
    Elm.declaration "decodeRecord"
        (jsonDecodeMap.call 
            (Elm.fn3 ()
            )
        )
```

The code above would generate the following example when run with `elm-codegen`:

```elm
decodeRecord : Json.Decode.Decoder { name: String, age: Int, username: String }
decodeRecord =
    Json.Decode.map3 (\arg1 arg2 arg3 ->
        { name = arg1
        , age = arg2
        , username = arg3
        }
        (Json.Decode.string)
        (Json.Decode.int)
        (Json.Decode.string)
    )
```