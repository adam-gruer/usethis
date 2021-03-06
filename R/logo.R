#' Use a package logo
#'
#' This function helps you use a logo in your package:
#'   * Enforces a specific size
#'   * Stores logo image file at `man/figures/logo.png`
#'   * Produces the markdown text you need in README to include the logo
#'
#' @param img The path to an existing image file
#' @param geometry a [magick::geometry] string specifying size. The default
#'   assumes that you have a hex logo using spec from
#'   <http://hexb.in/sticker.html>.
#' @param retina `TRUE`, the default, scales the image on the README,
#'   assuming that geometry is double the desired size.
#'
#' @examples
#' \dontrun{
#' use_logo("usethis.png")
#' }
#' @export
use_logo <- function(img, geometry = "240x278", retina = TRUE) {
  check_is_package("use_logo()")

  logo_path <- proj_path("man", "figures", "logo", ext = path_ext(img))
  if (!can_overwrite(logo_path)) {
    return(invisible(FALSE))
  }

  dir_create(path_dir(logo_path))

  if (path_ext(img) == "svg") {
    logo_path <- path("man", "figures", "logo.svg")
    file_copy(img, proj_path(logo_path))
    done("Copied {value(path_file(img))} to {value(logo_path)}")

    height <- as.integer(sub(".*x", "", geometry))
  } else {
    check_installed("magick")

    img_data <- magick::image_read(img)
    img_data <- magick::image_resize(img_data, geometry)
    magick::image_write(img_data, logo_path)
    done("Resized {value(path_file(img))} to {geometry}")

    height <- magick::image_info(magick::image_read(logo_path))$height
  }

  pkg <- project_name()
  if (retina) {
    height <- height / 2
  }

  todo("Add logo to your README with the following html:")
  code_block("# {pkg} <img src=\"{proj_rel_path(logo_path)}\" align=\"right\" height=\"{height}\" />")
}
