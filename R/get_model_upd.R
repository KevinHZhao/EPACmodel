#' Construct a model object from model definition files UPDATED
#'
#' @template param_model.name
#' @template param_local
#'
#' @return A [macpan2::Model()] object
#' @export
get_model_upd <- function(
    model.name,
    local = FALSE
){
  model_path <-
    get_model_path(
      model.name = model.name,
      file.name = NULL,
      local = local
    )

  source(fs::path(model_path, "model-spec.R"))
  return(model)
}
