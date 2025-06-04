FROM public.ecr.aws/lambda/python:3.10

COPY arrival-time-checker-function.py ${LAMBDA_TASK_ROOT}

CMD ["arrival-time-checker-function.lambda_handler"]
