module JsonDecodeMapGen exposing
    ( Generated
    , generate
    )

{-|

@docs Generated

@docs generate

-}

import Dict exposing (Dict)
import Elm
import Elm.Annotation as Type
import Gen.Json.Decode


{-| The generated type is returned by the `generate` function. If there is no built-in `Json.Decode` function
in the `elm-lang/json` package, a declaration will be returned. This should be put somewhere in the generated
code!

The returned declaration field is a `Dict` to avoid duplicate declarations when calling `generate` recursively.
You can use `Dict.union` to combine different generated declarations to ensure no duplicates.

-}
type alias Generated =
    { call : Elm.Expression -> Elm.Expression
    , callFrom : List String -> Elm.Expression -> Elm.Expression
    , declaration : Dict String Elm.Declaration
    }


{-| Generates a custom `Json.Decode.mapX` function based on the number of expressions passed.

Unlike the `generate` function, this will _always_ build a custom `Json.Decode.mapX` function and provide the
newly generated `Json.Decode.mapX` declaration.

-}
generateCustom : List Elm.Expression -> Generated
generateCustom expressions =
    let
        listLength =
            List.length expressions

        functionName =
            "jsonDecodeMap" ++ String.fromInt listLength

        argumentName : Int -> String
        argumentName =
            String.fromInt >> (++) "arg"

        arguments : List String
        arguments =
            List.map argumentName (List.range 1 listLength)

        argTypes : List Type.Annotation
        argTypes =
            List.map Type.var arguments

        argsWithAnnotations : List ( String, Type.Annotation )
        argsWithAnnotations =
            List.map (\str -> ( str, Gen.Json.Decode.annotation_.decoder (Type.var str) )) arguments

        call list first =
            Elm.apply
                (Elm.value
                    { name = functionName
                    , annotation =
                        Just
                            (Type.function
                                (Type.function argTypes (Type.var "result")
                                    :: List.map Tuple.second argsWithAnnotations
                                )
                                (Gen.Json.Decode.annotation_.decoder (Type.var "result"))
                            )
                    , importFrom = list
                    }
                )
                (first :: expressions)
    in
    { call = call []
    , callFrom = call
    , declaration =
        Dict.insert functionName
            (Elm.declaration functionName
                (Elm.function
                    (( "func", Just (Type.function argTypes (Type.var "result")) )
                        :: List.map (Tuple.mapSecond Just) argsWithAnnotations
                    )
                    (\exp ->
                        case exp of
                            func :: rest ->
                                List.foldl
                                    (Gen.Json.Decode.call_.map2
                                        (Elm.fn2
                                            ( "a", Nothing )
                                            ( "b", Nothing )
                                            (\a b -> Elm.apply b [ a ])
                                        )
                                    )
                                    (Gen.Json.Decode.call_.succeed func)
                                    rest

                            _ ->
                                Elm.string "error"
                    )
                )
            )
            Dict.empty
    }


{-| Generate a `Json.Decode.mapX` function based on the number of expressions passed.

If there are 8 or less items in the passed list, this function will return a call to a native `Json.Decode.mapX`
function (X being the number of passed arguments). If there are more than 8 arguments, a custom `Json.Decode.mapX`
function will be returned along with its declaration.

    JsonDecodeMapGen.generate
        [ Elm.string ""
        ]

Someting else...

-}
generate : List Elm.Expression -> Generated
generate expressions =
    case expressions of
        [] ->
            { call = Gen.Json.Decode.succeed << identity
            , callFrom = \_ -> Gen.Json.Decode.succeed << identity
            , declaration = Dict.empty
            }

        item1 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map a item1
            , callFrom = \_ a -> Gen.Json.Decode.call_.map a item1
            , declaration = Dict.empty
            }

        item1 :: item2 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map2 a item1 item2
            , callFrom = \_ a -> Gen.Json.Decode.call_.map2 a item1 item2
            , declaration = Dict.empty
            }

        item1 :: item2 :: item3 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map3 a item1 item2 item3
            , callFrom = \_ a -> Gen.Json.Decode.call_.map3 a item1 item2 item3
            , declaration = Dict.empty
            }

        item1 :: item2 :: item3 :: item4 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map4 a item1 item2 item3 item4
            , callFrom = \_ a -> Gen.Json.Decode.call_.map4 a item1 item2 item3 item4
            , declaration = Dict.empty
            }

        item1 :: item2 :: item3 :: item4 :: item5 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map5 a item1 item2 item3 item4 item5
            , callFrom = \_ a -> Gen.Json.Decode.call_.map5 a item1 item2 item3 item4 item5
            , declaration = Dict.empty
            }

        item1 :: item2 :: item3 :: item4 :: item5 :: item6 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map6 a item1 item2 item3 item4 item5 item6
            , callFrom = \_ a -> Gen.Json.Decode.call_.map6 a item1 item2 item3 item4 item5 item6
            , declaration = Dict.empty
            }

        item1 :: item2 :: item3 :: item4 :: item5 :: item6 :: item7 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map7 a item1 item2 item3 item4 item5 item6 item7
            , callFrom = \_ a -> Gen.Json.Decode.call_.map7 a item1 item2 item3 item4 item5 item6 item7
            , declaration = Dict.empty
            }

        item1 :: item2 :: item3 :: item4 :: item5 :: item6 :: item7 :: item8 :: [] ->
            { call = \a -> Gen.Json.Decode.call_.map8 a item1 item2 item3 item4 item5 item6 item7 item8
            , callFrom = \_ a -> Gen.Json.Decode.call_.map8 a item1 item2 item3 item4 item5 item6 item7 item8
            , declaration = Dict.empty
            }

        items ->
            generateCustom items
