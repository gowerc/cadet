## https://hub.docker.com/_/python
FROM python:3.9
RUN mkdir /app
WORKDIR /app
COPY ./requirements.txt  /
RUN pip install --upgrade pip
RUN pip install -r /requirements.txt
CMD ["python3"]
