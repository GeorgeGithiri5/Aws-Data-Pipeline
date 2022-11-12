
FROM amazon/aws-glue-libs:glue_libs_2.0.0_image_01
LABEL maintainer = "Data Engineers at Augius xxxx<@augius.com>"

WORKDIR /

# pip installing dependencies
RUN pip3 install sparkmagic
RUN python3 -m pip install --upgrade pip

COPY . .

ENV PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.0.5 \
    POETRY_HOME="/home/glue_user/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/home/glue_user/pysetup" \
    VENV_PATH="/home/glue_user/pysetup/.venv"

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH
COPY docker-dependencies/poetry.lock docker-dependencies/pyproject.toml ./

# Update dependencies in poetry
RUN poetry update --no-dev --no-ansi --no-interaction
# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev --no-ansi --no-interaction

ENTRYPOINT [ "/home/glue_user/jupyter/jupyter_start.sh" ]

CMD ["bash", "-V"]
