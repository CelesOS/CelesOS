echo "Dist Root: ${DIST_ROOT:?}"
echo "LFS: ${LFS:?}"

# shellcheck disable=SC2046
if ! test $(whoami) == "lfs"
then
  echo "ERROR: Must be lfs user to create build environment"
  exit 1
fi

echo "Creating build environment..."

