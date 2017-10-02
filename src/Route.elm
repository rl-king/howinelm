module Route exposing (..)

import Navigation exposing (Location)
import UrlParser as Url exposing (..)


type Route
    = Home
    | Article String


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Home top
        , Url.map Article (s "article" </> string)
        ]


routeToString : Route -> String
routeToString route =
    case route of
        Home ->
            ""

        Article _ ->
            "article"


parseLocation : Location -> Route
parseLocation =
    Url.parsePath route >> Maybe.withDefault Home
