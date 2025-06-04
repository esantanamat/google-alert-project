FROM public.ecr.aws/lambda/python:3.10

COPY google-api-function.py ${LAMBDA_TASK_ROOT}

CMD ["google-api-function.py.lambda_handler"]
