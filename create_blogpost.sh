#!/usr/bin/env bash

# TODO: use https://cli.github.com/
# TODO: use brew also on linux

set -e

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# prepare git development branch - the safe way ;)
git checkout main
git pull
git remote prune origin
git pull
git reset --hard HEAD
git pull
git checkout main
git checkout devel || git checkout -b devel
git merge main

# store absolute path
git_repo_base_patch="$(git rev-parse --show-toplevel)"


#
# select_featured_blog_post_photo
#
select_featured_blog_post_photo_Linux() {
  # TODO:
  echo todo
}
select_featured_blog_post_photo_Darwin() {
  # TODO: how to select file: https://apple.stackexchange.com/q/328557
  # TODO:
  echo todo
}

#
# convert_to_webp
#
convert_to_webp_Linux() {
  convert -quality 70 -resize '1000x' "${input_image}" "${git_repo_base_patch}/source/assets/img/posts/${input_image}_1000_70percent.webp"
}
convert_to_webp_Darwin() {
  # see also https://developers.google.com/speed/webp/docs/cwebp
  cwebp -q 70 -resize 1000 0 "${input_image}" -o "${git_repo_base_patch}/source/assets/img/posts/${input_image}_1000_70percent.webp"
}

#
# describe_featured_blog_post_photo_de
#
describe_featured_blog_post_photo_de_Linux() {
  xdg-open "${git_repo_base_patch}/source/assets/img/posts/${input_image}_1000_70percent.webp" 2>/den/null
  dialog --keep-tite --inputbox 'Describe the featured blog post (German)' 0 0 2> "$tmp_fl"
  post_photo_description_de="$(cat "$tmp_fl")"
}
describe_featured_blog_post_photo_de_Darwin() {
  # TODO:
  abort todo
}

#
# describe_featured_blog_post_photo_en
#
describe_featured_blog_post_photo_en_Linux() {
  xdg-open "${git_repo_base_patch}/source/assets/img/posts/${input_image}_1000_70percent.webp" 2>/den/null
  dialog --keep-tite --inputbox 'Describe the featured blog post (English)' 0 0 2> "$tmp_fl"
  post_photo_description_en="$(cat "$tmp_fl")"
}
describe_featured_blog_post_photo_en_Darwin() {
  # TODO:
  abort todo
}

#
# select_date_of_blogpost
#
select_date_of_blogpost_Linux() {
  dialog --keep-tite --date-format '%Y-%m-%d 09:00:00 +0100' --calendar 'pick release date' 0 0 2> "$tmp_fl"
  post_date="$(cat "$tmp_fl")"
  post_date_short="$(cut -d' ' -f1 "$tmp_fl")"
}
select_date_of_blogpost_Darwin() {
  # TODO:
  abort todo
}

#
# select_title_of_blogpost_de
#
select_title_of_blogpost_de_Linux() {
  dialog --keep-tite --inputbox 'enter title (German)' 0 0 2> "$tmp_fl"
  post_title_de="$(cat "$tmp_fl")"
  post_title_de_url="$(sed 's/ /-/g' "$tmp_fl")"
}
select_title_of_blogpost_de_Darwin() {
  # TODO:
  abort todo
}

#
# select_title_of_blogpost_en
#
select_title_of_blogpost_en_Linux() {
  dialog --keep-tite --inputbox 'enter title (English)' 0 0 2> "$tmp_fl"
  post_title_en="$(cat "$tmp_fl")"
  post_title_en_url="$(sed 's/ /-/g' "$tmp_fl")"
}
select_title_of_blogpost_de_Darwin() {
  # TODO:
  abort todo
}


# First check OS.
# TODO: maybe use brew also on Linux
# TODO: Configure git to use GitHub CLI as the credential helper for all authenticated hosts
# TODO: https://cli.github.com/manual/gh_auth_setup-git
OS="$(uname)"
if [[ "${OS}" == "Linux" ]]; then
  # here we have linux
  if ! type -P git; then
    abort 'git is missing.'
  fi
  if ! type -P convert; then
    abort 'image magick (convert) is missing.'
  fi

  # TODO: also darwin?
  tmp_fl="$(mktemp)"
  trap 'rm -f ${tmp_fl}' EXIT


elif [[ "${OS}" == "Darwin" ]]; then
  # here we have apple

  # check git
  if ! type -P git; then
    xcode-select --install
  fi

  # check converter for webp
  if ! type -P cwebp; then
    # check brew
    if ! type -P brew; then
      # install brew
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # install cwebp
    brew install webp
  fi

  # get input for webp
  input_image='bla.jpg'

else
  abort 'This script only works on macOS and Linux.'
fi


#
# main
#

# ask for Featured Blog Post photo
"select_featured_blog_post_photo_${OS}"

# convert it
"convert_to_webp_${OS}"

# ask for description
"describe_featured_blog_post_photo_de_${OS}"
"describe_featured_blog_post_photo_en_${OS}"

# select date for blogpost
"select_date_of_blogpost_${OS}"

# select title for blogpost
"select_title_of_blogpost_de_${OS}"
"select_title_of_blogpost_en_${OS}"

# edit content
# TODO: https://cli.github.com/manual/gh_browse
