# Description



In this repository, I am working on a data pipeline architecture on AWS. The set up have a deployment layer built using terraform. AWS Resources used: Redshift, S3, AWS Glue. The Setup uses pyspark and is laid out in a way it's scalable for any number of jobs.







## Setting up for local development







1. Install Poetry following the [official documentation](https://python-poetry.org/docs/)



2. Setting to create virtual environment locally



```bash

    poetry config virtualenvs.create true --local

```



3. Create the environment



```bash

    make deps

```



4. Activate the environment



```bash

    source .venv/bin/activate

```



5. In case you want to add new packages just use poetry for this



```bash

    poetry add <package_name>

```



6. Install pre-commit



```bash

    make pre-commit

```



For further information please check the poetry documentation.


# AWS Local development set-up

1). Make sure docker is installed on your machine [docker setup](https://docs.docker.com/desktop/install/mac-install/)

2). Make sure you have atleast 7 GB of disk space for image hosting on the running docker

3). Pull the AWS Glue docker image {optional}

```bash
 $ docker pull amazon/aws-glue-libs:glue_libs_2.0.0_image_01
```
4). Go to Docker desktop and navigate to images and click run to start the container.

5). Copy the `copy.env` file and rename the new copy to `.env`

6). Input the AWS Credentials in the `.env` file as below:
```bash
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_DEFAULT_REGION=xxx
```

7). run the following command to start the docker container

 ``` bash
 docker-compose up -d
 ```
8). To open the jupyter notebook for development. Open [localhost:8888](localhost:8888) in the browser.



## Folder Structure

1). `src`: This stores the main source code for data engineering tasks. It will be mainly used to store production code or refined code.
2). `tests`: This stores the unit tests for the written functions
3). `libs`: This stores the reusable libraries and modules for the repository.
4). `notebooks`: This will store the jupyter notebooks used in experimentation and testing the different functionalities especially using docker container. The files in this folder will not be tested or deployed since they are for experimentation purposes.
5). `docs`: This can store additional documentations for the data engineering pipeline including the data sources.



## Continous Integration Pipeline



For each pull request, the python code should meet the python standards to be enforced by the linter. They include formating standards, pep8 coding style and markdown documentation standard. The tests will fail on each push to enforce consistency in the repository.





## Deployment

The following will be used for deployment and creation of AWS resources mainly using Github actions and terraform.



1).  Push to the main branch

2).  It will trigger a creation of the crawlers and glue jobs on AWS.



Every merge into the main branch will trigger an automatically deployment of the jobs to AWS using Github actions.

To add new glue scripts for deployment:

a). Add the script in the src folder
b). Go to the terraform variable file `deployment/glue_jobs/variables.tf`
c). Add the name of the script in the variable `variable "glue_scripts {default = ["script1", "script2"]}`.
note: The variable is at the beginning of the terraform script for convenience

