"""Exemplo de pipeline: polars para carregar e limpar, duckdb para agregar com SQL."""

import duckdb
import polars as pl


def load_sample() -> pl.DataFrame:
    """Dados de exemplo. Troque por pl.read_csv / pl.read_parquet de data/."""
    return pl.DataFrame(
        {
            "city": ["Recife", "Recife", "Curitiba", "Curitiba", "Manaus"],
            "temp_c": [30.5, 29.0, 15.0, 17.5, 32.0],
        }
    )


def summary(df: pl.DataFrame) -> pl.DataFrame:
    """Temperatura média por cidade, em SQL."""
    with duckdb.connect() as con:
        con.register("readings", df)
        return con.sql(
            "select city, avg(temp_c) as avg_temp_c from readings group by city order by city"
        ).pl()
