{shared{
  open Eliom_content
  open Html5
  open Html5.D
}}

module Ex_app =
  Eliom_registration.App (struct let application_name = "ex" end)

{client{
  let switch_visibility elt =
    let elt = To_dom.of_element elt in
      if Js.to_bool (elt##classList##contains(Js.string "hidden")) then
        elt##classList##remove(Js.string "hidden")
      else
        elt##classList##add(Js.string "hidden")

  let mywidget s1 s2 =
    let button  = div ~a:[a_class ["button"]] [pcdata s1] in
    let content = div ~a:[a_class ["content"]] [pcdata s2] in

    (* Next statement is run for its side effects, note the ';' after the statement! *)
    Lwt_js_events.(
      async ( fun () ->
        clicks (To_dom.of_element button)
               (fun _ _ -> switch_visibility content; Lwt.return () )
      )
    );
    div ~a:[a_class ["mywidget"]] [button; content]

  let _ =
    lwt _ = Lwt_js_events.onload () in
    Dom.appendChild
      (Dom_html.document##body)
      (To_dom.of_element (mywidget "Click me" "Hello!"));
    Lwt.return ()

}}


let _ =
  Ex_app.register_service ~path:[] ~get_params:Eliom_parameter.unit
    (fun () () ->
      Lwt.return (Eliom_tools.D.html ~title:"ex" ~css:[["css"; "ex.css"]]
                   (body [h2 [pcdata "Welcome to Ocsigen!"]])))


