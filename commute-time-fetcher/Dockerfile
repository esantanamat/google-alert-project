FROM public.ecr.aws/lambda/python:3.10

COPY google-api-function.py ${LAMBDA_TASK_ROOT}

COPY requirements.txt ./
RUN pip install -r requirements.txt --target ${LAMBDA_TASK_ROOT}


CMD ["google-api-function.lambda_handler"]
