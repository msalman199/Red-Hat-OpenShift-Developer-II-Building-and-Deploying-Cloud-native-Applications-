FROM python:3.9-slim

WORKDIR /app

RUN pip install flask

COPY src/app.py .

ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION}
ENV FAIL_HEALTH=false

EXPOSE 5000

CMD ["python", "app.py"]
