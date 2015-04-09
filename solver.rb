require 'matrix'

module Solver
  def integrate(a,b, &f)
    n = 100
    h = (b-a)/n.to_f
    xs = (0..n).to_a.map { |i| a + i*h }
    res = -(f.call(a) + f.call(b))/2.0
    res += xs.reduce { |sum,x| sum + f.call(x) }
    res*h
  end

	def integrate2(a,b,t,&f)
		n = 200
		h = (t)/n.to_f
		xs = (0..n).to_a.map { |i| i*h }
		ff = lambda { |tt| lambda { |x| f.call(x,tt) } }
		res = - (integrate(a,b, &(ff.call(0))) + integrate(a,b,&(ff.call(t))))
		res += xs.reduce { |sum,tt| sum + integrate(a,b, &ff.call(tt)) }
		res*h
	end

  def inv(a)
    if a.is_a? Matrix
      #logger.info "Inverting the matrix.."
      return (a.t * a).inv * a.t
    else
      #logger.fatal "Got not a matrix"
    end
  end

	def u_f(x,t)
		@u.call(x,t)
	end

	def g_f(x,t)
		@g.call(x,t)
	end

	def init(lfr, rgh, tT, x0, y0, xg, tg, yg, u, g)
		@inited = true
		@lfr = lfr
		@rgh = rgh
		@tT = tT
		@x0 = x0
		@y0 = y0
		@xg = xg
		@tg = tg
		@yg = yg
		@u = u
		@g = g
	end

	def build_p1
		return if @p1
		sz = @x0.size + @xg.size
		aat = Matrix.build(sz,sz) do |row,col|
			lambda do |xx,tt|
				r = row < @x0.size ?
					@a1i[row].call(xx,tt)
				:
					@a2i[row-@x0.size].call(xx,tt)
				c = col < @x0.size ?
					@a1i[col].call(xx,tt)
				:
					@a2i[col-@x0.size].call(xx,tt)
				2*r*c
			end
		end
		@p1 = Matrix.build(sz, sz) do |row, col|
			integrate2(@lfr, @rgh, @tT, &aat[row,col])
		end
	end

	def build_y
		return if @yy
		@yy = Matrix.column_vector(@y0+@yg)
	end

	def u0(x,t)
		build_ai
		build_p1
		build_y
		vec = Matrix[(@a1i + @a2i).map { |func| func.call(x,t) }] # (a11t, a21t) |s
		res = vec*inv(@p1)*@yy
		res[0,0]
	end

	def build_ai
		return if @a1i && @a2i
		#logger.info "Building A11.."
		#logger.info "Building A12.."
		@a1i = @x0.map do |x0|
			lambda do |x,t|
				g_f(x0-x,-t)
			end
		end
		#logger.info "Building A21.."
		#logger.info "Building A22.."
		@a2i = @xg.zip(@tg).to_a.map do |xg, tg|
			lambda do |x,t|
				g_f(xg-x, tg-t)
			end
		end
	end

	def build_ui
		return if @u0 && @ug
		@u0 = @x0.map { |x0| u0(x0,0) }
		@ug = @xg.zip(@tg).map { |x,t| u0(x,t) }
	end

	def solve
		build_ui
		lambda do |x,t|
			x=x.to_f
			t=t.to_f
			yinf = integrate2(@lfr, @rgh, @tT) { |xx,tt| g_f(x-xx,t-tt)*u_f(xx,tt) }
			y0 = 0
			@x0.zip(@u0).each { |xx, u| y0 += g_f(x-xx,t)*u }
			yg = 0
			@xg.zip(@tg, @ug).each { |xx, tt, u| yg += g_f(x-xx, t-tt)*u }
			yinf + y0 + yg
		end
	end
end

# some tests ;)
include Solver
y = lambda do |x,t|
	Math.sin(x.to_f) + t**3/6.0
end

u = lambda do |x,t|
	t - Math.sin(x)
end

g = lambda do |x,t|
	c = 5.0
	1/(2*c) * ( x < 0 ? 0 : c*t - x.abs)
end

rand = Random.new

l0 = lG = 5
x0 = Array.new(l0) { rand.rand*10 }

xG = Array.new(lG) { rand.rand*10 }
tG = Array.new(lG) { rand.rand*10 }

y0 = x0.map { |x| y.call(x,0) }
yG = xG.zip(tG).map { |x,t| y.call(x, t) }

init(0,10, 6, x0, y0, xG, tG, yG, u, g)
res = solve

(0..10).each do |i|
	(0..3).each do |j|
		print "(%2d, %2d) real: %4.5f   find: %4.5f\n" % [i,j, y.call(i,j), res.call(i,j)]
	end
end

