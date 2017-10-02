module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error, get, send)
import Json.Decode as D exposing (..)
import Navigation exposing (Location)
import Route exposing (..)
import SyntaxHighlight exposing (elm, gitHub, javascript, toBlockHtml, useTheme)


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
    , articles : List Article
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    { route = parseLocation location
    , articles = []
    }
        ! [ getArticles ]


type Msg
    = NoOp
    | NewUrl String
    | UrlChange Location
    | GotArticles (Result Http.Error (List Article))


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

        GotArticles (Ok articles) ->
            { model | articles = articles } ! []

        GotArticles (Err _) ->
            model ! []


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
        [ header [ class "main-header" ]
            [ h1 [] [ text "How in elm" ]
            , h5 [] [ text "Elm equivalent of Javascript code" ]
            ]
        , selectedView
        ]


titleToSlug : String -> String
titleToSlug title =
    String.join "" (String.words title)


selectedArticle : List Article -> String -> Article
selectedArticle articleList title =
    List.filter ((==) title << titleToSlug << .title) articleList
        |> List.head
        |> Maybe.withDefault emptyArticle


articleList : Model -> Html Msg
articleList model =
    section [] (List.map articleItem model.articles)


articleItem : Article -> Html Msg
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
                , jsBlock item.js
                ]
            , div [ class "code-block" ]
                [ h5 [] [ text "Elm" ]
                , elmBlock item.elm
                ]
            ]
        , footer []
            [ ul [] (List.map (\x -> li [] [ text x ]) item.types)
            ]
        ]


elmBlock elmCode =
    div []
        [ useTheme gitHub
        , elm elmCode
            |> Result.map (toBlockHtml (Just 1))
            |> Result.withDefault
                (pre [] [ code [] [ text elmCode ] ])
        ]


jsBlock jsCode =
    div []
        [ useTheme gitHub
        , javascript jsCode
            |> Result.map (toBlockHtml (Just 1))
            |> Result.withDefault
                (pre [] [ code [] [ text jsCode ] ])
        ]


type alias Article =
    { title : String
    , author : String
    , description : String
    , types : List String
    , elm : String
    , js : String
    }


data =
    [ Article "article 1"
        "author 1"
        "descr"
        [ "Maybe", "Result" ]
        "# 1"
        "js"
    , Article "article 2" "author 2" "descr" [ "Maybe", "Result" ] "elm" "js"
    , Article "article 3" "author 3" "descr" [ "Maybe", "Result" ] "elm" "js"
    , Article "article 4" "author 4" "descr" [ "Maybe", "Result" ] "elm" "js"
    ]


emptyArticle =
    Article "empty" "_" "_" [ "_" ] "_" "_"



-- HTTP


getArticles : Cmd Msg
getArticles =
    Http.get "./data/articles.json" decodeArticleList
        |> Http.send GotArticles


decodeArticleList : D.Decoder (List Article)
decodeArticleList =
    D.list decodeArticle


decodeArticle : D.Decoder Article
decodeArticle =
    D.map6
        Article
        (D.field "title" D.string)
        (D.field "author" D.string)
        (D.field "description" D.string)
        (D.field "tags" (D.list D.string))
        (D.field "elm" D.string)
        (D.field "js" D.string)
