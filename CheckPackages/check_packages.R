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
cran_repo <- "https://packagemanager.posit.co/cran/latest"
internal_repo <- "https://aegisrspm.internal.onecloudlabo.com/aegis-R4.5.1-dev/latest"

# ----------------------------------------------------------
# パッケージデータベースの取得
# ----------------------------------------------------------
cat("=== リポジトリからパッケージ情報を取得中... ===\n")
cat("CRANリポジトリ: ", cran_repo, "\n")
ap_cran <- available.packages(repos = cran_repo)
cat("取得完了 (CRAN)。総パッケージ数: ", nrow(ap_cran), "\n\n")

cat("内部リポジトリ: ", internal_repo, "\n")
ap_internal <- available.packages(repos = internal_repo)
cat("取得完了 (内部)。総パッケージ数: ", nrow(ap_internal), "\n\n")

# ----------------------------------------------------------
# 存在チェック（CRANに存在しないパッケージを検出）
# ----------------------------------------------------------
in_cran <- pkgs %in% rownames(ap_cran)
in_internal <- pkgs %in% rownames(ap_internal)

pkg_source <- setNames(rep("NOT_FOUND", length(pkgs)), pkgs)
pkg_source[in_cran] <- "CRAN"
pkg_source[!in_cran & in_internal] <- "INTERNAL"

not_in_cran <- pkgs[!in_cran]
if (length(not_in_cran) > 0) {
  cat("[警告] 以下のパッケージはCRANに存在しません:\n")
  cat("  ", paste(not_in_cran, collapse = ", "), "\n\n")
}

not_found_anywhere <- names(pkg_source)[pkg_source == "NOT_FOUND"]
if (length(not_found_anywhere) > 0) {
  cat("[警告] 以下のパッケージはCRAN/内部リポジトリの両方に存在しません:\n")
  cat("  ", paste(not_found_anywhere, collapse = ", "), "\n\n")
}

# ----------------------------------------------------------
# 依存情報の取得
# ----------------------------------------------------------
get_dep <- function(target_pkgs, db, which_field, recursive_flag) {
  if (length(target_pkgs) == 0) return(setNames(vector("list", 0), character(0)))
  tools::package_dependencies(
    target_pkgs,
    db = db,
    which = which_field,
    recursive = recursive_flag
  )
}

# パッケージごとに参照先リポジトリを切り替えて依存を取得
direct_depends <- setNames(vector("list", length(pkgs)), pkgs)
direct_imports <- setNames(vector("list", length(pkgs)), pkgs)
direct_linkingto <- setNames(vector("list", length(pkgs)), pkgs)
all_recursive_deps <- setNames(vector("list", length(pkgs)), pkgs)

for (pkg in pkgs) {
  src <- pkg_source[[pkg]]
  if (src == "NOT_FOUND") {
    direct_depends[[pkg]] <- character(0)
    direct_imports[[pkg]] <- character(0)
    direct_linkingto[[pkg]] <- character(0)
    all_recursive_deps[[pkg]] <- character(0)
    next
  }

  dep_db <- if (src == "CRAN") ap_cran else ap_internal

  d <- get_dep(pkg, dep_db, "Depends", FALSE)[[pkg]]
  i <- get_dep(pkg, dep_db, "Imports", FALSE)[[pkg]]
  l <- get_dep(pkg, dep_db, "LinkingTo", FALSE)[[pkg]]
  r <- get_dep(pkg, dep_db, c("Depends", "Imports", "LinkingTo"), TRUE)[[pkg]]

  direct_depends[[pkg]] <- if (is.null(d)) character(0) else d
  direct_imports[[pkg]] <- if (is.null(i)) character(0) else i
  direct_linkingto[[pkg]] <- if (is.null(l)) character(0) else l
  all_recursive_deps[[pkg]] <- if (is.null(r)) character(0) else r
}

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

  src <- pkg_source[[pkg]]

  if (src == "NOT_FOUND") {
    cat("  ※ CRAN/内部リポジトリに存在しません\n\n")
    next
  }

  pkg_version <- if (src == "CRAN") ap_cran[pkg, "Version"] else ap_internal[pkg, "Version"]

  if (src == "INTERNAL") {
    cat("  ※ CRANに存在しないため、内部リポジトリで依存を取得\n")
  }

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
  src <- pkg_source[[pkg]]

  if (src == "NOT_FOUND") {
    row <- paste0(
      '"', pkg, '",',
      '"(CRANに存在しません)",',
      '"",',
      '"",',
      '"",',
      '""'
    )
  } else {
    pkg_version <- if (src == "CRAN") ap_cran[pkg, "Version"] else "(CRANに存在しません)"
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

# ----------------------------------------------------------
# 依存パッケージ一覧 CSV 出力
# 全パッケージの再帰依存（直接＋間接）を集約し、
# check_target_packages.txt 記載のパッケージを除外後、
# アルファベット順に並べてバージョンを出力
# ----------------------------------------------------------
all_dep_pkgs <- character(0)
for (pkg in pkgs) {
  rec <- all_recursive_deps[[pkg]]
  if (!is.null(rec) && length(rec) > 0) {
    all_dep_pkgs <- c(all_dep_pkgs, rec)
  }
}
all_dep_pkgs <- sort(unique(all_dep_pkgs))
all_dep_pkgs <- all_dep_pkgs[!(all_dep_pkgs %in% pkgs)]

dep_output_file <- file.path(script_dir, "dependency_info.csv")

dep_csv_header <- paste0(
  '"パッケージ名",',
  '"バージョン（', today_str, '時点のCRANの最新）"'
)

dep_csv_lines <- c(dep_csv_header)

for (dep_pkg in all_dep_pkgs) {
  if (dep_pkg %in% rownames(ap_cran)) {
    dep_ver <- ap_cran[dep_pkg, "Version"]
    dep_ver <- ifelse(is.na(dep_ver), "", dep_ver)
  } else {
    dep_ver <- "(CRANに存在しません)"
  }
  dep_row <- paste0('"', dep_pkg, '","', dep_ver, '"')
  dep_csv_lines <- c(dep_csv_lines, dep_row)
}

dep_csv_lines <- enc2utf8(dep_csv_lines)
con2 <- file(dep_output_file, open = "wb")
writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con2)
writeLines(dep_csv_lines, con2, useBytes = TRUE)
close(con2)
cat("依存パッケージ一覧CSV出力完了 (", length(all_dep_pkgs), "件 ): ", dep_output_file, "\n")
cat("=== 照会完了 ===\n")