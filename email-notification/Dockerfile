FROM public.ecr.aws/lambda/python:3.10

COPY email-api-function.py ${LAMBDA_TASK_ROOT}

COPY requirements.txt ./
RUN pip install -r requirements.txt --target ${LAMBDA_TASK_ROOT}


CMD ["email-api-function.lambda_handler"]
