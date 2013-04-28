require 'vips'
require 'tesseract'
require 'tempfile'

include VIPS

class CardDetect

	@te = Tesseract::Engine.new {|e|
		e.language = :eng
	}
	
	def self.get_cards(fn)
		im = Image.new(fn)
		whites = []
		curwhite = []

		(0..im.y_size-1).each do |y|
			(0..im.x_size-1).each do |x|
				p = im[x,y]
				if (p[0] == 255 && p[1] == 255 && p[2] == 255)
					curwhite.push([x,y])
				else
					whites.push(curwhite) unless curwhite.empty?
					curwhite = []
				end
			end
		end

		whites.select! {|p| p.size > 10 && p.size < 500}
		biggest = whites.map{|p| p.size}.max
		big_x = whites.select {|p| p.size >= biggest-1}.map{|p| p[0]}.uniq {|p| p[0]}

		cards = []
		i = 0
		big_x.each do |c|
			x = c[0]
			top_left = (c[1].downto(0)).take_while{|y| white?(im[x,y])}.last
			bottom_left = (c[1]..(im.y_size)).take_while{|y| white?(im[x,y])}.last
			width = biggest
			height = bottom_left - top_left
			
			# get suit
			im2 = im.extract_area(x,top_left,width,height)
			suit = nil
			nw = im2.each_pixel do |pcol,x,y|
				unless white?(pcol)
					suit = find_suit(pcol)
					break	
				end
			end

			# get rank
			numw = (width * 0.4).to_i
			ntl = c[1] - (width * 0.45).to_i
			numh = (width * 0.45).to_i
			num = im.extract_area(x,ntl,numw, numh)

			cardtf = Tempfile.new(["card", ".png"])
			cardfn = cardtf.path
			#dbgcardfn = "card_#{i = i + 1}.png"
			num.write(cardfn)
			system("convert -monochrome #{cardfn} #{cardfn}")
			rank = @te.text_for(cardfn).strip
			rank = 'T' if rank == 10
			cards.push "#{rank}#{suit}"
		end
		return cards
	end

	def self.white?(p)
		return p[0] > 240 && p[1] > 240 && p[2] > 240
	end

	def self.find_suit(p)
		if (p[1] > p[0] && p[1] > p[2])
			return 'c'
		elsif (p[0] > p[1] && p[0] > p[2])
			return 'h'
		elsif (p[2] > p[1] && p[2] > p[0])
			return 'd'
		else
			return 's'
		end
	end
end
