# https://cloud.google.com/ai-platform/deep-learning-containers/docs/overview
FROM gcr.io/deeplearning-platform-release/tf2-cpu:m40

ARG PYTHON_VERSION=3.7
ARG DOCKER_WORKDIR=${DOCKER_WORKDIR:-"/app"}
ENV PYTHONPATH=${PYTHONPATH}:${DOCKER_WORKDIR}/{{cookiecutter.project_name}}/src

# Remove miniconda, Hello naked python
RUN rm -r /root/miniconda3 \
 && apt update && apt install -y software-properties-common \
 && add-apt-repository -y ppa:deadsnakes/ppa \
 && apt install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python3-setuptools \
    python3-pip \
    libssl1.0-dev \
    nodejs-dev \
    node-gyp \
    npm \
 && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \

# Setup Python Dependencies
WORKDIR /tmp
COPY poetry.lock pyproject.toml ./
RUN pip3 install poetry==1.0.* wheel==0.33.* \
 && poetry config virtualenvs.create false \
 && poetry install

# Setup JupyterLab Dependencies
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN jupyter serverextension enable --py jupyterlab \
 && jupyter notebook --generate-config -y \
 && sed -i -e "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '0.0.0.0'/g" /root/.jupyter/jupyter_notebook_config.py \
 && sed -i -e "s/#c.NotebookApp.port = 8080/c.NotebookApp.port = 8080/g" /root/.jupyter/jupyter_notebook_config.py \
 && sed -i -e "s/#c.NotebookApp.password = ''/c.NotebookApp.password = ''/g" /root/.jupyter/jupyter_notebook_config.py \
 && sed -i -e "s/#c.NotebookApp.token = '<generated>'/c.NotebookApp.token = ''/g" /root/.jupyter/jupyter_notebook_config.py \
 && jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build \
 && jupyter labextension install jupyterlab-plotly --no-build \
 && jupyter labextension install plotlywidget --no-build \
 && jupyter lab build ${BUILD_OPTION} \
 && jupyter nbextension enable --py widgetsnbextension \
 && unset NODE_OPTIONS

EXPOSE 8080
WORKDIR ${DOCKER_WORKDIR}

COPY . .

ENTRYPOINT ["bash", "-lc"]

CMD ["kedro jupyter lab --no-browser --allow-root --ip=0.0.0.0 --port=8080 --config=/root/.jupyter/jupyter_notebook_config.py"]
