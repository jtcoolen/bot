open GitLab_types

type msg =
  | JobEvent of job_info
  | PipelineEvent of pipeline_info
  | UnsupportedEvent of string

val receive_gitlab :
  secret:string -> Cohttp.Header.t -> string -> (bool * msg, string) result
