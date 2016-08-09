(* ocamlc -I +ocamlmpi -o sendrecv mpi.cma sendrecv.ml               *)
(* mpiexec -n 2 ./sendrecv                                           *)

open Mpi

type message = Fib of (unit -> unit)
             | Task of int

effect Spawn : (unit -> unit) -> int
let spawn f = perform (Spawn f)
effect Yield : unit
let yield () = perform Yield
effect Myself : int
let myself () = perform Myself

effect Send : int * message -> unit
let send pid msg = perform (Send (pid, (Task msg)))                
effect Recv : int -> message
let rec recv () =
  yield ();
  match perform (Recv (myself ())) with
  | Task i -> i
  | _ -> assert false  
                 
let rec fib n parent () =
  if n == 0 || n == 1
  then send parent n
  else
    let me = myself () in
    let _  = spawn (fib (n-1) me) in
    let _  = spawn (fib (n-2) me) in
    send parent (recv () + recv ())

let nthfib n () =
  fib n (myself ()) ();
  Printf.printf "Fib: %d\n" (recv ())

      
let mpi m =
  let nodes = (Mpi.comm_size Mpi.comm_world) in
  let node = ref 0 in
  match m () with
  | effect (Spawn f) k ->
     node := (!node mod nodes) + 1;
     let pid = !node in
     Mpi.send (Fib f) pid 0 Mpi.comm_world;
     continue k pid
  | effect Yield k -> continue k ()
  | effect (Send (node, msg)) k ->
     Mpi.send msg node 0 Mpi.comm_world;
     continue k ()
  | effect (Recv _) k ->
     let msg = Mpi.receive Mpi.any_source 0 Mpi.comm_world in
     continue k msg
  | effect Myself k ->
     let rank = Mpi.comm_rank Mpi.comm_world in
     continue k rank
  | v -> ()

let fibered m =
  let q = Queue.empty ()
     

let worker () =
  
     
let main () =

  let rank = Mpi.comm_rank Mpi.comm_world in
  let _    =
    if rank == 0 then
      mpi (nthfib 10)
    else
      worker ()
  
  (* (\* Determine what my rank is *\) *)

  (* let rank = Mpi.comm_rank Mpi.comm_world in *)
  
  (* let my_tag = 1664 in *)
  
  (* print_string( "I am rank " ^ ( string_of_int rank ) ); *)
  (* print_newline(); *)

  (* if rank = 0 then *)
  (*   Mpi.send (Foo (fun () -> Printf.printf "Thunk!\n")) 1 my_tag Mpi.comm_world *)
  (* else *)
  (*   if rank = 1 then *)
  (*     begin *)
  (*       match receive 0 my_tag Mpi.comm_world with *)
  (*       | Foo f -> f () *)
  (*       | Bar c -> Printf.printf "Received %c\n" c *)
  (*     end *)
  (* ; *)
      
    

  Mpi.barrier comm_world
;;
  
main ()
