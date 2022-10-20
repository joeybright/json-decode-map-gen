module Generate exposing (main)

{-| -}

import Elm
import Gen.CodeGen.Generate as Generate
import JsonDecodeMapGen


main : Program {} () ()
main =
    Generate.run
        [ Elm.file [ "GeneratedForTesting" ]
            [ Elm.declaration "test"
                ((JsonDecodeMapGen.generate []).call
                    (Elm.string "")
                )
            ]
        ]
