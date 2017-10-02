module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import Route exposing (..)


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = \x -> Sub.none
        }


type alias Model =
    { route : Route
    , articles : List Item
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    { route = parseLocation location
    , articles = data
    }
        ! []


type Msg
    = NoOp
    | NewUrl String
    | UrlChange Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        NewUrl url ->
            model ! [ Navigation.newUrl url ]

        UrlChange location ->
            let
                route =
                    parseLocation location
            in
            { model | route = route } ! []


view : Model -> Html Msg
view model =
    let
        selectedView =
            case model.route of
                Home ->
                    articleList model

                Article title ->
                    articleItem (selectedArticle model.articles title)
    in
    main_ []
        [ header [] [ h1 [] [ text "How to in elm" ] ]
        , selectedView
        ]


titleToSlug : String -> String
titleToSlug title =
    String.join "" (String.words title)


selectedArticle : List Item -> String -> Item
selectedArticle articleList title =
    List.filter ((==) title << titleToSlug << .title) articleList
        |> List.head
        |> Maybe.withDefault emptyArticle


articleList : Model -> Html Msg
articleList model =
    section [] (List.map articleItem model.articles)


articleItem : Item -> Html Msg
articleItem item =
    article []
        [ h2
            [ onClick (NewUrl ("/article/" ++ titleToSlug item.title))
            ]
            [ text item.title ]
        , small [] [ text item.author ]
        , ul [] (List.map (\x -> li [] [ text x ]) item.types)
        , div [ class "code-blocks" ]
            [ pre [] [ text item.js ]
            , pre [] [ text item.elm ]
            ]
        ]


type alias Item =
    { title : String
    , author : String
    , description : String
    , types : List String
    , elm : String
    , js : String
    }


data =
    [ Item "article 1" "author 1" "descr" [ "Maybe", "Result" ] "elm" "js"
    , Item "article 2" "author 2" "descr" [ "Maybe", "Result" ] "elm" "js"
    , Item "article 3" "author 3" "descr" [ "Maybe", "Result" ] "elm" "js"
    , Item "article 4" "author 4" "descr" [ "Maybe", "Result" ] "elm" "js"
    ]


emptyArticle =
    Item "empty" "_" "_" [ "_" ] "_" "_"
