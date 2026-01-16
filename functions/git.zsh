# Git aliases and functions helpers
#
# A set of lightweight Git helper functions and short aliases intended to
# speed up common workflows.
#
# Provided functions:
#   git_current_branch() - Prints the current branch name (or nothing on failure).
#   git_is_dirty()       - Returns success if the working tree has unstaged changes.
#
# Aliases (examples):
#   gc      : commit (git commit)
#   gco     : checkout (git checkout)
#   gcb     : create + checkout (git checkout -b)
#   gp      : push (git push)
#   gpo     : push to origin (git push origin ...)
#   gpom    : push current branch to origin
#   gl      : pull (git pull)
#   glom    : pull current branch from origin
#   glomr   : pull --rebase current branch from origin
#   gst     : status (git status)
#   gs      : porcelain status (git status --porcelain)
#   glog    : pretty log (git log --oneline --graph --decorate)
#   gbd     : delete local branch(es) (git branch -D ...)
#   gsync   : push then pull current branch (gpo + glom)
#   gdone   : finish current branch, push it, and checks main
#   gnew    : create a new branch from main (must be on main and clean)
#   gwt     : create a new working tree (for concurrent work)
#
# Completions:
#   This file installs lightweight zsh completion wrappers so the short aliases
#   complete like their corresponding git subcommands (for example `gco` will
#   complete like `git checkout`). The wrappers try to reuse the standard git
#   completion function `_git` when available and fall back to minimal file
#   completions otherwise.
#
# Notes:
#   - These are intentionally minimal helpers. They wrap `git` directly and
#     forward arguments. See each function below for details.
#



git_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_is_dirty() {
    [[ -n "$(git status --porcelain 2>/dev/null)" ]]
}

gc() {
    git commit "$@"
}

gac() {
  git commit -a "$@"
}

gco() {
    git checkout "$@"
}

gcb() {
    git checkout -b "$@"
}

gp() {
    git push "$@"
}

gpo() {
    git push origin "$@"
}

gpom() {
    git push origin "$(git_current_branch)" "$@"
}

gl() {
    git pull "$@"
}

glom() {
    git pull origin "$(git_current_branch)" "$@"
}

glomr() {
    git pull --rebase origin "$(git_current_branch)" "$@"
}

gst() {
    git status "$@"
}

gs() {
    git status "$@" --porcelain
}

glog() {
    git log --oneline --graph --decorate "$@"
}

gbd() {
  # handle multiple branches
  for branch in "$@"; do
    git branch -D "$branch"
  done
}

gsync() {
  local  branch="$(git_current_branch)" || return 1
  if [[git_is_dirty()]]; then
    echo "You have changes to commit, before syncing"
    return 1
  fi
  glomr
  gpom


}

gdone() {
  gpom
  git checkout main
  git pull origin main --rebase || return 1
}

gnew() {
  local branch="$(git_current_branch)" || return 1
  if git_is_dirty; then
    echo "Working directory is dirty. Please commit or stash changes before creating a new branch."
    return 1
  fi
  # if on not main warn and exit
  if [[ "$branch" != "main" ]]; then
    echo "You are not on the main branch. Please switch to main before creating a new branch."
    return 1
  fi
  git pull origin main --rebase || return 1
  git checkout -b "$1"

}

gwt() {
  local branch="$1"
  local worktree_name="$2"
  
  if [[ -z "$branch" ]]; then
    echo "Usage: gwt <branch> [worktree-name]"
    echo "Creates a new working tree for the given branch."
    echo ""
    echo "Examples:"
    echo "  gwt feature-x                 # Creates worktree in ./feature-x"
    echo "  gwt feature-x ../concurrent   # Creates worktree in ../concurrent"
    return 1
  fi
  
  # Use branch name as worktree name if not provided
  if [[ -z "$worktree_name" ]]; then
    worktree_name="./${branch}"
  fi
  
  # Create the working tree
  git worktree add "$worktree_name" "$branch" || return 1
  echo "✓ Created working tree at: $worktree_name"
}

# zsh completion wrappers for the git aliases defined in this file.
# These wrappers attempt to call the `_git` completion helper with the right
# subcommand and flags so the aliases behave like the corresponding git
# commands when completing on the command line. If `_git` is not available,
# completions fall back to plain file completions.
__git_alias_complete() {
  local alias="$1"
  local -a prefix newwords

  case "$alias" in
    gc)
      prefix=(git commit)
      ;;
    gco)
      prefix=(git checkout)
      ;;
    gcb)
      prefix=(git checkout -b)
      ;;
    gp)
      prefix=(git push)
      ;;
    gpo)
      prefix=(git push origin)
      ;;
    gpom)
      prefix=(git push origin "$(git_current_branch)")
      ;;
    gl)
      prefix=(git pull)
      ;;
    glom)
      prefix=(git pull origin "$(git_current_branch)")
      ;;
    glomr)
      prefix=(git pull --rebase origin "$(git_current_branch)")
      ;;
    gst)
      prefix=(git status)
      ;;
    gs)
      prefix=(git status --porcelain)
      ;;
    glog)
      prefix=(git log)
      ;;
    gbd)
      prefix=(git branch -D)
      ;;
    gnew)
      prefix=(git checkout -b)
      ;;
    *)
      return 1
      ;;
  esac

  newwords=( "${prefix[@]}" ${words[2,-1]} )
  words=( "${newwords[@]}" )

  # Advance the completion cursor by the number of inserted tokens minus
  # the one token we replaced (the alias itself).
  (( CURRENT += ${#prefix[@]} - 1 ))

  # Prefer git's completion function when available.
  if (( $+functions[_git] )); then
    _git
  else
    _files
  fi
}

# Install completion wrappers for each alias if `compdef` is available.
# We check both commands and functions because compdef may be an autoload.
if (( $+commands[compdef] )) || (( $+functions[compdef] )); then
  for _alias in gc gco gcb gp gpo gpom gl glom glomr gst gs glog gbd gnew gwt; do
    eval "_git_alias_${_alias}() { __git_alias_complete ${_alias} }"
    compdef "_git_alias_${_alias}" ${_alias}
  done
fi
