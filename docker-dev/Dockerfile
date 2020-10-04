FROM gradle:4.10.0-jdk8
USER root

# Install Build Essentials
RUN apt-get update && apt-get install -y build-essential file apt-utils ncurses-dev git usbutils

# Install RipGrep
RUN wget -O rg.deb https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb \
 && dpkg -i rg.deb \
 && rm rg.deb

ENV HOME /root
WORKDIR ${HOME}

RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT ${HOME}/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"
ENV PATH "$PATH:${HOME}/Android/sdk/tools/bin:${HOME}/Android/sdk/platform-tools"

# Install flutter
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:${HOME}/flutter/bin"
RUN flutter doctor

# Install FZF
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
 && ~/.fzf/install
ENV PATH=${PATH}:${HOME}/.fzf/bin

RUN git clone https://github.com/vim/vim.git \
 && cd vim/src \
 && make \
 && make install

# Download vundle and install all vim plugins using vundle
RUN git clone https://github.com/VundleVim/Vundle.vim.git ${HOME}/.vim/bundle/Vundle.vim
COPY vimrc ${HOME}/.vimrc
RUN vim +silent +PluginInstall +qall
