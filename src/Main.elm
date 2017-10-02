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
        [ header [ class "main-header" ] [ h1 [] [ text "How to in elm" ] ]
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
        [ header []
            [ h2
                [ onClick (NewUrl ("/article/" ++ titleToSlug item.title)) ]
                [ text item.title ]
            , small [] [ text item.author ]
            , p [] [ text item.description ]
            ]
        , div [ class "code-blocks" ]
            [ div [ class "code-block" ]
                [ h5 [] [ text "JavaScript" ]
                , pre [] [ text item.js ]
                ]
            , div [ class "code-block" ]
                [ h5 [] [ text "Elm" ]
                , pre [] [ text item.elm ]
                ]
            ]
        , footer []
            [ ul [] (List.map (\x -> li [] [ text x ]) item.types)
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
    [ Item "article 1" "author 1" "descr" [ "Maybe", "Result" ] """myTuple = ("A", "B", "C")
myNestedTuple = ("A", "B", "C", ("X", "Y", "Z"))

let
  (a,b,c) = myTuple
in
  a ++ b ++ c
-- "ABC" : String

let
  (a,b,c,(x,y,z)) = myNestedTuple
in
  a ++ b ++ c ++ x ++ y ++ z
-- "ABCXYZ" : String""" "js"
    , Item "article 2" "author 2" "descr" [ "Maybe", "Result" ] "elm" "js"
    , Item "article 3" "author 3" "descr" [ "Maybe", "Result" ] "elm" "js"
    , Item "article 4" "author 4" "descr" [ "Maybe", "Result" ] "elm" "js"
    ]


emptyArticle =
    Item "empty" "_" "_" [ "_" ] "_" "_"
