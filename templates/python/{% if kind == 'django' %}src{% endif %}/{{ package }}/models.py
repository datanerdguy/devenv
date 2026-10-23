from django.db import models


class Todo(models.Model):
    text = models.CharField(max_length=200)
    created = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("created",)

    def __str__(self) -> str:
        return self.text
