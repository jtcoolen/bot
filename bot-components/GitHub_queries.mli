open GitHub_types

val get_pull_request_milestone_and_cards :
     bot_info:Bot_info.t
  -> owner:string
  -> repo:string
  -> number:int
  -> (project_card list * milestone option, string) result Lwt.t

val get_backported_pr_info :
     bot_info:Bot_info.t
  -> int
  -> string
  -> (mv_card_to_column_input option, string) result Lwt.t

val get_pull_request_id_and_milestone :
     bot_info:Bot_info.t
  -> owner:string
  -> repo:string
  -> number:int
  -> ((string * int * full_backport_info) option, string) result Lwt.t

val get_team_membership :
     bot_info:Bot_info.t
  -> org:string
  -> team:string
  -> user:string
  -> (bool, string) result Lwt.t

val get_pull_request_refs :
     bot_info:Bot_info.t
  -> owner:string
  -> repo:string
  -> number:int
  -> (string pull_request_info, string) result Lwt.t

val get_pull_request_reviews_refs :
     bot_info:Bot_info.t
  -> owner:string
  -> repo:string
  -> number:int
  -> (pull_request_reviews_info, string) result Lwt.t

val get_file_content :
     bot_info:Bot_info.t
  -> owner:string
  -> repo:string
  -> branch:string
  -> file_name:string
  -> (string option, string) result Lwt.t

val get_default_branch :
     bot_info:Bot_info.t
  -> owner:string
  -> repo:string
  -> (string, string) result Lwt.t

val get_issue_closer_info :
     bot_info:Bot_info.t
  -> issue
  -> (issue_closer_info closed_by, string) result Lwt.t

val get_repository_id :
  bot_info:Bot_info.t -> owner:id -> repo:id -> (id, string) result Lwt.t

val get_status_check :
     repo_full_name:string
  -> commit:string
  -> context:string
  -> bot_info:Bot_info.t
  -> (bool, string) result Lwt.t

val get_cards_in_column :
  int -> bot_info:Bot_info.t -> ((string * int) list, string) result Lwt.t

val get_check_runs :
     owner:string
  -> repo:string
  -> ref:string
  -> app_id:int
  -> bot_info:Bot_info.t
  -> (check_run list, id) result Lwt.t
