let ( let* ) o f = match o with Error msg -> Error msg | Ok v -> f v

let until_check m = Check.modul m

let until_group m =
  let* m = until_check m in
  let* m = Grouped.of_symbolic m in
  Ok m

let until_assign m =
  let* m = until_group m in
  let* m = Assigned.of_grouped m in
  Ok m

let until_simplify m =
  let* m = until_assign m in
  let* m = Rewrite.modul m in
  Ok m

let until_typecheck m =
  let* m = until_simplify m in
  let* () = Typecheck.modul m in
  Ok m

let until_optimize ~optimize m =
  let* m = until_typecheck m in
  if optimize then Ok (Optimize.modul m) else Ok m

let until_link link_state ~optimize ~name m =
  let* m = until_optimize ~optimize m in
  Link.modul link_state ~name m

let until_interpret link_state ~optimize ~name m =
  let* m, link_state = until_link link_state ~optimize ~name m in
  let* () = Interpret.modul link_state.envs m in
  Ok link_state
