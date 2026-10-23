# Migração inicial (gerada pelo makemigrations). As próximas: `just manage makemigrations`.

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Todo",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("text", models.CharField(max_length=200)),
                ("created", models.DateTimeField(auto_now_add=True)),
            ],
            options={
                "ordering": ("created",),
            },
        ),
    ]
