from kedro.pipeline import Pipeline, node

from .nodes import create_master_table, preprocess_companies, preprocess_shuttles


def create_pipeline(**kwargs):
    return Pipeline([
        node(
            func=preprocess_companies,
            inputs="companies",
            outputs="preprocessed_companies",
            name="preprocessing_companies",
        ),
        node(
            func=preprocess_shuttles,
            inputs="shuttles",
            outputs="preprocessed_shuttles",
            name="preprocessing_shuttles",
        ),
        node(
            func=create_master_table,
            inputs=["preprocessed_shuttles", "preprocessed_companies", "reviews"],
            outputs="master_table",
        ),
    ])
