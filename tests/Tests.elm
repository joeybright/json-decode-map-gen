module Tests exposing (..)

import Dict
import Elm
import Elm.ToString
import Expect
import Fuzz exposing (Fuzzer)
import JsonDecodeMapGen
import Test exposing (Test, describe, fuzz, test)


fuzzExpression : Fuzzer Elm.Expression
fuzzExpression =
    Fuzz.map Elm.string Fuzz.string


suite : Test
suite =
    describe "Tests for the `JsonDecodeMapGen` module"
        [ fuzz (Fuzz.list fuzzExpression)
            "Generates a declaration when there is more than 0 and less than 8 expressions passed to the `generate` function"
            (\expressionList ->
                let
                    listLength =
                        List.length expressionList

                    mapDeclarationName =
                        "jsonDecodeMap" ++ String.fromInt listLength

                    expectGeneratedDeclaration true false =
                        if listLength > 8 && listLength > 0 then
                            true

                        else
                            false
                in
                Expect.all
                    [ Dict.toList
                        >> List.map Tuple.first
                        >> Expect.equal
                            (expectGeneratedDeclaration [ mapDeclarationName ] [])
                    , Dict.get mapDeclarationName
                        >> Maybe.map Elm.ToString.declaration
                        >> Maybe.map .imports
                        >> Expect.equal
                            (expectGeneratedDeclaration (Just "import Json.Decode") Nothing)
                    , Dict.get mapDeclarationName
                        >> Maybe.map Elm.ToString.declaration
                        >> Maybe.map .docs
                        >> Expect.equal
                            (expectGeneratedDeclaration (Just "") Nothing)
                    ]
                    (JsonDecodeMapGen.generate expressionList |> .declaration)
            )
        , test "When 9 arguments are passed to the `generate` function, creates the correct declaration"
            (\_ ->
                JsonDecodeMapGen.generate (List.repeat 9 (Elm.string ""))
                    |> .declaration
                    |> Dict.get "jsonDecodeMap9"
                    |> Maybe.map Elm.ToString.declaration
                    |> Maybe.map .body
                    |> Expect.equal (Just """jsonDecodeMap9 :
    (arg1
    -> arg2
    -> arg3
    -> arg4
    -> arg5
    -> arg6
    -> arg7
    -> arg8
    -> arg9
    -> result)
    -> Json.Decode.Decoder arg1
    -> Json.Decode.Decoder arg2
    -> Json.Decode.Decoder arg3
    -> Json.Decode.Decoder arg4
    -> Json.Decode.Decoder arg5
    -> Json.Decode.Decoder arg6
    -> Json.Decode.Decoder arg7
    -> Json.Decode.Decoder arg8
    -> Json.Decode.Decoder arg9
    -> Json.Decode.Decoder result
jsonDecodeMap9 func arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 arg9 =
    Json.Decode.map2
        (\\a b -> b a)
        arg9
        (Json.Decode.map2
            (\\a b -> b a)
            arg8
            (Json.Decode.map2
                (\\a b -> b a)
                arg7
                (Json.Decode.map2
                    (\\a b -> b a)
                    arg6
                    (Json.Decode.map2
                        (\\a b -> b a)
                        arg5
                        (Json.Decode.map2
                            (\\a b -> b a)
                            arg4
                            (Json.Decode.map2
                                (\\a b -> b a)
                                arg3
                                (Json.Decode.map2
                                    (\\a b -> b a)
                                    arg2
                                    (Json.Decode.map2
                                        (\\a b -> b a)
                                        arg1
                                        (Json.Decode.succeed func)
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )


""")
            )
        , fuzz (Fuzz.intRange 0 100)
            "The returned expression always imports the `Json.Decode` module"
            (\int ->
                JsonDecodeMapGen.generate (List.repeat int (Elm.string ""))
                    |> (\res -> res.call (Elm.string ""))
                    |> Elm.ToString.expression
                    |> .imports
                    |> Expect.equal "import Json.Decode"
            )
        ]
