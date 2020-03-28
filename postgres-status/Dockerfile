FROM node as builder
WORKDIR /app
ADD package*.json ./
RUN npm ci
ADD index.js ./

FROM astefanutti/scratch-node:12
COPY --from=builder /app /
USER 1000
EXPOSE 8000
ENTRYPOINT []
CMD ["node", "index.js"]
