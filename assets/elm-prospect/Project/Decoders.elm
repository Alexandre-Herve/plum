module Project.Decoders exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import Model exposing (..)
import Ad.Decoders exposing (adDecoder)
import Project.Model exposing (Project, ProjectStepStatus, ProjectStep, stringToProjectStep)


projectStepDecoder : Decoder ProjectStep
projectStepDecoder =
    let
        convert : String -> Decoder ProjectStep
        convert raw =
            case stringToProjectStep raw of
                Just step ->
                    succeed step

                Nothing ->
                    fail "Not found"
    in
        string |> andThen convert


projectStepStatusDecoder : Decoder ProjectStepStatus
projectStepStatusDecoder =
    succeed
        ProjectStepStatus
        |: (field "name" projectStepDecoder)
        |: (field "checked" bool)


projectDecoder : Decoder Project
projectDecoder =
    at [ "data" ] <|
        succeed
            Project
            |: (field "id" int)
            |: (field "ad" adDecoder)
            |: (field "steps" (list projectStepStatusDecoder))
