# https://cloud.google.com/ai-platform/deep-learning-containers/docs/overview
FROM gcr.io/deeplearning-platform-release/tf2-cpu:m42

ENV PYTHONPATH=${PYTHONPATH}:${DOCKER_WORKDIR}/{{cookiecutter.project_name}}/src
ENV PYTHONUNBUFFERED=1
RUN test "$(PYTHON_VERSION) == $(python -V | sed -e 's/Python //g')"

# Setup Unix Dependencies
RUN apt update && apt install -y --no-install-recommends \
    gcc-8 \
    g++-8 \
    cmake \
    graphviz \
    libssl1.0-dev \
    nodejs-dev \
    node-gyp \
    npm \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

# Setup Python Dependencies
RUN pip install --no-cache-dir poetry==1.0.* wheel==0.33.* setuptools==45.1.* cython==0.29.* \
    jupyterlab==1.2.* jupyter_nbextensions_configurator==0.4.* jupyter-tensorboard==0.1.* \
    plotly==4.5.* ipywidgets==7.5.* nbbrowserpdf==0.2.* \
 && poetry config virtualenvs.create false

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

WORKDIR ${DOCKER_WORKDIR}
COPY . .
RUN poetry install

# for JupyterLab
EXPOSE 8080
# for TensorBoard
EXPOSE 6006
# for Kedro-Viz
EXPOSE 4141

ENTRYPOINT ["bash", "-lc"]

CMD ["honcho start --no-colour --no-prefix $PROCESSES"]
