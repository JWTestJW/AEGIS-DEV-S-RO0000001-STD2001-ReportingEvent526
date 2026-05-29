# ========================================================
# CRAN / RSPM パッケージ情報一括照会スクリプト
# 用途：各パッケージの最新バージョン、
#       Depends / Imports / LinkingTo（直接）と
#       再帰依存（間接）を確認し、CSV出力する
# ========================================================

# ----------------------------------------------------------
# スクリプトの実行ディレクトリを取得
# ----------------------------------------------------------
script_dir <- tryCatch(
  dirname(rstudioapi::getSourceEditorContext()$path),
  error = function(e) getwd()
)

# ----------------------------------------------------------
# 照会対象パッケージをファイルから読み込む
# ファイル形式：1行1パッケージ名
# 空行・#で始まるコメント行はスキップ
# ----------------------------------------------------------
input_file <- file.path(script_dir, "check_target_packages.txt")

if (!file.exists(input_file)) {
  stop("[エラー] 入力ファイルが見つかりません: ", input_file)
}

pkgs <- readLines(input_file, warn = FALSE)
pkgs <- trimws(pkgs)
pkgs <- pkgs[pkgs != "" & !startsWith(pkgs, "#")]

if (length(pkgs) == 0) {
  stop("[エラー] 入力ファイルにパッケージ名が0件です: ", input_file)
}

cat("照会対象パッケージ (", length(pkgs), "件 ):\n")
cat("  ", paste(pkgs, collapse = ", "), "\n\n")

# ----------------------------------------------------------
# リポジトリの指定（RSPM の latest を使用）
# CRANを使う場合："https://cran.r-project.org"
# ----------------------------------------------------------
repo <- "https://packagemanager.posit.co/cran/latest"

# ----------------------------------------------------------
# パッケージデータベースの取得
# ----------------------------------------------------------
cat("=== リポジトリからパッケージ情報を取得中... ===\n")
cat("リポジトリ: ", repo, "\n\n")
ap <- available.packages(repos = repo)
cat("取得完了。総パッケージ数: ", nrow(ap), "\n\n")

# ----------------------------------------------------------
# 存在チェック（CRANに存在しないパッケージを検出）
# ----------------------------------------------------------
not_found <- pkgs[!(pkgs %in% rownames(ap))]
if (length(not_found) > 0) {
  cat("[警告] 以下のパッケージはCRANに存在しません:\n")
  cat("  ", paste(not_found, collapse = ", "), "\n\n")
}
valid_pkgs <- pkgs[pkgs %in% rownames(ap)]

# ----------------------------------------------------------
# 依存情報の取得
# ----------------------------------------------------------
get_dep <- function(target_pkgs, which_field, recursive_flag) {
  if (length(target_pkgs) == 0) return(setNames(vector("list", 0), character(0)))
  tools::package_dependencies(
    target_pkgs,
    db = ap,
    which = which_field,
    recursive = recursive_flag
  )
}

# 直接依存
direct_depends <- get_dep(valid_pkgs, "Depends", FALSE)
direct_imports <- get_dep(valid_pkgs, "Imports", FALSE)
direct_linkingto <- get_dep(valid_pkgs, "LinkingTo", FALSE)

# 再帰依存（Depends + Imports + LinkingTo を起点）
all_recursive_deps <- get_dep(
  valid_pkgs,
  c("Depends", "Imports", "LinkingTo"),
  TRUE
)

collapse_or_none <- function(x) {
  if (length(x) == 0) "(なし)" else paste(sort(unique(x)), collapse = ", ")
}

# ----------------------------------------------------------
# コンソールにパッケージ詳細情報を出力
# ----------------------------------------------------------
cat("============================================================\n")
cat("  パッケージ詳細情報\n")
cat("============================================================\n\n")

for (pkg in pkgs) {
  cat("------------------------------------------------------------\n")
  cat("【パッケージ名】", pkg, "\n")

  if (!(pkg %in% valid_pkgs)) {
    cat("  ※ CRANに存在しません\n\n")
    next
  }

  pkg_version <- ap[pkg, "Version"]

  depends <- direct_depends[[pkg]]
  if (is.null(depends)) depends <- character(0)

  imports <- direct_imports[[pkg]]
  if (is.null(imports)) imports <- character(0)

  linkingto <- direct_linkingto[[pkg]]
  if (is.null(linkingto)) linkingto <- character(0)

  direct_union <- sort(unique(c(depends, imports, linkingto)))

  all_rec <- all_recursive_deps[[pkg]]
  if (is.null(all_rec)) all_rec <- character(0)

  # ========================================================
  # CRAN / RSPM パッケージ情報一括照会スクリプト
  # 用途：各パッケージの最新バージョン、
  #       Depends / Imports / LinkingTo（直接）と
  #       再帰依存（間接）を確認し、CSV出力する
  # ========================================================

  # ----------------------------------------------------------
  # スクリプトの実行ディレクトリを取得
  # ----------------------------------------------------------
  script_dir <- tryCatch(
    dirname(rstudioapi::getSourceEditorContext()$path),
    error = function(e) getwd()
  )

  # ----------------------------------------------------------
  # 照会対象パッケージをファイルから読み込む
  # ファイル形式：1行1パッケージ名
  # 空行・#で始まるコメント行はスキップ
  # ----------------------------------------------------------
  input_file <- file.path(script_dir, "check_target_packages.txt")

  if (!file.exists(input_file)) {
    stop("[エラー] 入力ファイルが見つかりません: ", input_file)
  }

  pkgs <- readLines(input_file, warn = FALSE)
  pkgs <- trimws(pkgs)
  pkgs <- pkgs[pkgs != "" & !startsWith(pkgs, "#")]

  if (length(pkgs) == 0) {
    stop("[エラー] 入力ファイルにパッケージ名が0件です: ", input_file)
  }

  cat("照会対象パッケージ (", length(pkgs), "件 ):\n")
  cat("  ", paste(pkgs, collapse = ", "), "\n\n")

  # ----------------------------------------------------------
  # リポジトリの指定（RSPM の latest を使用）
  # CRANを使う場合："https://cran.r-project.org"
  # ----------------------------------------------------------
  repo <- "https://packagemanager.posit.co/cran/latest"

  # ----------------------------------------------------------
  # パッケージデータベースの取得
  # ----------------------------------------------------------
  cat("=== リポジトリからパッケージ情報を取得中... ===\n")
  cat("リポジトリ: ", repo, "\n\n")
  ap <- available.packages(repos = repo)
  cat("取得完了。総パッケージ数: ", nrow(ap), "\n\n")

  # ----------------------------------------------------------
  # 存在チェック（CRANに存在しないパッケージを検出）
  # ----------------------------------------------------------
  not_found <- pkgs[!(pkgs %in% rownames(ap))]
  if (length(not_found) > 0) {
    cat("[警告] 以下のパッケージはCRANに存在しません:\n")
    cat("  ", paste(not_found, collapse = ", "), "\n\n")
  }
  valid_pkgs <- pkgs[pkgs %in% rownames(ap)]

  # ----------------------------------------------------------
  # 依存情報の取得
  # ----------------------------------------------------------
  get_dep <- function(target_pkgs, which_field, recursive_flag) {
    if (length(target_pkgs) == 0) {
      return(setNames(vector("list", 0), character(0)))
    }

    tools::package_dependencies(
      target_pkgs,
      db = ap,
      which = which_field,
      recursive = recursive_flag
    )
  }

  # 直接依存
  direct_depends <- get_dep(valid_pkgs, "Depends", FALSE)
  direct_imports <- get_dep(valid_pkgs, "Imports", FALSE)
  direct_linkingto <- get_dep(valid_pkgs, "LinkingTo", FALSE)

  # 再帰依存（Depends + Imports + LinkingTo を起点）
  all_recursive_deps <- get_dep(
    valid_pkgs,
    c("Depends", "Imports", "LinkingTo"),
    TRUE
  )

  collapse_or_none <- function(x) {
    if (length(x) == 0) {
      "(なし)"
    } else {
      paste(sort(unique(x)), collapse = ", ")
    }
  }

  # ----------------------------------------------------------
  # コンソールにパッケージ詳細情報を出力
  # ----------------------------------------------------------
  cat("============================================================\n")
  cat("  パッケージ詳細情報\n")
  cat("============================================================\n\n")

  for (pkg in pkgs) {
    cat("------------------------------------------------------------\n")
    cat("【パッケージ名】", pkg, "\n")

    if (!(pkg %in% valid_pkgs)) {
      cat("  ※ CRANに存在しません\n\n")
      next
    }

    pkg_version <- ap[pkg, "Version"]

    depends <- direct_depends[[pkg]]
    if (is.null(depends)) depends <- character(0)

    imports <- direct_imports[[pkg]]
    if (is.null(imports)) imports <- character(0)

    linkingto <- direct_linkingto[[pkg]]
    if (is.null(linkingto)) linkingto <- character(0)

    direct_union <- sort(unique(c(depends, imports, linkingto)))

    all_rec <- all_recursive_deps[[pkg]]
    if (is.null(all_rec)) all_rec <- character(0)

    recursive_only <- sort(setdiff(unique(all_rec), direct_union))

    cat("【バージョン】    ", pkg_version, "\n")
    cat("【Depends】      (", length(depends), "件 )\n", sep = "")
    cat("   ", collapse_or_none(depends), "\n")
    cat("【Imports】      (", length(imports), "件 )\n", sep = "")
    cat("   ", collapse_or_none(imports), "\n")
    cat("【LinkingTo】    (", length(linkingto), "件 )\n", sep = "")
    cat("   ", collapse_or_none(linkingto), "\n")
    cat("【再帰依存】      (", length(recursive_only), "件 ) ※直接依存を除く\n", sep = "")
    cat("   ", collapse_or_none(recursive_only), "\n\n")
  }

  # ----------------------------------------------------------
  # CSV ファイル出力
  # ヘッダーの日付は実行日を自動設定
  # UTF-8 BOM 付き（Excel で文字化けしないように）
  # ----------------------------------------------------------
  today_str <- format(Sys.Date(), "%Y/%m/%d")
  output_file <- file.path(script_dir, "package_check_result.csv")

  csv_header <- paste0(
    '"パッケージ名",',
    '"バージョン（', today_str, '時点のCRANの最新）",',
    '"Depends",',
    '"Imports",',
    '"LinkingTo",',
    '"再帰依存（直接依存を除く）"'
  )

  csv_lines <- c(csv_header)

  for (pkg in pkgs) {
    if (!(pkg %in% valid_pkgs)) {
      row <- paste0(
        '"', pkg, '",',
        '"(CRANに存在しません)",',
        '"",',
        '"",',
        '"",',
        '""'
      )
    } else {
      pkg_version <- ap[pkg, "Version"]

      depends <- direct_depends[[pkg]]
      if (is.null(depends)) depends <- character(0)

      imports <- direct_imports[[pkg]]
      if (is.null(imports)) imports <- character(0)

      linkingto <- direct_linkingto[[pkg]]
      if (is.null(linkingto)) linkingto <- character(0)

      direct_union <- sort(unique(c(depends, imports, linkingto)))

      all_rec <- all_recursive_deps[[pkg]]
      if (is.null(all_rec)) all_rec <- character(0)

      recursive_only <- sort(setdiff(unique(all_rec), direct_union))

      row <- paste0(
        '"', pkg, '",',
        '"', ifelse(is.na(pkg_version), "", pkg_version), '",',
        '"', paste(sort(unique(depends)), collapse = ", "), '",',
        '"', paste(sort(unique(imports)), collapse = ", "), '",',
        '"', paste(sort(unique(linkingto)), collapse = ", "), '",',
        '"', paste(recursive_only, collapse = ", "), '"'
      )
    }

    csv_lines <- c(csv_lines, row)
  }

  csv_lines <- enc2utf8(csv_lines)
  con <- file(output_file, open = "wb")
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
  writeLines(csv_lines, con, useBytes = TRUE)
  close(con)

  cat("============================================================\n")
  cat("CSV出力完了: ", output_file, "\n")
  cat("=== 照会完了 ===\n")