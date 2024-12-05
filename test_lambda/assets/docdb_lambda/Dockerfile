FROM --platform=linux/amd64 public.ecr.aws/lambda/nodejs:20 as builder
COPY package*.json ${LAMBDA_TASK_ROOT}
RUN npm install
COPY index.js ${LAMBDA_TASK_ROOT}
CMD ["index.handler"]