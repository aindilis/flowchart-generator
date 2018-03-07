({ rank = BT\; })

(convert flp2-bt.png -distort Perspective '0,0 0,0  825,0 825,0  0,825 0,825  825,825 825,825' flp2-bt-p.png)

(convert flp2-bt.png -distort Perspective '0,0 200,0  825,0 625,0  0,825 0,412.5  825,825 825,412.5' flp2-bt-p.png\; xdg-open  flp2-bt-p.png # right)
(convert flp2-bt.png -distort Perspective '-300,0 0,0  1125,0 825,0  0,825 0,412.5  825,825 825,412.5' flp2-bt-p.png\; xdg-open  flp2-bt-p.png # right)

(convert flp2-bt.png -distort Perspective '0,0 1,0 0,1 1,1' flp2-bt-p.png; xdg-open  flp2-bt-p.png # right)

(convert flp2-bt.png -distort Perspective '0,0 0.5,0.5 1.5,0.5 2.0,0.5' flp2-bt-p.png; xdg-open  flp2-bt-p.png # right)
  

