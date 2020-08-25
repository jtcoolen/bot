open GitHub_types

(** Various operations that change data on the GitHub servers,
    leveraging both REST and GraphQL APIs. *)

(** The following functions use the GraphQL API: *)

val mv_card_to_column :
  bot_info:Bot_info.t -> mv_card_to_column_input -> unit Lwt.t
(** [mv_card_to_column ~bot_info mv_card_to_column_input] moves
    a card whose GraphQL node id is {!field:GitHub_types.mv_card_to_column_input.card_id}
    to a column whose node id is {!field:GitHub_types.mv_card_to_column_input.column_id}.

    The card comes from a {{:https://docs.github.com/en/github/managing-your-work-on-github/about-project-boards} Github Project Board}, a {{:https://en.wikipedia.org/wiki/Kanban_board} Kanban board} for GitHub repositories. *)

val post_comment : bot_info:Bot_info.t -> id:id -> message:string -> unit Lwt.t
(** [post_comment ~bot_info ~id ~message] posts a comment to a comment thread identified by the
    GraphQL node id [id] and with the content of [message]. *)

val merge_pull_request :
     bot_info:Bot_info.t
  -> ?merge_method:merge_method
  -> ?commit_headline:string
  -> ?commit_body:string
  -> pr_id:id
  -> unit Lwt.t
(** [merge_pull_request bot_info ?merge_method ?commit_headline -> ?commit_body pr_id]
    merges a pull request whose GraphQL node id is [pr_id]. *)

val reflect_pull_request_milestone :
  bot_info:Bot_info.t -> issue_closer_info -> unit Lwt.t

(** The following functions use the REST API: *)

val add_rebase_label : bot_info:Bot_info.t -> issue -> unit Lwt.t
(** [add_rebase_label bot_info issue]
    adds a label [needs: rebase] to the issue [issue]. *)

val remove_rebase_label : bot_info:Bot_info.t -> issue -> unit Lwt.t
(** [remove_rebase_label bot_info issue]
    removes the label [needs: rebase] from the issue [issue]. *)

val update_milestone : bot_info:Bot_info.t -> string -> issue -> unit Lwt.t
(** [update_milestone bot_info id issue]
    replaces the current milestone by the one identified by
    the GraphQL node id [id] to the issue [issue]. *)

val remove_milestone : bot_info:Bot_info.t -> issue -> unit Lwt.t
(** [remove_milestone bot_info issue]
    removes the current milestone from the issue [issue]. *)

val send_status_check :
     bot_info:Bot_info.t
  -> repo_full_name:string
  -> commit:string
  -> state:string
  -> url:string
  -> context:string
  -> description:string
  -> unit Lwt.t
(** [send_status_check bot_info repo_full_name commit state url context description]
    sends a {{:https://docs.github.com/v3/repos/statuses/} status check} to the GitHub
    repository [repo_full_name]. The [repo_full_name] argument is expected to be of the
    form ["owner/repo"]. Check the GitHub REST API documentation for details. *)

val add_pr_to_column :
  bot_info:Bot_info.t -> pr_id:int -> column_id:int -> unit Lwt.t
(** [add_pr_to_column bot_info pr_id column_id]
    adds a pull request with GraphQL node id [pr_id] to a column with node id
    [column_id] from a
    {{:https://docs.github.com/en/github/managing-your-work-on-github/about-project-boards} 
    Github Project Board}. *)
