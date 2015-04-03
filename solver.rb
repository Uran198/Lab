require 'matrix'

module Solver
  def integrate(a,b, &f)
    n = 1000
    h = (b-a)/n.to_f
    xs = (0..n).to_a.map { |i| a + i*h }
    res = -(f.call(a) + f.call(b))/2.0
    res += xs.reduce { |sum,x| sum + f.call(x) }
    res*h
  end

  def inv(a)
    if a.is_a? Matrix
      logger.info "Inverting the matrix.."
      return (a.t * a).inv * a.t
    else
      logger.fatal "Got not a matrix"
    end
  end

  def build_ai
    logger.info "Building A11.."
    logger.info "Building A12.."
    logger.info "Building A21.."
    logger.info "Building A22.."
  end

  def build_y
    logger.info "Building Y0.."
    logger.info "Building Yg.."
  end

  def build_a
    logger.info "Building A.."
  end

  def build_p1
    build_a
    logger.info "Building P1.."
  end

  def find_ui
    build_ai
    build_p1
    build_y
    logger.info "Building u0.."
    logger.info "Building ug.."
  end

  def find_y_inf
    logger.info "Building y_inf.."
  end

  def solve
    find_ui
    find_y_inf
    logger.info "Building solution.."
  end
end
