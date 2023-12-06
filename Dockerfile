FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

COPY ./ /home/app
WORKDIR /home/app

RUN apt update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update
RUN apt install -y python3.9
RUN apt install -y python3-pip

RUN apt-get install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN bash -c 'pip3 install -r requirements.txt && source /root/.nvm/nvm.sh && nvm install 18.7.0 && cd front && npm install && npm run build'

CMD ["/bin/bash", "-c", "python3 app.py"]