val gitlab_ref :
     bot_info:Bot_components.Bot_info.t
  -> issue:Bot_components.GitHub_types.issue
  -> github_mapping:(string, string) Base.Hashtbl.t
  -> gitlab_mapping:(string, string) Base.Hashtbl.t
  -> Bot_components.GitHub_types.remote_ref_info Lwt.t

val ( |&& ) : string -> string -> string

val execute_cmd : string -> (unit, string) result Lwt.t

val git_fetch :
  ?force:bool -> Bot_components.GitHub_types.remote_ref_info -> string -> string

val git_push :
     ?force:bool
  -> remote_ref:Bot_components.GitHub_types.remote_ref_info
  -> local_ref:string
  -> string

val git_delete :
  remote_ref:Bot_components.GitHub_types.remote_ref_info -> string

val git_make_ancestor :
     pr_title:string
  -> pr_number:int
  -> base:string
  -> string
  -> (bool, string) result Lwt.t

val init_git_bare_repository : bot_info:Bot_components.Bot_info.t -> unit Lwt.t

val run_coq_minimizer :
     bot_info:Bot_components.Bot_info.t
  -> coq_minimizer_repo_token:Bot_components.Bot_info.github_token
  -> script:string
  -> comment_thread_id:string
  -> comment_author:string
  -> owner:string
  -> repo:string
  -> unit Lwt.t
