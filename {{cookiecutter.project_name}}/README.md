# {{cookiecutter.project_name}}

## Prerequisites
| Software                 | Install (Mac)              |
|--------------------------|----------------------------|
| [Python 3.7.6][python]   | `pyenv install 3.7.6`      |
| [Poetry 1.0.*][poetry]   | `curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py \| python`|
| [direnv][direnv]         | `brew install direnv`      |
| [Docker][docker]         | `brew cask install docker` |

[python]: https://www.python.org/downloads/release/python-376/
[poetry]: https://python-poetry.org/
[direnv]: https://direnv.net/
[docker]: https://docs.docker.com/docker-for-mac/

## Declare configurations
```bash
vi .env
=====================
PORT=YOUR_JUPYTER_PORT
BUILD_OPTION=--minimize=False
PROCESSES=kedro kedro_viz
```

## Overview

Take a look at the [documentation](https://kedro.readthedocs.io) to get started.

## Rules and guidelines

In order to get the best out of the template:
 * Please don't remove any lines from the `.gitignore` file provided
 * Make sure your results can be reproduced by following a data engineering convention, e.g. the one we suggest [here](https://kedro.readthedocs.io/en/latest/06_resources/01_faq.html#what-is-data-engineering-convention)
 * Don't commit any data to your repository
 * Don't commit any credentials or local configuration to your repository
 * Keep all credentials or local configuration in `conf/local/`

## Installing dependencies

Dependencies should be declared in `pyproject.toml` for pip installation.

To install them, run:

```
poetry install
```

If you add new dependency:

```
poetry add pandas
```

If you want to use it in only a development environment:

```
poetry add --dev pytest
```

## Running Kedro

You can run your Kedro project with:

```
poetry run kedro run
```

## Testing Kedro

Have a look at the file `src/tests/test_run.py` for instructions on how to write your tests. You can run your tests with the following command:

```
poetry run kedro test
```

To configure the coverage threshold, please have a look at the file `.coveragerc`.

## Linting Kedro

If you prefer, it's possible to run linter declared in [kedro_cli.py](https://github.com/{{cookiecutter.github_user_name}}/{{cookiecutter.project_name}}/blob/master/kedro_cli.py):

```
poetry run kedro lint
```

### Working with Kedro from notebooks

You can start a local notebook server:

```
poetry run kedro jupyter lab
```

Or if you need dependencies except to python's one such as C+ binding and more:

```
# At first, write down the process to install the dependency in cpu.dockerfile
# And then, are you ready to wait a long time?
docker-compose up

# Didn't work?
docker-compose up --build
```

And if you want to run an IPython session:

```
poetry run kedro ipython
```

Running Jupyter or IPython this way provides the following variables in
scope: `proj_dir`, `proj_name`, `conf`, `io`, `parameters` and `startup_error`.

#### Converting notebook cells to nodes in a Kedro project

Once you are happy with a notebook, you may want to move your code over into the Kedro project structure for the next stage in your development. This is done through a mixture of [cell tagging](https://jupyter-notebook.readthedocs.io/en/stable/changelog.html#cell-tags) and Kedro CLI commands.

By adding the `node` tag to a cell and running the command below, the cell's source code will be copied over to a Python file within `src/<package_name>/nodes/`.
```
poetry run kedro jupyter convert <filepath_to_my_notebook>
```
> *Note:* The name of the Python file matches the name of the original notebook.

Alternatively, you may want to transform all your notebooks in one go. To this end, you can run the following command to convert all notebook files found in the project root directory and under any of its sub-folders.
```
poetry run kedro jupyter convert --all
```

