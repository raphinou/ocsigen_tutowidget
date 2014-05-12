{shared{
  open Eliom_content
  open Html5
  open Html5.D
}}

module Ex_app =
  Eliom_registration.App (struct let application_name = "ex" end)

{client{
  (* Create a reference holding a function that will be called on the click *)
  let close_last = ref (fun c -> () )
  let switch_visibility elt =
    let elt = To_dom.of_element elt in
      if Js.to_bool (elt##classList##contains(Js.string "hidden")) then
        elt##classList##remove(Js.string "hidden")
      else
        elt##classList##add(Js.string "hidden")

}}

{shared{
  (* mywidget is now available both server and client side *)
  let mywidget s1 s2 =
    let button  = div ~a:[a_class ["button"]] [pcdata s1] in
    let content = div ~a:[a_class ["content";"hidden"]] [pcdata s2] in

    (* We need to reference button and content from the client to the server side.
       It is run as a client side value with {unit{...}}, to be executed by the client
       when it receives it.
     *)
    let _ = {unit {Lwt_js_events.(
      async ( fun () ->
        clicks (To_dom.of_element %button)
               (fun _ _ -> 
                 (* call function found in reference, and change it so it toggles the element we will change now back to its original state
                    the problem though is that we cannot hide the open widget, as clicking it will reopen it immediately as we switch its
                    visibility 2 times *)
                 !close_last %content;
                 close_last:=(fun c -> switch_visibility %content);
                 switch_visibility %content; Lwt.return () )
      )
    ) }}
    in
    div ~a:[a_class ["mywidget"]] [button; content]
}}

let _ =
  Ex_app.register_service ~path:[] ~get_params:Eliom_parameter.unit
    (fun () () ->
      Lwt.return (Eliom_tools.D.html ~title:"ex" ~css:[["css"; "ex.css"]]
                   (body [h2 [pcdata "Welcome to Ocsigen!"]; mywidget "Click me" "Hello"; mywidget "Click me" "Hello2";mywidget "Click me" "Hello3"  ])))


