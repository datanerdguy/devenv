"""A lógica fica aqui, fora do app, para ser testada sem o Streamlit."""

import math

import polars as pl


def sample(rows: int) -> pl.DataFrame:
    """Uma onda de exemplo. Troque pelos seus dados (pl.read_csv, pl.read_parquet...)."""
    return pl.DataFrame({"x": list(range(rows))}).with_columns(
        y=(pl.col("x") * (2 * math.pi / max(rows, 1))).sin()
    )


def mean(df: pl.DataFrame, column: str) -> float:
    value = df[column].mean()
    return float(value) if isinstance(value, int | float) else 0.0
