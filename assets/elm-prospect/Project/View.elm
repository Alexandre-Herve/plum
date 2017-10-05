module Project.View exposing (..)

import Ad.Model exposing (Ad)
import Ad.View as AdView
import Html exposing (..)
import Html.Attributes exposing (class, src, type_, name, value, id, checked)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Model exposing (..)
import Project.Model exposing (..)
import Routing exposing (toPath, Route(..))
import ViewHelpers exposing (..)
import RemoteData exposing (..)
import Json.Encode


projectPageView : Model -> Html Msg
projectPageView model =
    case model.project of
        Failure err ->
            failureView err |> inLayout

        NotAsked ->
            notAskedView |> inLayout

        Loading ->
            loadingView |> inLayout

        Success project ->
            projectView model project |> inLayout


projectView : Model -> Project -> Html Msg
projectView model project =
    div []
        [ adHeader project.ad
        , photo "maison_21.png"
        , div [ class "mt-3 mb-5" ]
            [ ul [ class "list-group" ]
                (List.map (\dStep -> stepIndexView dStep.step model project dStep.label) displaySteps)
            ]
        ]


projectStepPageView : ProjectStep -> Model -> Html Msg
projectStepPageView projectStep model =
    case model.project of
        Failure err ->
            failureView err |> inLayout

        NotAsked ->
            notAskedView |> inLayout

        Loading ->
            loadingView |> inLayout

        Success project ->
            case List.filter (\dStep -> dStep.step == projectStep) displaySteps of
                dStep :: _ ->
                    dStep.view model project dStep.label |> inLayout

                _ ->
                    text "Erreur" |> inLayout


type alias DisplayStep =
    { step : ProjectStep
    , view : Model -> Project -> String -> Html Msg
    , label : String
    }


displaySteps : List DisplayStep
displaySteps =
    [ { step = DiscoverLand, view = discoverLandView, label = "Découvrir le terrain" }
    , { step = DiscoverHouse, view = discoverHouseView, label = "Découvrir la maison" }
    , { step = ConfigureHouse, view = configureHouseView, label = "Mon choix de couleurs" }
    , { step = EvaluateFunding, view = evaluateFundingView, label = "Ma finançabilité" }
    , { step = PhoneCall, view = phoneCallView, label = "Premier contact" }
    , { step = Quotation, view = quotationView, label = "Mon devis" }
    , { step = Funding, view = fundingView, label = "Mon financement" }
    , { step = VisitLand, view = visitLandView, label = "Visite du terrain" }
    , { step = Contract, view = contractView, label = "Signature du contrat" }
    , { step = Permit, view = permitView, label = "Permis de construire" }
    , { step = Building, view = buildingView, label = "Construction" }
    , { step = Keys, view = keysView, label = "Réception" }
    , { step = AfterSales, view = afterSalesView, label = "Après-vente" }
    ]


adHeader : Ad -> Html Msg
adHeader ad =
    div [ class "mt-3 p-3 light-bordered text-center" ]
        [ h4 [ class "font-black h4-responsive default-color-text" ] [ text "Mon espace" ]
        , p [ class "lead mb-0" ] [ AdView.shortView ad ]
        ]


checkedIcon : ProjectStepStatus -> Html Msg
checkedIcon state =
    let
        checkedIcon =
            span [ class "fa-stack mr-2" ]
                [ i [ class "fa fa-circle fa-stack-2x yellow-flash-text black-bordered-icon" ] []
                , i [ class "fa fa-check fa-stack-1x" ] []
                ]

        currentIcon =
            span [ class "fa-stack mr-2" ]
                [ i [ class "fa fa-circle fa-stack-2x" ] []
                , i [ class "fa fa-arrow-right fa-stack-1x fa-inverse" ] []
                ]

        notYetIcon =
            span [ class "fa-stack mr-2 text-secondary" ]
                [ i [ class "fa fa-circle fa-stack-2x" ] []
                , i [ class "fa fa-question fa-stack-1x fa-inverse" ] []
                ]
    in
        case state of
            Checked ->
                checkedIcon

            Current ->
                currentIcon

            NotYet ->
                notYetIcon


stepIndexView : ProjectStep -> Model -> Project -> String -> Html Msg
stepIndexView projectStep model project label =
    let
        activeAttr =
            [ onClick (NavigateTo (ProjectStepRoute project.id projectStep)), class "list-group-item cp gray-hover" ]

        liAttr =
            case stepState project projectStep of
                Checked ->
                    activeAttr

                Current ->
                    activeAttr

                NotYet ->
                    [ class "list-group-item disabled" ]
    in
        li liAttr
            [ a []
                [ checkedIcon (stepState project projectStep)
                , label |> text
                ]
            ]


stepView : Model -> Project -> String -> Html Msg -> Html Msg
stepView model project title view =
    div []
        [ h1 [ class "h1-responsive" ]
            [ a
                [ class "btn btn-sm btn-yellow-flash"
                , onClick (NavigateTo (ProjectRoute project.id))
                ]
                [ i [ class "fa fa-chevron-left" ] []
                ]
            , text title
            ]
        , view
        ]


nextStepButton : Msg -> Html Msg
nextStepButton action =
    button
        [ class "btn btn-default pull-right", onClick action ]
        [ text "Suivant" ]


landImage : String -> Html Msg
landImage source =
    img [ class "d-block p-2 img-thumbnail mt-3 img-fluid", src source ] []


projectLandImages : Project -> List (Html Msg)
projectLandImages project =
    List.map landImage project.ad.land.images


discoverLandView : Model -> Project -> String -> Html Msg
discoverLandView model project title =
    let
        updateValue =
            Json.Encode.object [ ( "discover_land", Json.Encode.bool True ) ]

        getButton : Html Msg
        getButton =
            ValidateDiscoverLand project.id updateValue |> nextStepButton

        button =
            case stepState project DiscoverLand of
                Checked ->
                    getButton

                Current ->
                    getButton

                NotYet ->
                    text ""

        view =
            div []
                ((projectLandImages project)
                    ++ [ p [ class "mt-3 p-3 light-bordered" ] [ text project.ad.land.description ]
                       , button
                       ]
                )
    in
        stepView model project title view


discoverHouseView : Model -> Project -> String -> Html Msg
discoverHouseView model project title =
    let
        updateValue =
            Json.Encode.object [ ( "discover_house", Json.Encode.bool True ) ]

        getButton : Html Msg
        getButton =
            ValidateDiscoverHouse project.id updateValue |> nextStepButton

        button =
            case stepState project DiscoverHouse of
                Checked ->
                    getButton

                Current ->
                    getButton

                NotYet ->
                    text ""

        view =
            div []
                [ photo "maison_21_nuit.jpg"
                , photo "maison-min.png"
                , button
                ]
    in
        stepView model project title view


configureHouseView : Model -> Project -> String -> Html Msg
configureHouseView model project title =
    let
        color1 =
            "Maison-leo-configurateur-1.png"

        color2 =
            "Maison-leo-configurateur-2.png"

        ( photo1, checked11, checked12 ) =
            case ( model.houseColor1, project.house_color_1 ) of
                ( Just house_color_1, _ ) ->
                    ( [ photoClass house_color_1 "photo-stack" ], house_color_1 == color1, house_color_1 == color2 )

                ( Nothing, Just house_color_1 ) ->
                    ( [ photoClass house_color_1 "photo-stack" ], house_color_1 == color1, house_color_1 == color2 )

                _ ->
                    ( [], False, False )

        ( photo2, checked21, checked22 ) =
            case ( model.houseColor2, project.house_color_2 ) of
                ( Just house_color_2, _ ) ->
                    ( [ photoClass house_color_2 "photo-stack" ], house_color_2 == color1, house_color_2 == color2 )

                ( Nothing, Just house_color_2 ) ->
                    ( [ photoClass house_color_2 "photo-stack" ], house_color_2 == color1, house_color_2 == color2 )

                _ ->
                    ( [], False, False )

        view =
            div []
                [ div [ class "position-relative" ]
                    ([ photo "Maison-leo-configurateur-0-min.png" ] ++ photo1 ++ photo2)
                , div [ class "row" ]
                    [ div [ class "col-6" ]
                        [ p [ class "font-bold" ] [ text "Choix 1" ]
                        , div [ class "form-check" ]
                            [ label [ class "form-check-label" ]
                                [ input
                                    [ type_ "radio"
                                    , name "house-color-1"
                                    , value color1
                                    , id "house-color-11"
                                    , class "form-check-input"
                                    , checked checked11
                                    , onClick (SetHouseColor1 color1)
                                    ]
                                    []
                                , text "couleur-1"
                                ]
                            ]
                        , div [ class "form-check" ]
                            [ label [ class "form-check-label" ]
                                [ input
                                    [ type_ "radio"
                                    , name "house-color-1"
                                    , value color2
                                    , id "house-color-12"
                                    , class "form-check-input"
                                    , checked checked12
                                    , onClick (SetHouseColor1 color2)
                                    ]
                                    []
                                , text "couleur-2"
                                ]
                            ]
                        ]
                    , div [ class "col-6" ]
                        [ p [ class "font-bold" ] [ text "Choix 2" ]
                        , div [ class "form-check" ]
                            [ label [ class "form-check-label" ]
                                [ input
                                    [ type_ "radio"
                                    , name "house-color-2"
                                    , value color1
                                    , id "house-color-21"
                                    , class "form-check-input"
                                    , checked checked21
                                    , onClick (SetHouseColor2 color1)
                                    ]
                                    []
                                , text "couleur-1"
                                ]
                            ]
                        , div [ class "form-check" ]
                            [ label [ class "form-check-label" ]
                                [ input
                                    [ type_ "radio"
                                    , name "house-color-2"
                                    , value color2
                                    , id "house-color-22"
                                    , class "form-check-input"
                                    , checked checked22
                                    , onClick (SetHouseColor2 color2)
                                    ]
                                    []
                                , text "couleur-2"
                                ]
                            ]
                        ]
                    ]
                , ValidateConfigureHouse project.id |> nextStepButton
                ]
    in
        stepView model project title view


evaluateFundingView : Model -> Project -> String -> Html Msg
evaluateFundingView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


phoneCallView : Model -> Project -> String -> Html Msg
phoneCallView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


quotationView : Model -> Project -> String -> Html Msg
quotationView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


fundingView : Model -> Project -> String -> Html Msg
fundingView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


visitLandView : Model -> Project -> String -> Html Msg
visitLandView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


contractView : Model -> Project -> String -> Html Msg
contractView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


permitView : Model -> Project -> String -> Html Msg
permitView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


buildingView : Model -> Project -> String -> Html Msg
buildingView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


keysView : Model -> Project -> String -> Html Msg
keysView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view


afterSalesView : Model -> Project -> String -> Html Msg
afterSalesView model project title =
    let
        view =
            div [] []
    in
        stepView model project title view
