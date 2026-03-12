#' List flow names for a model
#'
#' @template param_model.name
#' @template param_local
#'
#' @returns Character vector of flows in model, see README for `model.name` for
#' explanations of each flow name.
#' @export
list_flows <- function(
    model.name,
    local = FALSE
){
  model <- get_model(model.name)
  return(model$all_derived_vars())
}
