class SolverController < ApplicationController
  include SolverHelper
  def solution
    solve
  end
end
