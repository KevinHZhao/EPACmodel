#' Construct a model object from model definition files
#'
#' @template param_model.name
#' @template param_local
#'
#' @return A `TMB::TMBModelSpec` object created by [macpan2::mp_tmb_model_spec()]
#' @export
get_model <- function(
    model.name,
    local = FALSE
){
  model_path <-
    get_model_path(
      model.name = model.name,
      file.name = NULL,
      local = local
    )

  sys.source(fs::path(model_path, "model-spec.R"), envir = environment())
  return(model)
}
