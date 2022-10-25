module Tests exposing (..)

import Dict
import Elm
import Expect
import Fuzz exposing (Fuzzer)
import JsonDecodeMapGen
import Test exposing (Test, fuzz)


fuzzExpression : Fuzzer Elm.Expression
fuzzExpression =
    Fuzz.map Elm.string Fuzz.string


suite : Test
suite =
    fuzz (Fuzz.list fuzzExpression)
        "Generates a declaration when there is more than 0 and less than 8 expressions passed to the `generate` function"
        (\expressionList ->
            let
                listLength =
                    List.length expressionList

                mapDeclarationName =
                    if listLength > 8 && listLength > 0 then
                        [ "jsonDecodeMap" ++ String.fromInt listLength ]

                    else
                        []
            in
            JsonDecodeMapGen.generate expressionList
                |> .declaration
                |> Dict.toList
                |> List.map Tuple.first
                |> Expect.equal mapDeclarationName
        )
