#!/usr/bin/env bash
#
# This script helps creating (not updating!) blog post files
#
# tools needed:
#   * git
#   * brew
#   * cwebp (by brew)
#   * gh (by brew)
#   * interactive parts on macos: applescript / display dialog
#

# TODO: https://scriptingosx.com/2018/08/user-interaction-from-bash-scripts/

set -euo pipefail

abort() {
  echo
  echo 'Abort.'
  exit 1
}

#
# select_featured_blog_post_photo
#
check_softwares_common() {
  # check for brew installer
  if ! type -P brew >/dev/null; then
    echo 'brew is missing. Install it by typing:'
    # shellcheck disable=SC2016
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    abort
  fi

  # check for webp converter webp
  if ! type -P cwebp >/dev/null; then
    echo 'webp is missing. Install it by typing:'
    echo '  brew install webp'
    abort
  fi

  # check for github cli client
  if ! type -P gh >/dev/null; then
    echo 'gh is missing. Install it by typing:'
    echo '  brew install gh'
    echo
    abort
  fi

  # check if gh is logged in
  if ! gh auth status -h github.com >/dev/null 2>&1; then
    gh auth login --hostname github.com --git-protocol ssh --web
  fi

  # always setup git auth
  gh auth setup-git

}
check_softwares_Linux() {
  # check for git
  if ! type -P git >/dev/null; then
    abort 'git is missing. Install it using your package manager'
  fi
  check_softwares_common
}
check_softwares_Darwin() {
  # check git
  if ! type -P git >/dev/null; then
    abort 'git is missing. Install it by typing:\n  xcode-select --install'
  fi
  check_softwares_common
}

#
# prepare_git_dir
#
prepare_git_dir() {
  # prepare git development branch - the safe way ;)
  git checkout main
  git pull --ff-only
  git remote prune origin
  git pull --ff-only
  git reset --hard HEAD
  git pull --ff-only
  git checkout main
  git checkout devel || git checkout -b devel
  git merge main

  # store absolute path
  git_repo_base_patch="$(git rev-parse --show-toplevel)"
}

#
# select_featured_blog_post_photo
#
select_featured_blog_post_photo_Linux() {
  while true; do
    read -rp 'insert full path of image to be converted: '
    input_image="$(eval echo "$REPLY")"
    if [ -e "${input_image}" ]; then
      break
    else
      echo "The file '${REPLY}' does not exist or is not a file. Please try again"
    fi
  done
}
select_featured_blog_post_photo_Darwin() {
  # TODO: how to select file: https://apple.stackexchange.com/q/328557
  osascript -e "display dialog \"Bitte auf OK klicken und im nächsten Fenster das Foto auswählen, das für den Blogpost verwendet werden soll.\" with title \"Heyho!\""
  input_image="$(osascript -e "set directory to posix path of (choose file with prompt \"Wähle Datei\" default location (path to desktop))")"
}

#
# convert_to_webp
#
convert_to_webp() {
  output_image="${git_repo_base_patch}/source/assets/img/posts/$(basename "$input_image")_1000_70percent.webp"
  output_image_basename="$(basename "$output_image")"
  if [ -e "${output_image}" ]; then
    echo "The featured blog post photo '${output_image}' already exists."
    abort
  else
    # see also https://developers.google.com/speed/webp/docs/cwebp
    cwebp -q 70 -resize 1000 0 "${input_image}" -o "${output_image}"
    echo
    echo
  fi
}

#
# describe_featured_blog_post_photo_de
#
describe_featured_blog_post_photo_Linux() {
  # TODO: too much ( xdg-open "${output_image}" ) >/dev/null 2>&1 || true
  while true; do
    read -rp 'Describe the blog post image in German: '
    if [ "$(wc -w <<< "${REPLY}")" -ge 3 ]; then
      break
    else
      echo "The description '${REPLY}' does not contain three or more words. Please try again."
    fi
  done
  post_photo_description_de="${REPLY}"
  while true; do
    read -rp 'Describe the blog post image in English: '
    if [ "$(wc -w <<< "${REPLY}")" -ge 3 ]; then
      break
    else
      echo "The description '${REPLY}' does not contain three or more words. Please try again."
    fi
  done
  post_photo_description_en="${REPLY}"
}
describe_featured_blog_post_photo_Darwin() {
  post_photo_description_de="$(osascript -e "text returned of (display dialog \"Beschreibe das Bild für den Blogpost auf Deutsch\" with title \"Bildbeschreibung Deutsch\" default answer \"\")")"
  post_photo_description_en="$(osascript -e "text returned of (display dialog \"Beschreibe das Bild für den Blogpost auf Englisch\" with title \"Bildbeschreibung Englisch\" default answer \"\")")"
}


#
# select_date_of_blogpost
#
select_date_of_blogpost_Linux() {
  while true; do
    read -rp 'Insert the publishing date of the Blogpost (Format: YYYY-MM-DD): '
    if date --date="${REPLY} 09:00:00 +0100" >/dev/null 2>&1 && wc -m <<< "${REPLY}" >/dev/null 2>&1; then
      break
    else
      echo "The date '${REPLY}' is invalid. Please try again."
    fi
  done
  post_date="${REPLY} 09:00:00 +0100"
  post_date_short="${REPLY}"
}
select_date_of_blogpost_Darwin() {
  while true; do
    REPLY="$(osascript -e "text returned of (display dialog \"Gebe das Datum der Veröffentlichung im Format JJJJ-MM-TT ein\" with title \"Veröffentlichungsdatum\" default answer \"\")")"
    if date -jf "%Y-%m-%d %H:%M:%S %z" "${REPLY} 09:00:00 +0100" >/dev/null 2>&1 && wc -m <<< "${REPLY}" >/dev/null 2>&1; then
      break
    else
      osascript -e "display notification \"Das Datum '${REPLY}' ist ungültig. Bitte nocheinmal versuchen.\" with title \"Tippfehler?\""
    fi
  done
  post_date="${REPLY} 09:00:00 +0100"
  post_date_short="${REPLY}"
}

#
# select_title_of_blogpost
#
select_title_of_blogpost_Linux() {
  while true; do
    read -rp 'Enter the blog post title in German: '
    if [ "${REPLY}" != '' ]; then
      break
    else
      echo "The description '${REPLY}' is empty. Please try again."
    fi
  done
  post_title_de="${REPLY}"
  post_title_de_url="${REPLY// /-}"

  while true; do
    read -rp 'Enter the blog post title in English: '
    if [ "${REPLY}" != '' ]; then
      break
    else
      echo "The description '${REPLY}' is empty. Please try again."
    fi
  done
  post_title_en="${REPLY}"
  post_title_en_url="${REPLY// /-}"
}
select_title_of_blogpost_Darwin() {
  while true; do
    REPLY="$(osascript -e "text returned of (display dialog \"Gebe den Blogpost Titel auf Deutsch ein\" with title \"Blogpost Titel Deutsch\" default answer \"\")")"
    if [ "${REPLY}" != '' ]; then
      break
    else
      osascript -e "display notification \"Der Titel ist leer - Bitte nocheinmal versuchen.\" with title "Nocheinmal bitte""
    fi
  done
  post_title_de="${REPLY}"
  post_title_de_url="${REPLY// /-}"

  while true; do
    REPLY="$(osascript -e "text returned of (display dialog \"Gebe den Blogpost Titel auf Engilsch ein\" with title \"Blogpost Titel Englisch\" default answer \"\")")"
    if [ "${REPLY}" != '' ]; then
      break
    else
      osascript -e "display notification \"Der Titel ist leer - Bitte nocheinmal versuchen.\" with title \"Nocheinmal bitte\""
    fi
  done
  post_title_en="${REPLY}"
  post_title_en_url="${REPLY// /-}"
}

#
# create_blog_post_files
#
create_blog_post_files() {

  # create german post
  blogpost_file_de="${git_repo_base_patch}/source/de/_posts/${post_date_short}-${post_title_de_url}.md"
  echo "Creating German Blogpost file '${blogpost_file_de}'..."
  if [ -e "${blogpost_file_de}" ]; then
    echo "The German Blogpost file already exists."
    abort
  else
    cat << EOF > "${blogpost_file_de}"
---
layout: 'sub-page'
extra_include: 'go_back_to_blog.html'
lang: 'de'

title: '${post_title_de}'
date: '${post_date}'
path_to_other_lang: 'en/posts/${post_date_short}-${post_title_en_url}/'
blog_list_image: '${output_image_basename}'
---
![${post_photo_description_de}](../../../assets/img/posts/${output_image_basename} "Featured Blog Post Foto")

Hier bitte den Blogpost Text ersetzen. Alles vor dem<!--more--> erscheint in der Blogpost Übersicht, alles danach nicht mehr.

Links werden folgendermaßen formatiert: [Angezeigter Text (KLICK MICH)](https://www.startnext.com/nbtf-right-where-you-are){:target="_blank"}

EOF
  fi

  # create english post
  blogpost_file_en="${git_repo_base_patch}/source/en/_posts/${post_date_short}-${post_title_en_url}.md"
  echo "Creating German Blogpost file '${blogpost_file_en}'..."
  if [ -e "${blogpost_file_en}" ]; then
    echo "The English Blogpost file already exists."
    abort
  else
    cat << EOF > "${blogpost_file_en}"
---
layout: 'sub-page'
extra_include: 'go_back_to_blog.html'
lang: 'de'

title: '${post_title_en}'
date: '${post_date}'
path_to_other_lang: 'en/posts/${post_date_short}-${post_title_de_url}/'
blog_list_image: '${output_image_basename}'
---
![${post_photo_description_en}](../../../assets/img/posts/${output_image_basename} "Featured Blog Post Foto")

Hier bitte den Blogpost Text ersetzen. Alles vor dem<!--more--> erscheint in der Blogpost Übersicht, alles danach nicht mehr.

Links werden folgendermaßen formatiert: [Angezeigter Text (KLICK MICH)](https://www.startnext.com/nbtf-right-where-you-are){:target="_blank"}

EOF
  fi
}

#
# git_push_files_and_create_pr
#
git_push_files_and_create_pr() {
  git add "${blogpost_file_de}" "${blogpost_file_en}" "${output_image}"
  git commit -m "Create post '${post_title_en}'"
  git push --set-upstream origin "$(git rev-parse --abbrev-ref HEAD)"
  gh pr create --title "Create post '${post_title_en}'" --body "See also https://chrisongthb.github.io/nobutthefrog-com/blog/ or https://chrisongthb.github.io/nobutthefrog-com/en/blog/ - You may have to reload the pages by Option+Command+R (Strg+F5)"
}

#
# main
#

# check OS
OS="$(uname)"
if [ "${OS}" != "Linux" ] && [ "${OS}" != "Darwin" ]; then
  abort 'This script only works on macOS and Linux.'
fi

# check for softwares
"check_softwares_${OS}"

# prepare git - no decision between OS
prepare_git_dir

# ask for Featured Blog Post photo
"select_featured_blog_post_photo_${OS}"

# convert it
convert_to_webp

# ask for description
"describe_featured_blog_post_photo_${OS}"

# select date for blogpost
"select_date_of_blogpost_${OS}"

# select title for blogpost
"select_title_of_blogpost_${OS}"

# create blog post files
create_blog_post_files

# git push
git_push_files_and_create_pr

# open it in web browser
read -rp 'Edit the blog posts by via the pull request. Press ENTER to open the pull requests...'
gh pr list -w
