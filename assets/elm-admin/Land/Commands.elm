module Land.Commands exposing (..)

import Commands exposing (..)
import DecodedTypes exposing (..)
import Dict
import Json.Decode
import Json.Encode exposing (..)
import Land.Model exposing (..)
import Ad.Model exposing (..)
import List as L
import Messages exposing (Msg(..))
import Model exposing (..)
import RemoteData exposing (..)
import Task


getLandWithCallback : ApiToken -> Int -> (Int -> WebData DecodedLand -> Msg) -> Cmd Msg
getLandWithCallback apiToken landId callback =
    let
        url =
            "/api/lands/" ++ (toString landId)
    in
        authGet apiToken url landShowResponseDecoder
            |> RemoteData.sendRequest
            |> Cmd.map (callback landId)


getLand : ApiToken -> Int -> Cmd Msg
getLand apiToken landId =
    getLandWithCallback apiToken landId LandResponse


getLandList : Model -> Cmd Msg
getLandList model =
    let
        url =
            String.concat [ "/api/lands" ]
    in
        authGet model.apiToken url landListResponseDecoder
            |> RemoteData.sendRequest
            |> Cmd.map LandListResponse


createLandWithCallback : ApiToken -> Value -> (WebData DecodedLand -> Msg) -> Cmd Msg
createLandWithCallback apiToken landFormValue callback =
    let
        url =
            "/api/lands"

        land_data =
            object [ ( "land", landFormValue ) ]
    in
        authPost apiToken url landShowResponseDecoder land_data
            |> RemoteData.sendRequest
            |> Cmd.map callback



{--
  - successAds : WebData Ad -> Maybe Ad
  - successAds adWD =
  -     case adWD of
  -         Success ad ->
  -             Just ad
  -
  -         _ ->
  -             Nothing
  --}


createLand : ApiToken -> Value -> Cmd Msg
createLand apiToken landFormValue =
    createLandWithCallback apiToken landFormValue LandCreateResponse


ensureLandWithCallback : Int -> Model -> (Int -> WebData DecodedLand -> Msg) -> Cmd Msg
ensureLandWithCallback landId model callback =
    {--
  -     let
  -         makeDecodedLand =
  -             \land ->
  -                 (DecodedLand
  -                     land
  -                     (land.ads
  -                         -- Error prone, ads could be out of sync
  -                         -- Better check if land is loaded along with its ads
  -                         |> L.filterMap (\adId -> model.ads |> Dict.get adId)
  -                         |> L.filterMap successAds
  -                     )
  -                 )
  -                     |> RemoteData.succeed
  -     in
  -         case model.lands |> Dict.get landId of
  -             Just (Success land) ->
  -                 Task.succeed (callback landId (makeDecodedLand land)) |> Task.perform identity
  -
  -             _ ->
  --}
    getLandWithCallback model.apiToken landId callback


ensureLand : Int -> Model -> Cmd Msg
ensureLand landId model =
    ensureLandWithCallback landId model LandResponse
