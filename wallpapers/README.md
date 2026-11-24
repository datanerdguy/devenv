# Papéis de parede

A pasta fica ligada em `~/Pictures/Wallpapers`, a do seletor do Noctalia. Imagens aqui ficam só na máquina (o
`.gitignore` as ignora): o repo é público, e a maioria das imagens tem dono. Imagem livre (domínio público, licença
aberta) entra no repo com `git add -f`, como a Grande Onda do Hokusai.

O monitor é 2560×1080 (21:9). Para reduzir e recortar uma imagem no tamanho dele:

```fish
vips thumbnail foto.jpg 'foto-2560x1080.jpg[Q=92,strip]' 2560 --height 1080 --crop centre --size both
```

Coleções que combinam com os temas: [rose-pine/wallpapers](https://github.com/rose-pine/wallpapers),
[linuxdotexe/nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers),
[philikarus/Kanagawa-wallpapers](https://github.com/philikarus/Kanagawa-wallpapers) e
[dharmx/walls](https://github.com/dharmx/walls).
