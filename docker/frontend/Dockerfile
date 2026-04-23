FROM nginx:1.27-alpine

ARG FRONTEND_TITLE="Local Platform"

COPY index.html /usr/share/nginx/html/index.html
RUN sed -i "s/__FRONTEND_TITLE__/${FRONTEND_TITLE}/g" /usr/share/nginx/html/index.html
