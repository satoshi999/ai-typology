FROM python:3.8.9

COPY ./ /home/app

WORKDIR /home/app

RUN pip3 install -r requirements.txt

ENTRYPOINT ["python3", "app.py"]