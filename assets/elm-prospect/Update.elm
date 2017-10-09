module Update exposing (..)

import Commands exposing (getMaybeValue)
import Json.Encode as Encode
import Maps
import Maps.Geo
import Maps.Map as Map
import Maps.Marker as Marker
import Messages exposing (..)
import Model exposing (..)
import Navigation
import Project.Commands exposing (getProject, updateProject, updateProjectWithCallback)
import Project.Model exposing (..)
import RemoteData exposing (..)
import Routing exposing (Route(..), parse, toPath)
import Window


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        MapsMsg msg ->
            model.landMap
                |> Maps.update msg
                |> Tuple.mapFirst (\map -> { model | landMap = map })
                |> Tuple.mapSecond (Cmd.map MapsMsg)

        Resize size ->
            { model
                | windowSize = size
                , landMap = resizeMap model.landMap size
            }
                ! []

        ProjectResponse response ->
            setProject model response ! []

        UpdateProject projectId value ->
            model ! [ updateProject model.apiToken projectId value ]

        UrlChange location ->
            let
                currentRoute =
                    parse location
            in
                urlUpdate { model | route = currentRoute }

        NavigateTo route ->
            model ! [ Navigation.newUrl <| toPath route ]

        SetHouseColor1 color ->
            { model | houseColor1 = Just color } ! []

        SetHouseColor2 color ->
            { model | houseColor2 = Just color } ! []

        SetContribution contribution ->
            case String.toInt contribution of
                Ok intContribution ->
                    { model | contribution = Just intContribution } ! []

                Err _ ->
                    { model | contribution = Nothing } ! []

        SetNetIncome netIncome ->
            case String.toInt netIncome of
                Ok intNetIncome ->
                    { model | netIncome = Just intNetIncome } ! []

                Err _ ->
                    { model | netIncome = Nothing } ! []

        SetPhoneNumber phoneNumber ->
            { model | phoneNumber = Just phoneNumber } ! []

        ValidateDiscoverLand projectId value ->
            model ! [ updateProjectWithCallback model.apiToken projectId value ValidateDiscoverLandResponse ]

        ValidateDiscoverLandResponse response ->
            let
                newModel =
                    setProject model response
            in
                case response of
                    Success project ->
                        update (NavigateTo (ProjectStepRoute project.id DiscoverHouse)) newModel

                    _ ->
                        newModel ! []

        ValidateDiscoverHouse projectId value ->
            model ! [ updateProjectWithCallback model.apiToken projectId value ValidateDiscoverHouseResponse ]

        ValidateDiscoverHouseResponse response ->
            let
                newModel =
                    setProject model response
            in
                case response of
                    Success project ->
                        update (NavigateTo (ProjectStepRoute project.id ConfigureHouse)) newModel

                    _ ->
                        newModel ! []

        ValidateConfigureHouse projectId ->
            let
                value =
                    (getMaybeValue "house_color_1" model.houseColor1 Encode.string)
                        ++ (getMaybeValue "house_color_2" model.houseColor2 Encode.string)
                        |> Encode.object
            in
                model ! [ updateProjectWithCallback model.apiToken projectId value ValidateConfigureHouseResponse ]

        ValidateConfigureHouseResponse response ->
            let
                newModelP =
                    setProject model response

                newModel =
                    { newModelP | houseColor1 = Nothing, houseColor2 = Nothing }
            in
                case response of
                    Success project ->
                        case stepState project ConfigureHouse of
                            Checked ->
                                update (NavigateTo (ProjectStepRoute project.id EvaluateFunding)) newModel

                            _ ->
                                newModel ! []

                    _ ->
                        newModel ! []

        ValidateEvaluateFunding projectId ->
            let
                value =
                    (getMaybeValue "contribution" model.contribution Encode.int)
                        ++ (getMaybeValue "net_income" model.netIncome Encode.int)
                        |> Encode.object
            in
                model ! [ updateProjectWithCallback model.apiToken projectId value ValidateEvaluateFundingResponse ]

        ValidateEvaluateFundingResponse response ->
            let
                newModel =
                    setProject model response
            in
                case response of
                    Success project ->
                        case stepState project EvaluateFunding of
                            Checked ->
                                update (NavigateTo (ProjectStepRoute project.id PhoneCall)) newModel

                            _ ->
                                newModel ! []

                    _ ->
                        newModel ! []

        SubmitPhoneNumber projectId ->
            case model.phoneNumber of
                Nothing ->
                    model ! []

                Just phoneNumber ->
                    let
                        value =
                            (getMaybeValue "phone_number" model.phoneNumber Encode.string)
                                |> Encode.object
                    in
                        model ! [ updateProjectWithCallback model.apiToken projectId value SubmitPhoneNumberResponse ]

        SubmitPhoneNumberResponse response ->
            setProject model response ! []


landMapHeight : Window.Size -> Float
landMapHeight size =
    250


landMapWidth : Window.Size -> Float
landMapWidth size =
    size.width |> toFloat |> (\x -> min 490 (x - 65))


resizeMap : Maps.Model Msg -> Window.Size -> Maps.Model Msg
resizeMap map size =
    map
        |> Maps.updateMap (Map.setWidth <| landMapWidth <| size)
        |> Maps.updateMap (Map.setHeight <| landMapHeight <| size)


urlUpdate : Model -> ( Model, Cmd Msg )
urlUpdate model =
    case model.route of
        ProjectRoute projectId ->
            ( model, ensureProject model projectId )

        ProjectStepRoute projectId projectStep ->
            ( model, ensureProject model projectId )

        _ ->
            ( model, Cmd.none )


ensureProject : Model -> ProjectId -> Cmd Msg
ensureProject model projectId =
    if projectIsLoaded model projectId then
        Cmd.none
    else
        getProject model.apiToken projectId


projectIsLoaded : Model -> ProjectId -> Bool
projectIsLoaded model projectId =
    case model.project of
        Success project ->
            if project.id == projectId then
                True
            else
                False

        _ ->
            False


setProject : Model -> WebData Project -> Model
setProject model response =
    case response of
        Success project ->
            let
                latLng =
                    Maps.Geo.latLng project.ad.land.lat project.ad.land.lng

                landMap =
                    Maps.defaultModel
                        |> Maps.updateMap (Map.viewBounds <| Maps.Geo.centeredBounds 12 latLng)
                        |> Maps.updateMarkers (\_ -> [ Marker.create latLng ])
            in
                { model
                    | project = response
                    , landMap = resizeMap landMap model.windowSize
                    , netIncome = project.net_income
                    , contribution = Just project.contribution
                    , phoneNumber = project.phone_number
                }

        _ ->
            { model | project = response }
