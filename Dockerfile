FROM python:3.11.0-alpine3.16
ENV PYTHONUNBUFFERED true 
WORKDIR /app
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD exec gunicorn --bind :8080 --workers 1 --threads 8 --timeout 0 main:app
