module Messages exposing (..)

import Http
import Navigation
import Routing exposing (Route)
import RemoteData exposing (..)
import LandList.Model exposing (LandList)


type Msg
    = LandListResponse (WebData LandList)
    | UrlChange Navigation.Location
    | NavigateTo Route