echo "export http_proxy=127.0.0.1:20171" >> ~/.zshrc
echo "export https_proxy=\$http_proxy" >> ~/.zshrc
echo "export ftp_proxy=\$http_proxy" >> ~/.zshrc
echo "export rsync_proxy=\$http_proxy" >> ~/.zshrc
echo "export no_proxy=\"localhost.127.0.0.1\"" >> ~/.zshrc
