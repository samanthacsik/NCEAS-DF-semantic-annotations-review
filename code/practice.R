# example
my_list <- list(
  "first_node" = list(
    "group_a" = list(
      "E001" = 1:5,
      "E002" = list(
        "F001" = 6:10,
        "F002" = 11:15
      )
    ),
    "group_b" = list(
      "XY01" = list(
        "Z1" = LETTERS[1:5],
        "Z2" = LETTERS[6:10],
        "Z3" = list(
          "ZZ1" = LETTERS[1],
          "ZZ2" = LETTERS[2],
          "ZZ3" = LETTERS[3]
        )
      ),
      "YZ" = LETTERS[11:15]
    ),
    "group_c" = list(
      "QQQQ" = list(
        "RRRR" = 200:300
      )
    )
  ),
  "second_node" = list(
    "group_d" = list(
      "L1" = 99:101,
      "L2" = 12
    )
  )
)

find_name <- function(haystack, needle) {
  if (hasName(haystack, needle)) {
    haystack[[needle]]
  } else if (is.list(haystack)) {
    for (obj in haystack) {
      ret <- Recall(obj, needle)
      if (!is.null(ret)) return(ret)
    }
  } else {
    NULL
  }
}

test <- find_name(my_list, "XY01")
