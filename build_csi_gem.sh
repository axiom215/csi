#!/bin/bash --login
rm pkg/*.gem
old_ruby_version=$(cat /csi/.ruby-version)
git pull
new_ruby_version=$(cat /csi/.ruby-version)

if [[ $old_ruby_version == $new_ruby_version ]]; then
  rake
  rake install
  rake rerdoc
  gem rdoc --rdoc --ri --overwrite -V csi
  bundle update
  bundle-audit update
  echo "Invoking bundle-audit Gemfile Scanner..."
  bundle-audit
else
  cd /csi && ./upgrade_ruby.sh $new_ruby_version $old_ruby_version
fi
