"""Modelo de exemplo: uma rede pequena (MLP) para regressão."""

import torch
from torch import nn


class MLP(nn.Module):
    def __init__(self, in_features: int = 1, hidden: int = 32) -> None:
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(in_features, hidden),
            nn.ReLU(),
            nn.Linear(hidden, hidden),
            nn.ReLU(),
            nn.Linear(hidden, 1),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.net(x)


def best_device() -> torch.device:
    """GPU NVIDIA (cuda) se houver, senão CPU."""
    return torch.device("cuda" if torch.cuda.is_available() else "cpu")
