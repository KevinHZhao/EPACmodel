#' Aggregate simulation results into overall epi categories
#'
#' @param output simulation output from [simulate()]
#' @param value_type value type to keep in tidied output
#'
#' @return data frame with values aggregated across epidemiological subcategories
tidy_output = function(output, value_type = "state") {
  if (!is.null(value_type)) {
    output <- (output
               |> dplyr::filter(value_type %in% !!value_type)
    )
  }

  output <- (output
             # parse state names
             |> tidyr::separate(
               state_name,
               into = c("var", "age"),
               sep = ".lb"
             )
             # enforce order of states
             |> dplyr::mutate(
               var = forcats::as_factor(var)
             )
  )

  output
}
