import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import Json.Decode
import Json.Encode
import Svg
import Svg.Attributes


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { input : String
  , messages : List String
  , pins : List Pin
  }

type alias Pin =
  { gpio : Int
  , state : Bool
  , mode : PinMode
  }

type PinMode = PinInput | PinOutput


init : (Model, Cmd Msg)
init =
  (Model "" [] [], Cmd.none)


-- UPDATE

type Msg
  = Input String
  | Send
  | NewMessage String
  | SendRising Pin
  | SendFalling Pin


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input _ ->
      (model, Cmd.none)

    Send ->
      (model, WebSocket.send "ws://echo.websocket.org" "")

    NewMessage str ->
      --(Model input (str :: messages) (decodeMessage str), Cmd.none)
      (Model model.input model.messages (decodeMessage str), Cmd.none)

    SendRising pin ->
      (model, WebSocket.send "ws://localhost:8080/ws" (Json.Encode.encode 0 <| Json.Encode.object [ ("pin", Json.Encode.int pin.gpio), ("interrupt_direction", Json.Encode.string "rising")]))
    SendFalling pin ->
      (model, WebSocket.send "ws://localhost:8080/ws" (Json.Encode.encode 0 <| Json.Encode.object [ ("pin", Json.Encode.int pin.gpio), ("interrupt_direction", Json.Encode.string "falling")]))

decodeMessage message =
  case Json.Decode.decodeString (Json.Decode.field "gpios" (Json.Decode.list pinDecoder)) message of
    Ok pins -> pins
    Err error -> []

pinDecoder = Json.Decode.map3 Pin (Json.Decode.field "pin" Json.Decode.int) (Json.Decode.field "pin_state" bool01Decoder) (Json.Decode.field "direction" pinModeDecoder)

bool01Decoder =
  Json.Decode.int
  |> Json.Decode.andThen (\integer ->
    case integer of
      0 -> Json.Decode.succeed False
      1 -> Json.Decode.succeed True
      invalid -> Json.Decode.fail <| toString invalid
    )

pinModeDecoder =
  Json.Decode.string
  |> Json.Decode.andThen (\pinMode ->
    case pinMode of
      "input" -> Json.Decode.succeed PinInput
      "output" -> Json.Decode.succeed PinOutput
      invalid -> Json.Decode.fail invalid
    )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:8080/ws" NewMessage


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ Svg.svg [ Svg.Attributes.width "200", Svg.Attributes.height "55", Svg.Attributes.viewBox "0 0 200 55", Svg.Attributes.fill "white" ] (List.indexedMap drawPin model.pins)
    , div [] (List.map viewInputPinButtons (List.filter (\pin -> pin.mode == PinInput) model.pins))
    ]


viewMessage : String -> Html msg
viewMessage msg =
  div [] [ text msg ]

viewPin pin =
  div [] [ span [] [ text <| toString pin.gpio ]
  , span [] [ text <| toString pin.mode ]
  , span [] [ text <| toString pin.state ]
         ]

drawPin index pin =
  let
      color = case pin.mode of
        PinInput -> "green"
        PinOutput -> if pin.state then
        "red"
        else
        "black"
  in
        Svg.g [] [ Svg.rect [ Svg.Attributes.x (toString <| index * 20), Svg.Attributes.y "0", Svg.Attributes.width "20", Svg.Attributes.height "20", Svg.Attributes.fill color] []
        , Svg.text_ [ Svg.Attributes.x (toString <| index * 20), Svg.Attributes.y "35", Svg.Attributes.fill "black"] [ Svg.text <| toString pin.gpio ]
        ]

viewInputPinButtons pin =
  div [] [ button [onClick <| SendRising pin] [text <| ((toString pin.gpio) ++ " rising")]
  , button [onClick <| SendFalling pin] [text <| ((toString pin.gpio) ++ " falling")]
  ]
