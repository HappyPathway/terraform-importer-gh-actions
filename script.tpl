git clone --bare ${public_clone_url} ${repo_path}
cd ${repo_path}
git fetch
git remote add internal ${internal_clone_url}
git push internal --force --mirror

