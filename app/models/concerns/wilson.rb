module Wilson

  private

  # https://www.evanmiller.org/how-not-to-sort-by-average-rating.html
  def wilson_score(n, win)
    return 0 if n == 0

    z = 1.64485 # default confidence, a little over 95%
    phat = 1.0*win/n
    (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n) * 100
    # multiplied by 100, so on a scale of 0 to 100
  end
end
