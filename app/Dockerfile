FROM ruby:2.7.2 as Builder

# Adds Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list

# Adds NodeJS 14
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update -qq \
    && apt-get install -y \
        nodejs \
        postgresql-client \
        netcat \
        google-chrome-stable

RUN gem install zeus -v 0.15.15.pre

# Yarn + Lighthouse Batch
RUN npm install --global yarn
RUN yarn global add lighthouse-batch

# Set the workdir inside the container
WORKDIR /usr/src

# Set the gemfile and install
COPY Gemfile* ./
RUN bundle install --jobs=10 --retry=5

# Copy the main application.
COPY . ./

RUN chmod +x ./docker/*.sh
