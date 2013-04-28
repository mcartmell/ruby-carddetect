#ruby-carddetect

Detects rank and suit of playing cards in an image using [ruby-vips](https://github.com/jcupitt/ruby-vips]) and [tesseract](https://github.com/meh/ruby-tesseract-ocr).

#example

```ruby
  cards = CardDetect.get_cards("/some/image.png")
  p cards
  # ["6d", "10h", "Qh", "9h"]
```

#TODO

* Work out how to greyscale an image in vips (convert is too slow)
* Detect different-sized cards (eg. hole cards)
