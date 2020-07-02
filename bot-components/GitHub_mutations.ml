open Base
open GitHub_GraphQL
open Lwt
open Utils

let mv_card_to_column ~token
    ({card_id; column_id} : GitHub_queries.mv_card_to_column_input) =
  MoveCardToColumn.make ~card_id ~column_id ()
  |> GitHub_queries.send_graphql_query ~token
  >|= function
  | Ok _ ->
      ()
  | Error err ->
      print_endline (f "Error while moving project card: %s" err)

let post_comment ~token ~id ~message =
  PostComment.make ~id ~message ()
  |> GitHub_queries.send_graphql_query ~token
  >|= function
  | Ok _ ->
      ()
  | Error err ->
      print_endline (f "Error while posting comment: %s" err)

let update_milestone ~token ~issue ~milestone =
  UpdateMilestone.make ~issue ~milestone ()
  |> GitHub_queries.send_graphql_query ~token
  >|= function
  | Ok _ ->
      ()
  | Error err ->
      print_endline (f "Error while updating milestone: %s" err)

let reflect_pull_request_milestone ~token
    (issue_closer_info : GitHub_queries.issue_closer_info) =
  match issue_closer_info.closer.milestone_id with
  | None ->
      Lwt_io.printf "PR closed without a milestone: doing nothing.\n"
  | Some milestone -> (
    match issue_closer_info.milestone_id with
    | None ->
        (* No previous milestone: setting the one of the PR which closed the issue *)
        update_milestone ~token ~issue:issue_closer_info.issue_id ~milestone
    | Some previous_milestone when String.equal previous_milestone milestone ->
        Lwt_io.print "Issue is already in the right milestone: doing nothing.\n"
    | Some _ ->
        update_milestone ~token ~issue:issue_closer_info.issue_id ~milestone
        <&> post_comment ~token ~id:issue_closer_info.issue_id
              ~message:
                "The milestone of this issue was changed to reflect the one of \
                 the pull request that closed it." )

(* TODO: use GraphQL API *)

let add_rebase_label (issue_info : GitHub_subscriptions.issue_info) ~token =
  let issue = issue_info.issue in
  GitHub_queries.get_label_id ~owner:issue.owner ~repo:issue.repo
    ~name:"needs: rebase" ~token
  >>= function
  | Error e ->
      Lwt_io.printf "Error while adding rebase label: %s" e
  | Ok label_id -> (
      AddLabel.make ~labelable:issue_info.id ~label:label_id ()
      |> GitHub_queries.send_graphql_query ~token
      >|= function
      | Ok _ ->
          ()
      | Error err ->
          print_endline (f "Error while adding rebase label: %s" err) )

let remove_rebase_label (issue_info : GitHub_subscriptions.issue_info) ~token =
  let issue = issue_info.issue in
  GitHub_queries.get_label_id ~owner:issue.owner ~repo:issue.repo
    ~name:"needs: rebase" ~token
  >>= function
  | Error e ->
      Lwt_io.printf "Error while removing rebase label: %s" e
  | Ok label_id -> (
      RemoveLabel.make ~labelable:issue_info.id ~label:label_id ()
      |> GitHub_queries.send_graphql_query ~token
      >|= function
      | Ok _ ->
          ()
      | Error err ->
          print_endline (f "Error while removing rebase label: %s" err) )

let update_milestone new_milestone (issue : GitHub_subscriptions.issue) ~token =
  GitHub_queries.get_pr_id ~owner:issue.owner ~repo:issue.repo
    ~number:issue.number ~token
  >>= function
  | Error e ->
      Lwt_io.printf "Error while retrieving pull request id: %s" e
  | Ok pr_id -> (
      GitHub_queries.get_milestone_id ~owner:issue.owner ~repo:issue.repo
        ~number:(int_of_string new_milestone)
        ~token
      >>= function
      | Error e ->
          Lwt_io.printf "Error while retrieving milestone id: %s" e
      | Ok milestone_id -> (
          UpdateMilestoneFromPR.make ~pullRequestId:pr_id
            ~milestoneId:milestone_id ()
          |> GitHub_queries.send_graphql_query ~token
          >|= function
          | Ok _ ->
              ()
          | Error err ->
              print_endline (f "Error while updating milestone: %s" err) ) )

let remove_milestone (issue : GitHub_subscriptions.issue) ~token =
  GitHub_queries.get_pr_id ~owner:issue.owner ~repo:issue.repo
    ~number:issue.number ~token
  >>= function
  | Error e ->
      Lwt_io.printf "Error while retrieving pull request id: %s" e
  | Ok pr_id -> (
      RemoveMilestoneFromPR.make ~pullRequestId:pr_id ()
      |> GitHub_queries.send_graphql_query ~token
      >|= function
      | Ok _ ->
          ()
      | Error err ->
          print_endline (f "Error while updating milestone: %s" err) )

let send_status_check ~repo_full_name ~commit ~state ~url ~context ~description
    ~token =
  Lwt_io.printf "Sending status check to %s (commit %s, state %s)\n"
    repo_full_name commit state
  >>= fun () ->
  let body =
    "{\"state\": \"" ^ state ^ "\",\"target_url\":\"" ^ url
    ^ "\", \"description\": \"" ^ description ^ "\", \"context\": \"" ^ context
    ^ "\"}"
    |> (fun body ->
         Stdio.printf "Body:\n %s\n" body ;
         body)
    |> Cohttp_lwt.Body.of_string
  in
  let uri =
    "https://api.github.com/repos/" ^ repo_full_name ^ "/statuses/" ^ commit
    |> Uri.of_string
  in
  let github_header = [("Authorization", "bearer " ^ token)] in
  send_request ~body ~uri github_header

let add_pr_to_column pr_id column_id ~token =
  let body =
    "{\"content_id\":" ^ Int.to_string pr_id
    ^ ", \"content_type\": \"PullRequest\"}"
    |> (fun body ->
         Stdio.printf "Body:\n%s\n" body ;
         body)
    |> Cohttp_lwt.Body.of_string
  in
  let uri =
    "https://api.github.com/projects/columns/" ^ Int.to_string column_id
    ^ "/cards"
    |> (fun url ->
         Stdio.printf "URL: %s\n" url ;
         url)
    |> Uri.of_string
  in
  let github_header = [("Authorization", "bearer " ^ token)] in
  send_request ~body ~uri (project_api_preview_header @ github_header)
